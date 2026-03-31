package ws

import (
	"context"

	"fastapp/internal/app/common/deps"
	appws "fastapp/internal/websocket"
)

// RegisterWebSocket 注册本插件全部 WS action（实现均在同包 handlers，此处仅用闭包转发）。
// 宿主 fastapp/plugin/plugin.go init 中 RegisterWebSocket(syskefu.PluginName, ws.RegisterWebSocket)。
func RegisterWebSocket(reg *appws.ActionRegistry) {
	reg.Register("kefu_message_send", func(ctx context.Context, _ int, opID string, data map[string]any, userID any, _ bool, d *deps.Deps, hub *appws.Hub) appws.Response {
		uid, _ := userID.(int64)
		return handleKefuMessageSend(ctx, d, hub, opID, data, uid)
	})
	reg.Register("kefu_message_read", func(ctx context.Context, _ int, opID string, data map[string]any, userID any, _ bool, d *deps.Deps, hub *appws.Hub) appws.Response {
		uid, _ := userID.(int64)
		return handleKefuMessageRead(ctx, d, hub, opID, data, uid)
	})
	reg.Register("kefu_message_end", func(ctx context.Context, _ int, opID string, data map[string]any, userID any, _ bool, d *deps.Deps, hub *appws.Hub) appws.Response {
		uid, _ := userID.(int64)
		return handleKefuMessageEnd(ctx, d, hub, opID, data, uid)
	})
	reg.RegisterVisitor("visitor.kefu_message_send", func(ctx context.Context, _ int, opID string, data map[string]any, _ any, _ bool, d *deps.Deps, hub *appws.Hub) appws.Response {
		return handleKefuVisitorMessageSend(ctx, d, hub, opID, data)
	})
	reg.RegisterVisitor("visitor.kefu_message_end", func(ctx context.Context, _ int, opID string, data map[string]any, _ any, _ bool, d *deps.Deps, hub *appws.Hub) appws.Response {
		return handleKefuVisitorMessageEnd(ctx, d, hub, opID, data)
	})
	reg.AddZeroConnHook(handleKefuVisitorLastDisconnected)
}
