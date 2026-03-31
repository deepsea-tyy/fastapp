package main

import (
	"fmt"
	"log/slog"
	"net/http"
	"os"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/i18n"
	"fastapp/internal/app/model"
	"fastapp/internal/app/router"
	"fastapp/internal/config"
	"fastapp/internal/store"
	"fastapp/internal/websocket"
	"fastapp/plugin"

	"github.com/redis/go-redis/v9"
)

func main() {
	root, err := tools.ResolveServerGoRoot()
	if err != nil {
		slog.Error("server_go root", "err", err)
		os.Exit(1)
	}
	_ = tools.LoadDotEnvForServerRoot(root)
	i18n.Init(tools.StorageLocalesDir(root))
	cfg := config.Load()

	uploadDir := tools.StorageUploadsDir(root)
	if err := os.MkdirAll(uploadDir, 0o755); err != nil {
		slog.Error("mkdir uploads", "path", uploadDir, "err", err)
		os.Exit(1)
	}

	model.P = cfg.DBPrefix

	loaded, err := plugin.LoadInstalled(root)
	if err != nil {
		slog.Error("load plugins", "err", err)
		os.Exit(1)
	}
	slog.Info("plugins loaded", "count", len(loaded), "root", root)

	if err := plugin.LoadPluginI18n(root); err != nil {
		slog.Error("plugin i18n", "err", err)
		os.Exit(1)
	}

	db, err := store.OpenMySQL(cfg)
	if err != nil {
		slog.Error("mysql", "err", err)
		os.Exit(1)
	}

	var rdb = tryRedis(cfg)

	var jwtAdmin, jwtAPI deps.JWTProvider
	if j, err := tools.NewService(cfg, tools.SceneAdmin, rdb); err != nil {
		slog.Warn("jwt admin disabled", "err", err)
	} else {
		jwtAdmin = j
	}
	if j, err := tools.NewService(cfg, tools.SceneAPI, rdb); err != nil {
		slog.Warn("jwt api disabled", "err", err)
	} else {
		jwtAPI = j
	}

	wsHub := websocket.NewHub()

	var d *deps.Deps
	if db != nil {
		d = &deps.Deps{
			Config:    cfg,
			DB:        db,
			RDB:       rdb,
			JWT:       jwtAdmin,
			JWTAPI:    jwtAPI,
			UploadDir: uploadDir,
			WSHub:     wsHub,
		}
	}

	var plug []router.Endpoint
	if d != nil {
		plug = plugin.HTTPEndpoints(loaded)
	}
	engine := router.New(router.Config{Deps: d, PluginEndpoints: plug})

	addr := fmt.Sprintf(":%d", cfg.HTTPPort)
	go func() {
		slog.Info("http listening", "addr", addr)
		if err := http.ListenAndServe(addr, engine); err != nil {
			slog.Error("http server", "err", err)
			os.Exit(1)
		}
	}()

	wsReg := plugin.BindingWS(loaded)

	wsAddr := fmt.Sprintf(":%d", cfg.WSPort)
	slog.Info("websocket listening", "addr", wsAddr)
	if err := websocket.ListenAndServe(wsAddr, d, wsHub, wsReg); err != nil {
		slog.Error("websocket server", "err", err)
		os.Exit(1)
	}
}

func tryRedis(cfg config.Config) *redis.Client {
	rdb, err := store.OpenRedis(cfg)
	if err != nil {
		slog.Warn("redis disabled", "err", err)
		return nil
	}
	return rdb
}
