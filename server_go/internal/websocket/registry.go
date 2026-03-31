package websocket

import (
	"context"
	"sync"

	"fastapp/internal/app/common/deps"
)

// ActionFunc 处理除 login / visitor.bind_fd / ping 外的业务 action。
type ActionFunc func(ctx context.Context, fd int, opID string, data map[string]any, userID any, isVisitor bool, d *deps.Deps, hub *Hub) Response

// ZeroConnHook 当某 Redis 用户键在所有 fd 上已无连接时触发（如换绑释放旧用户、连接关闭），供插件做清理/推送。
type ZeroConnHook func(ctx context.Context, d *deps.Deps, hub *Hub, redisUserKey string)

// ActionRegistry 插件注册 WS action，
type ActionRegistry struct {
	mu        sync.RWMutex
	actions   map[string]ActionFunc
	visitor   map[string]ActionFunc
	zeroHooks []ZeroConnHook
}

func NewRegistry() *ActionRegistry {
	return &ActionRegistry{
		actions: make(map[string]ActionFunc),
		visitor: make(map[string]ActionFunc),
	}
}

func (r *ActionRegistry) Register(action string, fn ActionFunc) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.actions[action] = fn
}

func (r *ActionRegistry) RegisterVisitor(action string, fn ActionFunc) {
	r.mu.Lock()
	defer r.mu.Unlock()
	r.visitor[action] = fn
}

func (r *ActionRegistry) Get(action string, visitor bool) (ActionFunc, bool) {
	r.mu.RLock()
	defer r.mu.RUnlock()
	if visitor {
		fn, ok := r.visitor[action]
		return fn, ok
	}
	fn, ok := r.actions[action]
	return fn, ok
}

func (r *ActionRegistry) AddZeroConnHook(h ZeroConnHook) {
	if h == nil {
		return
	}
	r.mu.Lock()
	defer r.mu.Unlock()
	r.zeroHooks = append(r.zeroHooks, h)
}

func (r *ActionRegistry) RunZeroConnHooks(ctx context.Context, d *deps.Deps, hub *Hub, redisUserKey string) {
	if redisUserKey == "" {
		return
	}
	r.mu.RLock()
	hooks := append([]ZeroConnHook(nil), r.zeroHooks...)
	r.mu.RUnlock()
	for _, h := range hooks {
		h(ctx, d, hub, redisUserKey)
	}
}
