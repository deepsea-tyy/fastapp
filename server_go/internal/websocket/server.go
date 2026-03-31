package websocket

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"strconv"
	"strings"
	"sync/atomic"
	"time"

	"fastapp/internal/app/common/deps"

	"github.com/gorilla/websocket"
	"github.com/redis/go-redis/v9"
)

var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

// ListenAndServe 在独立端口提供 /ws；hub 可与 HTTP 共用；reg 由 plugin.BindingWS（已安装插件在 register 表中的 RegisterWebSocket）组装（可为 nil 表示仅基础连接无业务 action）。
func ListenAndServe(addr string, d *deps.Deps, hub *Hub, reg *ActionRegistry) error {
	if hub == nil {
		hub = NewHub()
	}
	if reg == nil {
		reg = NewRegistry()
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		serveWS(w, r, reg, d, hub)
	})

	srv := &http.Server{Addr: addr, Handler: mux}
	return srv.ListenAndServe()
}

// IsVisitorAction 。
func IsVisitorAction(action string) bool {
	return strings.HasPrefix(action, "visitor.")
}

var connSeq atomic.Uint64

func serveWS(w http.ResponseWriter, r *http.Request, reg *ActionRegistry, d *deps.Deps, hub *Hub) {
	c, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		slog.Error("ws upgrade", "err", err)
		return
	}
	defer c.Close()

	fd := int(connSeq.Add(1))
	hub.Register(fd, c)

	locks := make(map[int]*lockStore)
	ctx := context.Background()

	rb := make([]byte, 8)
	_, _ = rand.Read(rb)
	bindKey := fmt.Sprintf("visitor_%d_%d_%s", fd, time.Now().Unix(), hex.EncodeToString(rb))
	open := SuccessResp(map[string]any{"bind_key": bindKey}, "connected successfully", "")
	_ = c.WriteMessage(websocket.TextMessage, open.JSON())

	var userID any = nil
	clientIP := clientIPFromRequest(r)
	ua := r.UserAgent()
	var rdb *redis.Client
	if d != nil {
		rdb = d.RDB
	}

	defer func() {
		hub.Unregister(fd)
		if rdb != nil {
			_ = rdb.Del(ctx, redisKeyLockFd+strconv.Itoa(fd)).Err()
		}
		last := wsRemoveConnection(ctx, rdb, locks, fd)
		if last != "" {
			reg.RunZeroConnHooks(ctx, d, hub, last)
		}
	}()

	for {
		_, message, err := c.ReadMessage()
		if err != nil {
			return
		}
		var params struct {
			Action string         `json:"action"`
			Data   map[string]any `json:"data"`
			OpID   string         `json:"op_id"`
		}
		if err := json.Unmarshal(message, &params); err != nil {
			_ = c.WriteMessage(websocket.TextMessage, ErrorResp("Invalid JSON format", "").JSON())
			continue
		}
		if params.Data == nil {
			params.Data = map[string]any{}
		}

		switch params.Action {
		case "ping", "heartbeat":
			wsUpdatePing(ctx, rdb, fd)
			continue
		case "login":
			tokenStr, _ := params.Data["token"].(string)
			tokenStr = strings.TrimSpace(tokenStr)
			var uid int64
			var perr error
			if d != nil {
				if d.JWT != nil {
					_, uid, perr = d.JWT.ParseAccess(tokenStr)
				}
				if perr != nil && d.JWTAPI != nil {
					_, uid, perr = d.JWTAPI.ParseAccess(tokenStr)
				}
			}
			if tokenStr == "" || perr != nil || uid == 0 {
				_ = c.WriteMessage(websocket.TextMessage, ErrorResp("Failed to parse token", params.OpID).JSON())
				//
				go func(conn *websocket.Conn) {
					time.Sleep(3 * time.Second)
					_ = conn.Close()
				}(c)
				return
			}
			oldClose, ok := wsAddConnection(ctx, rdb, locks, fd, strconv.FormatInt(uid, 10), clientIP, ua, "unknown")
			if !ok {
				_ = c.WriteMessage(websocket.TextMessage, ErrorResp("Failed to bind connection", params.OpID).JSON())
				continue
			}
			if oldClose != "" {
				reg.RunZeroConnHooks(ctx, d, hub, oldClose)
			}
			userID = uid
			_ = c.WriteMessage(websocket.TextMessage, SuccessResp(map[string]any{}, "Auth successfully", params.OpID).JSON())
			continue
		case "visitor.bind_fd":
			bk, _ := params.Data["bind_key"].(string)
			bk = strings.TrimSpace(bk)
			var resp Response
			if bk == "" {
				resp = ErrorResp("bind_key is required and must be a non-empty string", params.OpID)
			} else {
				oldClose, ok := wsAddConnection(ctx, rdb, locks, fd, bk, clientIP, ua, "unknown")
				if !ok {
					resp = ErrorResp("Failed to bind connection", params.OpID)
				} else {
					if oldClose != "" {
						reg.RunZeroConnHooks(ctx, d, hub, oldClose)
					}
					userID = bk
					resp = SuccessResp(map[string]any{}, "Bind key successfully", params.OpID)
				}
			}
			_ = c.WriteMessage(websocket.TextMessage, resp.JSON())
			continue
		}

		opID := params.OpID
		action := params.Action
		isVisitor := IsVisitorAction(action)

		if !isVisitor {
			uid, ok := authNumericUserID(ctx, rdb, fd, userID)
			if !ok {
				_ = c.WriteMessage(websocket.TextMessage, ErrorResp("Please login first", opID).JSON())
				continue
			}
			userID = uid
		}

		fn, ok := reg.Get(action, isVisitor)
		if !ok {
			_ = c.WriteMessage(websocket.TextMessage, ErrorResp("Unknown action or handler not found", opID).JSON())
			continue
		}
		resp := fn(ctx, fd, opID, params.Data, userID, isVisitor, d, hub)
		resp = resp.WithOpID(opID)
		_ = c.WriteMessage(websocket.TextMessage, resp.JSON())
	}
}

func authNumericUserID(ctx context.Context, rdb *redis.Client, fd int, cached any) (int64, bool) {
	if uid, ok := cached.(int64); ok && uid > 0 {
		return uid, true
	}
	if rdb == nil {
		return 0, false
	}
	fdStr := strconv.Itoa(fd)
	val, err := rdb.Get(ctx, redisKeyFdUser+fdStr).Result()
	if err != nil || val == "" {
		return 0, false
	}
	id, err := strconv.ParseInt(val, 10, 64)
	if err != nil || id <= 0 {
		return 0, false
	}
	return id, true
}

func clientIPFromRequest(r *http.Request) string {
	if r == nil {
		return ""
	}
	if xff := r.Header.Get("X-Forwarded-For"); xff != "" {
		parts := strings.Split(xff, ",")
		return strings.TrimSpace(parts[0])
	}
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	return host
}
