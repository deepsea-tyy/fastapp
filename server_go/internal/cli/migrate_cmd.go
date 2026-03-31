package cli

import (
	"fmt"
	"io"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/model"
	"fastapp/internal/cli/gen"
	"fastapp/internal/config"
	"fastapp/internal/store"

	"github.com/spf13/cobra"
	"gorm.io/gorm"
)

const sqlPrefixToken = "{{prefix}}"

// 匹配 migrate 里常见写法：CREATE TABLE `name` / CREATE TABLE IF NOT EXISTS `name`
var reCreateTable = regexp.MustCompile("(?i)CREATE\\s+TABLE\\s+(?:IF\\s+NOT\\s+EXISTS\\s+)?`([^`]+)`")

func migrationsDirName() string { return "migrations" }

func seedersDirName() string { return "seeders" }

func ensureDatabaseRoot(databaseRoot string) error {
	databaseRoot = filepath.Clean(databaseRoot)
	st, err := os.Stat(databaseRoot)
	if err != nil {
		return fmt.Errorf("database 根目录无效 %s: %w", databaseRoot, err)
	}
	if !st.IsDir() {
		return fmt.Errorf("不是目录: %s", databaseRoot)
	}
	return nil
}

// RunDatabaseMigrationsOnly 仅执行 databaseRoot 下 migrations 子目录 *.sql。SQL 中 {{prefix}} 替换为 cfg.DBPrefix。
func RunDatabaseMigrationsOnly(db *gorm.DB, databaseRoot string, cfg config.Config, out io.Writer) error {
	databaseRoot = filepath.Clean(databaseRoot)
	if err := ensureDatabaseRoot(databaseRoot); err != nil {
		return err
	}
	sub := migrationsDirName()
	return applySQLSubdir(db, databaseRoot, sub, sub, cfg, out)
}

// RunDatabaseSeedersOnly 仅执行 databaseRoot 下 seeders 子目录 *.sql。SQL 中 {{prefix}} 替换为 cfg.DBPrefix。
func RunDatabaseSeedersOnly(db *gorm.DB, databaseRoot string, cfg config.Config, out io.Writer) error {
	databaseRoot = filepath.Clean(databaseRoot)
	if err := ensureDatabaseRoot(databaseRoot); err != nil {
		return err
	}
	sub := seedersDirName()
	return applySQLSubdir(db, databaseRoot, sub, sub, cfg, out)
}

// RunDatabaseMigrationsThenSeeders 先迁移 *.sql，再种子 *.sql（如 plugin install）。
func RunDatabaseMigrationsThenSeeders(db *gorm.DB, databaseRoot string, cfg config.Config, out io.Writer) error {
	databaseRoot = filepath.Clean(databaseRoot)
	if err := ensureDatabaseRoot(databaseRoot); err != nil {
		return err
	}
	if err := applySQLSubdir(db, databaseRoot, migrationsDirName(), migrationsDirName(), cfg, out); err != nil {
		return err
	}
	return applySQLSubdir(db, databaseRoot, seedersDirName(), seedersDirName(), cfg, out)
}

