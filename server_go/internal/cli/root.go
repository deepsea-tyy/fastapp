package cli

import (
	"fmt"
	"os"

	tools "fastapp/internal/app/common"

	"github.com/spf13/cobra"
)

// Execute 解析根命令（plugin / gen）
func Execute() error {
	root := &cobra.Command{
		Use:   "fastapp-cli",
		Short: "FastApp server_go 插件、核心库迁移、代码生成与 WebSocket 运维 CLI",
		PersistentPreRun: func(cmd *cobra.Command, args []string) {
			r, err := tools.ResolveServerGoRoot()
			if err != nil {
				fmt.Fprintln(os.Stderr, "server_go root:", err)
				os.Exit(1)
			}
			_ = tools.LoadDotEnvForServerRoot(r)
		},
	}
	root.AddCommand(newPluginCmd())
	root.AddCommand(newMigrateCmd())
	root.AddCommand(newGenCmd())
	root.AddCommand(newWsCmd())
	return root.Execute()
}

// RootDir 供子命令使用（需在 PersistentPreRun 之后调用；此处每次解析 env）
func RootDir() string {
	r, err := tools.ResolveServerGoRoot()
	if err != nil {
		fmt.Fprintln(os.Stderr, "server_go root:", err)
		os.Exit(1)
	}
	return r
}
