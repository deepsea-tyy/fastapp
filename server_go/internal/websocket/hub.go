package websocket

import (
	"context"
	"log/slog"
	"strconv"
	"sync"

	"github.com/gorilla/websocket"
	"github.com/redis/go-redis/v9"
)

// Hub 进程内 fd → 连接，用于向在线客户端推送（与 Redis ws:user:fds 对齐）。
type Hub struct {
	mu    sync.RWMutex
	conns map[int]*connEntry
}

type connEntry struct {
	c   *websocket.Conn
	wmu sync.Mutex
}

func NewHub() *Hub {
	return &Hub{conns: make(map[int]*connEntry)}
}

func (h *Hub) Register(fd int, c *websocket.Conn) {
	if h == nil || c == nil {
		return
	}
	h.mu.Lock()
	defer h.mu.Unlock()
	h.conns[fd] = &connEntry{c: c}
}

func (h *Hub) Unregister(fd int) {
	if h == nil {
		return
	}
	h.mu.Lock()
	defer h.mu.Unlock()
	delete(h.conns, fd)
}

// PushToUsers 实现 deps.WebSocketHub：按用户/访客标识解析 fd 并推送 JSON。
func (h *Hub) PushToUsers(ctx context.Context, rdb *redis.Client, userKeys []string, data map[string]any, event string) {
	if h == nil || rdb == nil || len(userKeys) == 0 {
		return
	}
	//
	merged := make(map[string]any, len(data)+1)
	if event != "" {
		merged["event"] = event
	}
	for k, v := range data {
		merged[k] = v
	}

	payload := SuccessResp(merged, "push", "").JSON()

	fdSeen := make(map[int]struct{})
	for _, uid := range userKeys {
		if uid == "" {
			continue
		}
		members, err := rdb.SMembers(ctx, redisKeyUserFdsPrefix+uid).Result()
		if err != nil {
			slog.Debug("ws push smembers", "err", err, "key", uid)
			continue
		}
		for _, fs := range members {
			fd, err := strconv.Atoi(fs)
			if err != nil || fd <= 0 {
				continue
			}
			if _, ok := fdSeen[fd]; ok {
				continue
			}
			fdSeen[fd] = struct{}{}
			h.writeFD(fd, payload)
		}
	}
}

func (h *Hub) writeFD(fd int, msg []byte) {
	h.mu.RLock()
	e, ok := h.conns[fd]
	h.mu.RUnlock()
	if !ok || e == nil {
		return
	}
	e.wmu.Lock()
	defer e.wmu.Unlock()
	if err := e.c.WriteMessage(websocket.TextMessage, msg); err != nil {
		slog.Debug("ws push write", "fd", fd, "err", err)
	}
}

// PushRawToUsers 将已是 JSON 对象的内容直接包进 success/data 推送（无额外 event 字段）。
func (h *Hub) PushRawToUsers(ctx context.Context, rdb *redis.Client, userKeys []string, data map[string]any) {
	h.PushToUsers(ctx, rdb, userKeys, data, "")
}
