package cli

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	tools "fastapp/internal/app/common"
	"fastapp/internal/app/model"
	"fastapp/internal/cli/gen"
	"fastapp/internal/config"
	"fastapp/internal/store"

	"github.com/spf13/cobra"
)

func newGenCmd() *cobra.Command {
	c := &cobra.Command{
		Use:   "gen",
		Short: "代码生成器（gen model / crud / seeders）；库迁移执行与 DDL 导出见 migrate",
	}
	c.AddCommand(cmdGenModel())
	c.AddCommand(cmdGenCrud())
	c.AddCommand(cmdGenSeeders())
	return c
}

func cmdGenModel() *cobra.Command {
	var table, module, plugin, target, sql, out, pkg string
	var force bool
	var pid int
	cmd := &cobra.Command{
		Use:   "model",
		Short: "根据 MySQL 表生成 GORM model（模板 internal/cli/templates/model.go.tmpl）",
		Long: `读取 information_schema 与 DB_PREFIX，生成 Go 结构体与 TableName()。

默认输出：gen/model/{StructName}_gen.go（package genmodel，TableName 使用 basemodel.P）。
输出到 internal/app/model 下且未指定 --package 时为 package model，TableName 使用 P。
插件目录 .../plugin/.../model/... 下为 package model + basemodel.P（与现有插件一致）。

--out - 仅打印到 stdout，--package 可指定包名。`,
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			model.P = cfg.DBPrefix
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库（设置 DB_DATABASE 等）")
			}
			if table == "" {
				return fmt.Errorf("--table 必填")
			}

			cols, err := gen.ListColumnMeta(db, cfg, table)
			if err != nil {
				return err
			}
			if len(cols) == 0 {
				return fmt.Errorf("表 %s%s 无列或未找到", model.P, table)
			}

			tcomment, err := gen.TableComment(db, cfg, table)
			if err != nil {
				return err
			}

			root := RootDir()
			modulePath, err := gen.ReadModulePath(root)
			if err != nil {
				return err
			}
			outPath, packageName, useBasemodel := gen.ResolveModelOutput(root, out, pkg, table)
			data := gen.BuildModelData(table, cols, tcomment, packageName, modulePath, useBasemodel)

			templatesDir := tools.RootJoin(root, "internal", "cli", "templates")
			b, err := gen.RenderModelGo(templatesDir, data)
			if err != nil {
				return err
			}

			if outPath == "-" {
				_, _ = cmd.OutOrStdout().Write(b)
				return nil
			}

			if _, err := os.Stat(outPath); err == nil && !force {
				return fmt.Errorf("文件已存在: %s（使用 --force 覆盖）", outPath)
			}
			if err := os.MkdirAll(filepath.Dir(outPath), 0o755); err != nil {
				return err
			}
			if err := os.WriteFile(outPath, b, 0o644); err != nil {
				return err
			}
			fmt.Fprintf(cmd.OutOrStdout(), "已生成 %s（%d 个字段）\n", outPath, len(cols))
			if module != "" || plugin != "" || target != "" || sql != "" || pid != 0 {
				fmt.Fprintf(cmd.OutOrStdout(), "提示: 若需 Admin CRUD 全量生成请使用 gen crud（--module/--plugin 等）；本命令仅生成 model。\n")
				fmt.Fprintf(cmd.OutOrStdout(), "  module=%q plugin=%q target=%q force=%v pid=%d sql=%q\n",
					module, plugin, target, force, pid, sql)
			}
			return nil
		},
	}
	cmd.Flags().StringVar(&table, "table", "", "表名（不含 DB_PREFIX）")
	cmd.Flags().StringVar(&out, "out", "", "输出 .go 路径；默认 gen/model/{Struct}_gen.go；`-` 打印到 stdout")
	cmd.Flags().StringVar(&pkg, "package", "", "覆盖 package 名（默认按输出路径推断）")
	cmd.Flags().BoolVar(&force, "force", false, "覆盖已存在文件")
	cmd.Flags().StringVar(&module, "module", "", "（占位参数）")
	cmd.Flags().StringVar(&plugin, "plugin", "", "（占位参数）")
	cmd.Flags().StringVar(&target, "target", "admin", "（占位参数）")
	cmd.Flags().StringVar(&sql, "sql", "", "（占位参数）")
	cmd.Flags().IntVar(&pid, "pid", 0, "（占位参数）")
	return cmd
}

