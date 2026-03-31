package plugin

import (
	"fmt"
	"sync"

	"fastapp/internal/app/router"
	"fastapp/internal/websocket"
)

var (
	regMu        sync.RWMutex
	httpBuilt    = map[string]func() []router.Endpoint{}
	wsRegisterFn = map[string]func(*websocket.ActionRegistry){}
)

// RegisterHTTPEndpoints 在 plugin 包 init 中调用（name 与目录路径一致，如 ds/sysConfig）。
func RegisterHTTPEndpoints(name string, fn func() []router.Endpoint) {
	if name == "" || fn == nil {
		panic("plugin: RegisterHTTPEndpoints: name and fn required")
	}
	regMu.Lock()
	defer regMu.Unlock()
	if _, dup := httpBuilt[name]; dup {
		panic(fmt.Sprintf("plugin: duplicate RegisterHTTPEndpoints for %q", name))
	}
	httpBuilt[name] = fn
}

// RegisterWebSocket 在 plugin 包 init 中调用。
func RegisterWebSocket(name string, fn func(*websocket.ActionRegistry)) {
	if name == "" || fn == nil {
		panic("plugin: RegisterWebSocket: name and fn required")
	}
	regMu.Lock()
	defer regMu.Unlock()
	if _, dup := wsRegisterFn[name]; dup {
		panic(fmt.Sprintf("plugin: duplicate RegisterWebSocket for %q", name))
	}
	wsRegisterFn[name] = fn
}

func mergeHTTPEndpoints(pluginNames []string) []router.Endpoint {
	var out []router.Endpoint
	for _, name := range pluginNames {
		regMu.RLock()
		fn, ok := httpBuilt[name]
		regMu.RUnlock()
		if !ok {
			continue
		}
		out = append(out, fn()...)
	}
	return out
}

func buildBindingWS(pluginNames []string) *websocket.ActionRegistry {
	r := websocket.NewRegistry()
	for _, name := range pluginNames {
		regMu.RLock()
		fn, ok := wsRegisterFn[name]
		regMu.RUnlock()
		if !ok {
			continue
		}
		fn(r)
	}
	return r
}
