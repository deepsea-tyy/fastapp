package cli

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"strings"

	"fastapp/internal/config"
	"fastapp/internal/store"
	"fastapp/internal/websocket"

	"github.com/spf13/cobra"
)

func newWsCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "ws",
		Short: "WebSocket Redis 连接统计与运维",
	}
	cmd.AddCommand(&cobra.Command{
		Use:   "stats",
		Short: "输出当前连接统计（total_connections、unique_users、visitor_connections）",
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			rdb, err := store.OpenRedis(cfg)
			if err != nil {
				return err
			}
			ctx := context.Background()
			s, err := websocket.GetConnectionStats(ctx, rdb)
			if err != nil {
				return err
			}
			enc := json.NewEncoder(os.Stdout)
			enc.SetIndent("", "  ")
			return enc.Encode(s)
		},
	})
	cmd.AddCommand(&cobra.Command{
		Use:   "fix-stats",
		Short: "将 ws:stats:total 修复为 ws:connections:info 长度",
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			rdb, err := store.OpenRedis(cfg)
			if err != nil {
				return err
			}
			ctx := context.Background()
			r, err := websocket.FixConnectionStats(ctx, rdb)
			if err != nil {
				return err
			}
			enc := json.NewEncoder(os.Stdout)
			enc.SetIndent("", "  ")
			return enc.Encode(r)
		},
	})
	listCmd := &cobra.Command{
		Use:   "list",
		Short: "分页列出连接详情（JSON）",
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			rdb, err := store.OpenRedis(cfg)
			if err != nil {
				return err
			}
			page, _ := cmd.Flags().GetInt("page")
			size, _ := cmd.Flags().GetInt("page-size")
			user, _ := cmd.Flags().GetString("user")
			var uid *string
			if strings.TrimSpace(user) != "" {
				u := strings.TrimSpace(user)
				uid = &u
			}
			ctx := context.Background()
			res, err := websocket.GetConnectionsList(ctx, rdb, uid, page, size)
			if err != nil {
				return err
			}
			enc := json.NewEncoder(os.Stdout)
			enc.SetIndent("", "  ")
			return enc.Encode(res)
		},
	}
	listCmd.Flags().Int("page", 1, "页码")
	listCmd.Flags().Int("page-size", 20, "每页条数")
	listCmd.Flags().String("user", "", "仅该用户 ID 或访客 bind_key")
	cmd.AddCommand(listCmd)

	clearCmd := &cobra.Command{
		Use:   "clear",
		Short: "删除所有 WS 相关 Redis 键（危险操作）",
		RunE: func(cmd *cobra.Command, args []string) error {
			yes, _ := cmd.Flags().GetBool("yes")
			if !yes {
				return fmt.Errorf("必须加 --yes 确认")
			}
			cfg := config.Load()
			rdb, err := store.OpenRedis(cfg)
			if err != nil {
				return err
			}
			ctx := context.Background()
			res := websocket.ClearAllConnections(ctx, rdb, 100)
			enc := json.NewEncoder(os.Stdout)
			enc.SetIndent("", "  ")
			if err := enc.Encode(res); err != nil {
				return err
			}
			if res.Error != "" {
				return fmt.Errorf("%s", res.Error)
			}
			return nil
		},
	}
	clearCmd.Flags().Bool("yes", false, "确认执行")
	cmd.AddCommand(clearCmd)

	cmd.AddCommand(&cobra.Command{
		Use:   "online",
		Short: "批量查询用户是否在线（逗号分隔数字 ID）",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			rdb, err := store.OpenRedis(cfg)
			if err != nil {
				return err
			}
			var ids []int64
			for _, p := range strings.Split(args[0], ",") {
				p = strings.TrimSpace(p)
				if p == "" {
					continue
				}
				n, err := strconv.ParseInt(p, 10, 64)
				if err != nil {
					return fmt.Errorf("invalid id %q", p)
				}
				ids = append(ids, n)
			}
			ctx := context.Background()
			m := websocket.GetBatchUserOnlineStatus(ctx, rdb, ids)
			enc := json.NewEncoder(os.Stdout)
			enc.SetIndent("", "  ")
			return enc.Encode(m)
		},
	})

	return cmd
}