func cmdGenCrud() *cobra.Command {
	var table, module, plugin, adminRoot, httpPrefix, modelOut, modelAlias, goOut string
	var force, runSQL, skipFront, skipGo bool
	var pid int
	cmd := &cobra.Command{
		Use:     "crud",
		Aliases: []string{"curd"},
		Short:   "Admin CRUD：Go handler + admin/Vue 模版 + 菜单 SQL（不含 Api target）",
		Long: `读取 MySQL 表结构，生成：
  • internal/app/http/admin/crud_gen_<table>.go（或 plugin/.../src/http/）
  • admin/src/modules/<module>/... 或 plugin/.../web/ 下 vue/tsx/api
  • gen/crud/sql/*_menu.sql、gen/crud/snippets/*_endpoints.txt
  • 非 --skip-go 时：核心向 endpoints.go 尾部追加路由；插件无 routes.go 时自动创建标准骨架再写入（已有则尾部追加；list Path 已存在则跳过）；并向 plugin/plugin.go 追加 import 与 RegisterHTTPEndpoints（已登记则跳过）

未指定 --model-out 时默认写入：核心 internal/app/model/<表>.go，插件 plugin/.../src/model/<表>.go（文件已存在且未 --force 则跳过 model 覆盖）。
菜单 SQL 仅当传入 --sql 时执行（核心与插件相同）。
插件 snippets、sql 文件名带插件前缀（如 ds_test_kefu_*）。
覆盖已生成文件请加 --force。
--http-prefix 可覆盖自动推导的 /admin/... 路径。`,
		RunE: func(cmd *cobra.Command, args []string) error {
			cfg := config.Load()
			model.P = cfg.DBPrefix
			db, err := store.OpenMySQL(cfg)
			if err != nil {
				return fmt.Errorf("database: %w", err)
			}
			if db == nil {
				return fmt.Errorf("未配置数据库")
			}
			root := RootDir()
			templatesDir := tools.RootJoin(root, "internal", "cli", "templates")
			if adminRoot == "" {
				adminRoot = tools.SiblingAdminDir(root)
			} else if !filepath.IsAbs(adminRoot) {
				adminRoot = filepath.Join(root, adminRoot)
			}

			opts := gen.CrudOptions{
				Table:      table,
				Module:     module,
				Plugin:     plugin,
				AdminRoot:  adminRoot,
				HTTPPrefix: httpPrefix,
				Force:      force,
				PID:        pid,
				RunMenuSQL: runSQL,
				SkipFront:  skipFront,
				SkipGo:     skipGo,
				ModelOut:   modelOut,
				ModelAlias: modelAlias,
				GoOut:      goOut,
			}
			b, err := gen.BuildCrudBundle(db, cfg, opts, root)
			if err != nil {
				return err
			}

			explicitModel := strings.TrimSpace(modelOut) != ""
			modelRel := strings.TrimSpace(modelOut)
			if modelRel == "" {
				if b.IsPlugin {
					modelRel = gen.DefaultPluginModelRelPath(b.PluginPath, table)
				} else {
					modelRel = gen.DefaultCoreModelRelPath(table)
				}
			}
			outPath, pkg, useBM := gen.ResolveModelOutput(root, modelRel, "", table)
			absModel := outPath
			if !filepath.IsAbs(absModel) {
				absModel = filepath.Join(root, outPath)
			}
			absModel = filepath.Clean(absModel)

			_, statErr := os.Stat(absModel)
			modelExists := statErr == nil
			if modelExists && !force {
				if explicitModel {
					return fmt.Errorf("model 已存在: %s（--force）", absModel)
				}
				fmt.Fprintf(cmd.OutOrStdout(), "跳过 model（已存在）: %s\n", absModel)
			} else {
				cols, err := gen.ListColumnMeta(db, cfg, table)
				if err != nil {
					return err
				}
				tcomment, err := gen.TableComment(db, cfg, table)
				if err != nil {
					return err
				}
				data := gen.BuildModelData(table, cols, tcomment, pkg, b.ModulePath, useBM)
				mb, err := gen.RenderModelGo(templatesDir, data)
				if err != nil {
					return err
				}
				if err := os.MkdirAll(filepath.Dir(absModel), 0o755); err != nil {
					return err
				}
				if err := os.WriteFile(absModel, mb, 0o644); err != nil {
					return err
				}
				fmt.Fprintf(cmd.OutOrStdout(), "已写入 model %s\n", absModel)
			}

			return gen.WriteCrudArtifacts(db, b, root, templatesDir, adminRoot, cmd.OutOrStdout())
		},
	}
	cmd.Flags().StringVar(&table, "table", "", "表名（不含 DB_PREFIX）")
	cmd.Flags().StringVar(&module, "module", "", "admin 模块目录名（如 search）；插件模式可空")
	cmd.Flags().StringVar(&plugin, "plugin", "", "插件路径（如 ds/sysCms）")
	cmd.Flags().StringVar(&adminRoot, "admin-root", "", "admin 项目根路径（默认 <repo>/admin）")
	cmd.Flags().StringVar(&httpPrefix, "http-prefix", "", "覆盖 HTTP 前缀，如 /admin/search/keyword")
	cmd.Flags().BoolVar(&force, "force", false, "覆盖已存在文件")
	cmd.Flags().BoolVar(&runSQL, "sql", false, "生成后执行菜单 SQL（默认关；核心与插件均可）")
	cmd.Flags().IntVar(&pid, "pid", 0, "菜单 parent_id")
	cmd.Flags().StringVar(&modelOut, "model-out", "", "GORM model 输出路径；不设则核心→internal/app/model/<表>.go，插件→plugin/.../src/model/<表>.go（已存在且未 --force 则跳过）")
	cmd.Flags().BoolVar(&skipFront, "skip-front", false, "仅生成 Go + SQL + 片段")
	cmd.Flags().BoolVar(&skipGo, "skip-go", false, "仅生成前端 + SQL + 片段")
	cmd.Flags().StringVar(&modelAlias, "model-alias", "", "插件 model import 别名（默认 plugmodel）")
	cmd.Flags().StringVar(&goOut, "go-out", "", "覆盖生成的 Go handler 路径")
	return cmd
}

