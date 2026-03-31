package cli

import (
	"encoding/json"
	"fmt"
	"io"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/spf13/cobra"

	tools "fastapp/internal/app/common"
	"fastapp/internal/config"
	"fastapp/internal/store"
	"fastapp/plugin"
)

func newPluginCmd() *cobra.Command {
	c := &cobra.Command{
		Use:   "plugin",
		Short: "插件安装、卸载、列表、同步 admin、脚本发布",
	}
	c.AddCommand(cmdPluginInstall())
	c.AddCommand(cmdPluginUninstall())
	c.AddCommand(cmdPluginList())
	c.AddCommand(cmdPluginCreate())
	c.AddCommand(cmdPluginSyncAdmin())
	c.AddCommand(cmdPluginScript())
	return c
}

const installLock = "install.lock"

var (
	rePluginConfigDescription = regexp.MustCompile(`(?m)Description\s*=\s*"([^"]*)"`)
	rePluginConfigAuth        = regexp.MustCompile(`(?m)Auth\s*=\s*"([^"]*)"`)
)

func parsePluginRootConfigGo(configPath string) (description, auth string) {
	b, err := os.ReadFile(configPath)
	if err != nil {
		return "", ""
	}
	s := string(b)
	if m := rePluginConfigDescription.FindStringSubmatch(s); len(m) > 1 {
		description = m[1]
	}
	if m := rePluginConfigAuth.FindStringSubmatch(s); len(m) > 1 {
		auth = m[1]
	}
	return description, auth
}