// pluginMenuNamePrefix 与 plugin uninstall 参数、config.go 的 PluginName、菜单/路由命名共用同一规则：
// 插件相对路径 org/pluginDir（大小写与目录一致）把「/」换成「:」，如 ds/sysCms → ds:sysCms。
// 凡写入 menu.name 的值均须以此字符串为前缀，uninstall 才会 DELETE 干净（见 deletePluginMenusByPrefix）。
func pluginMenuNamePrefix(pluginRel string) string {
	s := strings.Trim(strings.ReplaceAll(pluginRel, `\`, "/"), "/")
	return strings.ReplaceAll(s, "/", ":")
}

// deletePluginMenusByPrefix 先删 role_belongs_menu 再删 menu，条件为 menu.name LIKE prefix||'%'（与 pluginMenuNamePrefix 一致）。
func deletePluginMenusByPrefix(db *gorm.DB, dbPrefix, menuPrefix string, out io.Writer) error {
	if menuPrefix == "" {
		return nil
	}
	like := menuPrefix + "%"
	m := "`" + strings.ReplaceAll(dbPrefix+"menu", "`", "``") + "`"
	rm := "`" + strings.ReplaceAll(dbPrefix+"role_belongs_menu", "`", "``") + "`"
	q1 := "DELETE rm FROM " + rm + " AS rm INNER JOIN " + m + " AS m ON m.id = rm.menu_id WHERE m.name LIKE ?"
	if err := db.Exec(q1, like).Error; err != nil {
		return fmt.Errorf("清理 role_belongs_menu: %w", err)
	}
	q2 := "DELETE FROM " + m + " WHERE name LIKE ?"
	if err := db.Exec(q2, like).Error; err != nil {
		return fmt.Errorf("清理 menu: %w", err)
	}
	if out != nil {
		fmt.Fprintf(out, "已删除菜单 name LIKE %q（前缀 %q）\n", like, menuPrefix)
	}
	return nil
}

// RunDatabaseUninstallSQL 插件卸载：按 pluginRel 推导菜单前缀并删菜单/角色关联，再按 migrations 逆序 DROP 表。
func RunDatabaseUninstallSQL(db *gorm.DB, databaseRoot string, cfg config.Config, pluginRel string, out io.Writer) error {
	databaseRoot = filepath.Clean(databaseRoot)
	if err := ensureDatabaseRoot(databaseRoot); err != nil {
		return err
	}
	prefix := pluginMenuNamePrefix(pluginRel)
	if err := deletePluginMenusByPrefix(db, cfg.DBPrefix, prefix, out); err != nil {
		return err
	}
	return dropTablesFromMigrationFiles(db, databaseRoot, cfg.DBPrefix, out)
}

func tablesCreatedInMigrationsOrder(databaseRoot, dbPrefix string) ([]string, error) {
	migDir := filepath.Join(databaseRoot, migrationsDirName())
	st, err := os.Stat(migDir)
	if err != nil || !st.IsDir() {
		return nil, nil
	}
	files, err := listSortedSQLFiles(migDir)
	if err != nil {
		return nil, err
	}
	var names []string
	seen := make(map[string]struct{})
	for _, fp := range files {
		b, err := os.ReadFile(fp)
		if err != nil {
			return nil, err
		}
		body := substituteDBPrefix(string(b), dbPrefix)
		for _, m := range reCreateTable.FindAllStringSubmatch(body, -1) {
			tn := m[1]
			if _, ok := seen[tn]; ok {
				continue
			}
			seen[tn] = struct{}{}
			names = append(names, tn)
		}
	}
	return names, nil
}

func dropTablesFromMigrationFiles(db *gorm.DB, databaseRoot, dbPrefix string, out io.Writer) error {
	names, err := tablesCreatedInMigrationsOrder(databaseRoot, dbPrefix)
	if err != nil {
		return err
	}
	if len(names) == 0 {
		if out != nil {
			fmt.Fprintf(out, "提示: 迁移目录中未解析到 CREATE TABLE，跳过自动删表。\n")
		}
		return nil
	}
	if out != nil {
		fmt.Fprintf(out, "根据迁移 SQL 逆序 DROP %d 张表（FOREIGN_KEY_CHECKS=0）…\n", len(names))
	}
	if err := db.Exec("SET FOREIGN_KEY_CHECKS = 0").Error; err != nil {
		return fmt.Errorf("FOREIGN_KEY_CHECKS=0: %w", err)
	}
	defer func() {
		_ = db.Exec("SET FOREIGN_KEY_CHECKS = 1").Error
	}()
	for i := len(names) - 1; i >= 0; i-- {
		tn := strings.ReplaceAll(names[i], "`", "``")
		q := "DROP TABLE IF EXISTS `" + tn + "`"
		if err := db.Exec(q).Error; err != nil {
			return fmt.Errorf("%s: %w", q, err)
		}
		if out != nil {
			fmt.Fprintf(out, "  %s\n", q)
		}
	}
	return nil
}

// ResolveDatabaseDir 将用户输入解析为绝对路径：绝对路径直接清洗；否则相对于 serverGoRoot。
func ResolveDatabaseDir(serverGoRoot, userPath string) (string, error) {
	userPath = strings.TrimSpace(strings.Trim(userPath, `/\`))
	if userPath == "" {
		return "", fmt.Errorf("请指定 database 根目录（须含 migrations/、seeders/ 子目录）")
	}
	if filepath.IsAbs(userPath) {
		return filepath.Clean(userPath), nil
	}
	return filepath.Clean(filepath.Join(serverGoRoot, userPath)), nil
}

func substituteDBPrefix(sql string, dbPrefix string) string {
	return strings.ReplaceAll(sql, sqlPrefixToken, dbPrefix)
}

func listSortedSQLFiles(dir string) ([]string, error) {
	matches, err := filepath.Glob(filepath.Join(dir, "*.sql"))
	if err != nil {
		return nil, err
	}
	sort.Strings(matches)
	return matches, nil
}

func applySQLFile(db *gorm.DB, path string, dbPrefix string, out io.Writer) error {
	b, err := os.ReadFile(path)
	if err != nil {
		return err
	}
	body := substituteDBPrefix(string(b), dbPrefix)
	stmts := gen.SplitSQLStatements(body)
	t, ok, nErr, err := gen.ImportSQLStatements(db, stmts, true, false, 500, nil)
	if err != nil {
		return fmt.Errorf("%s: %w", filepath.Base(path), err)
	}
	if out != nil {
		fmt.Fprintf(out, "  %s: 语句 %d，成功 %d，失败 %d\n", filepath.Base(path), t, ok, nErr)
	}
	return nil
}

func applySQLSubdir(db *gorm.DB, databaseRoot, subdir, label string, cfg config.Config, out io.Writer) error {
	dir := filepath.Join(databaseRoot, subdir)
	st, err := os.Stat(dir)
	if err != nil || !st.IsDir() {
		if out != nil {
			fmt.Fprintf(out, "提示: 无 %s 目录或不可读，跳过 %s。\n", dir, label)
		}
		return nil
	}
	files, err := listSortedSQLFiles(dir)
	if err != nil {
		return err
	}
	if len(files) == 0 && out != nil {
		fmt.Fprintf(out, "提示: %s 下无 .sql，跳过 %s。\n", dir, label)
	}
	for _, fp := range files {
		if err := applySQLFile(db, fp, cfg.DBPrefix, out); err != nil {
			return err
		}
	}
	return nil
}

func newMigrateCmd() *cobra.Command {
	c := &cobra.Command{
		Use:   "migrate",
		Short: "数据库：执行/导出 SQL（up、seed、dump、import-sql）；目录约定见 migrate up 说明",
	}
	c.AddCommand(cmdMigrateUp())
	c.AddCommand(cmdMigrateSeedSQL())
	c.AddCommand(cmdMigrateDump())
	c.AddCommand(cmdMigrateImportSQL())
	return c
}

func cmdMigrateDump() *cobra.Command {
	var force bool
	var prefix, filename, outDir, pluginRoot string
	cmd := &cobra.Command{
		Use:   "dump",
		Short: "从数据库导出核心表 DDL（SHOW CREATE TABLE），排除插件表，写入 gen/migrations/*.sql",
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			model.P = cfg.DBPrefix
			if prefix == "" {
				prefix = cfg.DBPrefix
			}
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库")
			}

			root := RootDir()
			if outDir == "" {
				outDir = tools.RootJoin(root, "gen", "migrations")
			} else if !filepath.IsAbs(outDir) {
				outDir = filepath.Join(root, outDir)
			}
			if pluginRoot == "" {
				pluginRoot = gen.ResolvePluginMigrationsRoot(root)
			} else if !filepath.IsAbs(pluginRoot) {
				pluginRoot = filepath.Join(root, pluginRoot)
			}
			pluginSet := gen.PluginTableSet(pluginRoot, prefix)

			all, err := gen.ListBaseTableNames(db, cfg, prefix)
			if err != nil {
				return err
			}
			tables := gen.CoreTableNames(all, prefix, pluginSet)
			if len(tables) == 0 {
				return fmt.Errorf("无非插件表可导出")
			}

			sqlText, err := gen.DumpSchemaSQL(db, tables)
			if err != nil {
				return err
			}

			ts := time.Now().Format("2006_01_02_150405")
			outPath := filepath.Join(outDir, fmt.Sprintf("%s_%s.sql", ts, filename))
			if _, err := os.Stat(outPath); err == nil && !force {
				return fmt.Errorf("文件已存在: %s（使用 --force 覆盖）", outPath)
			}
			if err := os.MkdirAll(outDir, 0o755); err != nil {
				return err
			}
			if err := os.WriteFile(outPath, []byte(sqlText), 0o644); err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "已写入 %s（%d 张表）\n", outPath, len(tables))
			return nil
		},
	}
	cmd.Flags().BoolVar(&force, "force", false, "覆盖已存在文件")
	cmd.Flags().StringVar(&prefix, "prefix", "", "表名前缀过滤（默认 DB_PREFIX）")
	cmd.Flags().StringVar(&filename, "filename", "all_tables", "输出文件名（不含后缀与时间戳）")
	cmd.Flags().StringVar(&outDir, "out-dir", "", "输出目录（默认 <root>/gen/migrations）")
	cmd.Flags().StringVar(&pluginRoot, "plugin-root", "", "插件根目录（默认本仓库 plugin/）")
	return cmd
}

func cmdMigrateImportSQL() *cobra.Command {
	var skipErrors bool
	var useTransaction bool
	var batchSize int
	cmd := &cobra.Command{
		Use:   "import-sql <file>",
		Short: "导入 SQL 文件（支持 _part2 分片；相对路径先查 gen/seeders 再 internal/store/database/seeders）",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库")
			}

			root := RootDir()
			mainPath, err := gen.ResolveSQLImportBase(root, args[0])
			if err != nil {
				return err
			}
			files, err := gen.ChunkedSQLPaths(mainPath)
			if err != nil {
				return err
			}

			var totalStmts, okStmts, errStmts int
			for _, fp := range files {
				b, err := os.ReadFile(fp)
				if err != nil {
					return err
				}
				stmts := gen.SplitSQLStatements(string(b))
				t, ok, nErr, err := gen.ImportSQLStatements(db, stmts, useTransaction, skipErrors, batchSize, func(done, tot int) {
					fmt.Fprintf(cmd.OutOrStdout(), "  %s 已执行 %d/%d 条\n", filepath.Base(fp), done, tot)
				})
				if err != nil {
					return fmt.Errorf("%s: %w", fp, err)
				}
				totalStmts += t
				okStmts += ok
				errStmts += nErr
				fmt.Fprintf(cmd.OutOrStdout(), "  完成 %s: 总计 %d，成功 %d，失败 %d\n", filepath.Base(fp), t, ok, nErr)
			}
			fmt.Fprintf(cmd.OutOrStdout(), "导入结束：文件 %d 个，语句 总计 %d / 成功 %d / 失败 %d\n", len(files), totalStmts, okStmts, errStmts)
			return nil
		},
	}
	cmd.Flags().BoolVar(&skipErrors, "skip-errors", false, "单条失败时继续（与 --transaction 互斥时是逐条执行）")
	cmd.Flags().BoolVar(&useTransaction, "transaction", true, "整体用事务（失败回滚；为 true 且未 skip-errors 时整文件单事务）")
	cmd.Flags().IntVar(&batchSize, "batch-size", 100, "进度打印间隔（每 N 条）")
	return cmd
}

func cmdMigrateUp() *cobra.Command {
	return &cobra.Command{
		Use:   "up <databaseDir>",
		Short: "仅执行 databaseDir 下迁移子目录中按文件名排序的 .sql；路径相对 server_go 根",
		Args:  cobra.ExactArgs(1),
		Long: `databaseDir 为数据库 SQL 根路径，例如:
  internal/store/database
  plugin/ds/sysConfig/database
子目录为 migrations（迁移）与 seeders（种子）。数据种子请用 migrate seed。{{prefix}} 在 SQL 中替换为环境变量 DB_PREFIX。`,
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库")
			}
			root := RootDir()
			dir, err := ResolveDatabaseDir(root, args[0])
			if err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "迁移目录 %s（DB_PREFIX=%q）\n", dir, cfg.DBPrefix)
			return RunDatabaseMigrationsOnly(db, dir, cfg, cmd.OutOrStdout())
		},
	}
}

func cmdMigrateSeedSQL() *cobra.Command {
	return &cobra.Command{
		Use:   "seed <databaseDir>",
		Short: "仅执行 databaseDir 下种子子目录中按文件名排序的 .sql；路径相对 server_go 根",
		Args:  cobra.ExactArgs(1),
		Long: `与 migrate up 分离：只跑 seeders 下 *.sql（含初始化数据，如管理员等）。
{{prefix}} 在 SQL 中替换为环境变量 DB_PREFIX。`,
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库")
			}
			root := RootDir()
			dir, err := ResolveDatabaseDir(root, args[0])
			if err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "种子目录 %s（DB_PREFIX=%q）\n", dir, cfg.DBPrefix)
			return RunDatabaseSeedersOnly(db, dir, cfg, cmd.OutOrStdout())
		},
	}
}