func cmdGenSeeders() *cobra.Command {
	var force bool
	var prefix, filename, outDir, pluginRoot string
	var limit, chunkSize int
	cmd := &cobra.Command{
		Use:   "seeders",
		Short: "导出非插件表数据为 INSERT SQL，支持按体积分片",
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
				outDir = tools.RootJoin(root, "gen", "seeders")
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

			chunks, err := gen.DumpSeedersSQL(db, tables, limit, chunkSize)
			if err != nil {
				return err
			}
			if len(chunks) == 0 {
				return fmt.Errorf("所有表均无数据（或 LIMIT=%d 为空）", limit)
			}

			ts := time.Now().Format("2006_01_02_150405")
			if err := os.MkdirAll(outDir, 0o755); err != nil {
				return err
			}
			for i, data := range chunks {
				var name string
				if i == 0 {
					name = fmt.Sprintf("%s_%s.sql", ts, filename)
				} else {
					name = fmt.Sprintf("%s_%s_part%d.sql", ts, filename, i+1)
				}
				outPath := filepath.Join(outDir, name)
				if _, err := os.Stat(outPath); err == nil && !force {
					return fmt.Errorf("文件已存在: %s（使用 --force 覆盖）", outPath)
				}
				if err := os.WriteFile(outPath, data, 0o644); err != nil {
					return err
				}
				fmt.Fprintf(cmd.OutOrStdout(), "已写入 %s\n", outPath)
			}
			return nil
		},
	}
	cmd.Flags().BoolVar(&force, "force", false, "覆盖已存在文件")
	cmd.Flags().StringVar(&prefix, "prefix", "", "表名前缀（默认 DB_PREFIX）")
	cmd.Flags().StringVar(&filename, "filename", "all_data", "输出文件名（不含后缀与时间戳）")
	cmd.Flags().StringVar(&outDir, "out-dir", "", "输出目录（默认 <root>/gen/seeders）")
	cmd.Flags().StringVar(&pluginRoot, "plugin-root", "", "插件根目录（默认本仓库 plugin/）")
	cmd.Flags().IntVar(&limit, "limit", 1000, "每表最大行数")
	cmd.Flags().IntVar(&chunkSize, "chunk-size", 10, "单文件大致上限（MB）")
	return cmd
}