func cmdPluginInstall() *cobra.Command {
	var yes bool
	cmd := &cobra.Command{
		Use:   "install [path]",
		Short: "安装插件：执行 database/migrations 与 database/seeders，再写入 install.lock",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			rel := strings.Trim(args[0], `/\`)
			if err := plugin.ValidateOrgPluginPath(rel); err != nil {
				return err
			}
			root := RootDir()
			dir := tools.PluginPath(root, rel)
			regPath := filepath.Join(dir, plugin.RootConfigFileName)
			if _, err := os.Stat(regPath); err != nil {
				return fmt.Errorf("%s 不存在: %s", plugin.RootConfigFileName, regPath)
			}
			lockPath := filepath.Join(dir, installLock)
			if _, err := os.Stat(lockPath); err == nil {
				return fmt.Errorf("已安装（存在 %s）", lockPath)
			}
			if !yes {
				fmt.Fprintf(cmd.OutOrStdout(), "将安装插件目录: %s\n按回车继续或 Ctrl+C 取消...\n", rel)
				_, _ = fmt.Scanln()
			}
			cfg := config.Load()
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库")
			}
			dbRoot := filepath.Join(dir, "database")
			fmt.Fprintf(cmd.OutOrStdout(), "插件数据库（DB_PREFIX=%q）migrations → seeders …\n", cfg.DBPrefix)
			if err := RunDatabaseMigrationsThenSeeders(db, dbRoot, cfg, cmd.OutOrStdout()); err != nil {
				return err
			}
			if err := os.WriteFile(lockPath, []byte{'1'}, 0o644); err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "已写入 %s\n", lockPath)
			return nil
		},
	}
	cmd.Flags().BoolVarP(&yes, "yes", "y", false, "跳过确认")
	return cmd
}

func cmdPluginUninstall() *cobra.Command {
	var yes bool
	cmd := &cobra.Command{
		Use:   "uninstall [path]",
		Short: "卸载插件：按 database/migrations 解析的表逆序 DROP，再删除 install.lock",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			rel := strings.Trim(args[0], `/\`)
			if err := plugin.ValidateOrgPluginPath(rel); err != nil {
				return err
			}
			root := RootDir()
			dir := tools.PluginPath(root, rel)
			lockPath := filepath.Join(dir, installLock)
			if _, err := os.Stat(lockPath); err != nil {
				if os.IsNotExist(err) {
					return fmt.Errorf("未安装（无 %s）", lockPath)
				}
				return err
			}
			if !yes {
				fmt.Fprintf(cmd.OutOrStdout(), "将卸载插件: %s（将根据 migrations 解析删表）\n按回车继续或 Ctrl+C 取消...\n", rel)
				_, _ = fmt.Scanln()
			}
			cfg := config.Load()
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库")
			}
			dbRoot := filepath.Join(dir, "database")
			fmt.Fprintf(cmd.OutOrStdout(), "插件数据库卸载（DB_PREFIX=%q）…\n", cfg.DBPrefix)
			if err := RunDatabaseUninstallSQL(db, dbRoot, cfg, rel, cmd.OutOrStdout()); err != nil {
				return err
			}
			if err := os.Remove(lockPath); err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "已移除 %s\n", lockPath)
			return nil
		},
	}
	cmd.Flags().BoolVarP(&yes, "yes", "y", false, "跳过确认")
	return cmd
}

func cmdPluginList() *cobra.Command {
	return &cobra.Command{
		Use:   "list",
		Short: "列出 plugin 下含 config.go 的 组织/插件 及安装状态",
		RunE: func(cmd *cobra.Command, args []string) error {
			root := tools.PluginRoot(RootDir())
			if _, err := os.Stat(root); os.IsNotExist(err) {
				fmt.Fprintln(cmd.OutOrStdout(), "(无 plugin 目录)")
				return nil
			}
			var rows [][]string
			_ = filepath.WalkDir(root, func(path string, d fs.DirEntry, err error) error {
				if err != nil || d.IsDir() {
					return nil
				}
				if d.Name() != plugin.RootConfigFileName {
					return nil
				}
				dir := filepath.Dir(path)
				rel, _ := filepath.Rel(root, dir)
				if err := plugin.ValidateOrgPluginPath(rel); err != nil {
					return nil
				}
				rel = filepath.ToSlash(rel)
				desc, auth := parsePluginRootConfigGo(path)
				if desc == "" {
					desc = "--"
				}
				author := auth
				if author == "" {
					author = "--"
				}
				st := "uninstalled"
				if _, err := os.Stat(filepath.Join(dir, installLock)); err == nil {
					st = "installed"
				}
				rows = append(rows, []string{rel, desc, author, st, rel})
				return nil
			})
			fmt.Fprintf(cmd.OutOrStdout(), "%-20s %-30s %-35s %-12s %s\n", "name", "description", "author", "status", "path")
			for _, r := range rows {
				fmt.Fprintf(cmd.OutOrStdout(), "%-20s %-30s %-35s %-12s %s\n", r[0], r[1], r[2], r[3], r[4])
			}
			return nil
		},
	}
}

func cmdPluginCreate() *cobra.Command {
	var name, desc, author, typ string
	cmd := &cobra.Command{
		Use:   "create [path]",
		Short: "创建插件目录骨架与根目录 config.go（path 如 ds/myPlugin，不含 plugin 前缀）",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			rel := strings.Trim(args[0], `/\`)
			rel = filepath.ToSlash(rel)
			if err := plugin.ValidateOrgPluginPath(rel); err != nil {
				return err
			}
			base := tools.PluginPath(RootDir(), rel)
			if _, err := os.Stat(base); err == nil {
				return fmt.Errorf("目录已存在: %s", base)
			}
			dirs := []string{
				base,
				filepath.Join(base, "src"),
				filepath.Join(base, "src", "http"),
				filepath.Join(base, "src", "model"),
				filepath.Join(base, "src", "websocket"),
				filepath.Join(base, "web"),
				filepath.Join(base, "database", "migrations"), filepath.Join(base, "database", "seeders"),
			}
			for _, d := range dirs {
				if err := os.MkdirAll(d, 0o755); err != nil {
					return err
				}
			}
			pName := strings.TrimSpace(name)
			if pName == "" {
				pName = rel
			}
			typVal := typ
			if typVal == "" {
				typVal = "mixed"
			}
			pkgIdent := "plug_" + strings.ReplaceAll(strings.ReplaceAll(rel, "/", "_"), "-", "_")
			regBody := fmt.Sprintf(`package %s

const (
	PluginName  = %q
	Version     = "1.0.0"
	Description = %q
	PluginType  = %q
)
`, pkgIdent, pName, desc, typVal)
			regPath := filepath.Join(base, plugin.RootConfigFileName)
			if err := os.WriteFile(regPath, []byte(regBody), 0o644); err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "已创建 %s\n", regPath)
			return nil
		},
	}
	cmd.Flags().StringVar(&name, "name", "", "PluginName 常量（默认与 path 一致）")
	cmd.Flags().StringVar(&desc, "description", "sample plugin", "描述")
	cmd.Flags().StringVar(&author, "author", "", "作者")
	cmd.Flags().StringVar(&typ, "type", "mixed", "类型 mixed|backend|frontend")
	return cmd
}

func cmdPluginSyncAdmin() *cobra.Command {
	var all bool
	cmd := &cobra.Command{
		Use:   "sync-admin [path]",
		Short: "将插件 web/ 同步到 admin/src/plugins/<组织>/<插件>/（默认上级 admin/）",
		RunE: func(cmd *cobra.Command, args []string) error {
			rdir := RootDir()
			adminDir := tools.SiblingAdminDir(rdir)
			if all {
				return syncAllWeb(rdir, adminDir, cmd.OutOrStdout())
			}
			if len(args) != 1 {
				return fmt.Errorf("请指定 path 或使用 --all")
			}
			rel := strings.Trim(args[0], `/\`)
			if err := plugin.ValidateOrgPluginPath(rel); err != nil {
				return err
			}
			n, err := copyPluginWeb(tools.PluginPath(rdir, rel), adminDir)
			if err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "已同步 %s，共 %d 个文件\n", rel, n)
			return nil
		},
	}
	cmd.Flags().BoolVarP(&all, "all", "a", false, "同步所有已安装且含 web 的插件")
	return cmd
}

func syncAllWeb(serverRoot, adminDir string, out io.Writer) error {
	pluginRoot := tools.PluginRoot(serverRoot)
	var total int
	_ = filepath.WalkDir(pluginRoot, func(path string, d fs.DirEntry, err error) error {
		if err != nil || !d.IsDir() {
			return nil
		}
		if filepath.Base(path) != "web" {
			return nil
		}
		pluginDir := filepath.Dir(path)
		if _, err := os.Stat(filepath.Join(pluginDir, installLock)); err != nil {
			return nil
		}
		relPlug, _ := filepath.Rel(pluginRoot, pluginDir)
		if err := plugin.ValidateOrgPluginPath(relPlug); err != nil {
			return nil
		}
		n, err := copyPluginWeb(pluginDir, adminDir)
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(pluginRoot, pluginDir)
		fmt.Fprintf(out, "%s: %d files\n", rel, n)
		total += n
		return filepath.SkipDir
	})
	if total == 0 {
		fmt.Fprintln(out, "没有已安装且含 web 目录的插件需要同步")
	}
	return nil
}

// copyPluginWeb 将 plugin/<组织>/<插件>/web/** 拷到 admin/src/plugins/<组织>/<插件>/**。
func copyPluginWeb(pluginDir, adminDir string) (int, error) {
	web := filepath.Join(pluginDir, "web")
	st, err := os.Stat(web)
	if err != nil || !st.IsDir() {
		return 0, nil
	}
	pluginRepoRoot := filepath.Clean(filepath.Join(pluginDir, "..", ".."))
	relPlug, err := filepath.Rel(pluginRepoRoot, filepath.Clean(pluginDir))
	if err != nil {
		return 0, err
	}
	destRoot := filepath.Join(adminDir, "src", "plugins", filepath.ToSlash(relPlug))
	var count int
	err = filepath.WalkDir(web, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(web, path)
		if err != nil {
			return err
		}
		if d.IsDir() {
			return os.MkdirAll(filepath.Join(destRoot, rel), 0o755)
		}
		b, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		target := filepath.Join(destRoot, rel)
		if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
			return err
		}
		if err := os.WriteFile(target, b, 0o644); err != nil {
			return err
		}
		count++
		return nil
	})
	return count, err
}

func copyDirAll(src, dst string) error {
	return filepath.WalkDir(src, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		rel, err := filepath.Rel(src, path)
		if err != nil {
			return err
		}
		target := filepath.Join(dst, rel)
		if d.IsDir() {
			return os.MkdirAll(target, 0o755)
		}
		b, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		if err := os.MkdirAll(filepath.Dir(target), 0o755); err != nil {
			return err
		}
		return os.WriteFile(target, b, 0o644)
	})
}

func cmdPluginScript() *cobra.Command {
	var show bool
	var id string
	var force bool
	cmd := &cobra.Command{
		Use:   "script [path]",
		Short: "发布插件 publish 资源（读取插件根目录 publish.json 顶层 publish 数组并拷贝文件）",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			rel := strings.Trim(args[0], `/\`)
			if err := plugin.ValidateOrgPluginPath(rel); err != nil {
				return err
			}
			cfgPath := filepath.Join(tools.PluginPath(RootDir(), rel), "publish.json")
			b, err := os.ReadFile(cfgPath)
			if err != nil {
				return err
			}
			var m struct {
				Publish []map[string]string `json:"publish"`
			}
			if err := json.Unmarshal(b, &m); err != nil {
				return err
			}
			if len(m.Publish) == 0 {
				fmt.Fprintln(cmd.OutOrStdout(), "无 publish 配置")
				return nil
			}
			if show {
				for _, item := range m.Publish {
					fmt.Fprintf(cmd.OutOrStdout(), "%+v\n", item)
				}
				return nil
			}
			pRoot := tools.PluginPath(RootDir(), rel)
			for _, item := range m.Publish {
				pid := item["id"]
				srcRel := item["source"]
				dstPath := item["destination"]
				if srcRel == "" || dstPath == "" {
					continue
				}
				if id != "" && pid != id {
					continue
				}
				src := filepath.Join(pRoot, srcRel)
				dst := dstPath
				if !filepath.IsAbs(dst) {
					dst = tools.RootJoin(RootDir(), dst)
				}
				if _, err := os.Stat(src); err != nil {
					fmt.Fprintf(cmd.OutOrStdout(), "[%s] skip missing source: %s\n", pid, src)
					continue
				}
				if !force {
					if _, err := os.Stat(dst); err == nil {
						fmt.Fprintf(cmd.OutOrStdout(), "[%s] exists: %s (use -f)\n", pid, dst)
						continue
					}
				}
				st, err := os.Stat(src)
				if err != nil {
					continue
				}
				if st.IsDir() {
					if err := copyDirAll(src, dst); err != nil {
						return err
					}
				} else {
					if err := os.MkdirAll(filepath.Dir(dst), 0o755); err != nil {
						return err
					}
					b, err := os.ReadFile(src)
					if err != nil {
						return err
					}
					if err := os.WriteFile(dst, b, 0o644); err != nil {
						return err
					}
				}
				fmt.Fprintf(cmd.OutOrStdout(), "[%s] published -> %s\n", pid, dst)
			}
			return nil
		},
	}
	cmd.Flags().BoolVarP(&show, "show", "s", false, "仅列出 publish 项")
	cmd.Flags().StringVarP(&id, "id", "i", "", "指定 publish id")
	cmd.Flags().BoolVarP(&force, "force", "f", false, "覆盖已存在文件")
	return cmd
}
