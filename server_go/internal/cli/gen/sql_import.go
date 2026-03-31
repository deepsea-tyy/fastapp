package gen

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"gorm.io/gorm"
)

// ResolveSQLImportBase 解析首个存在的 SQL 路径（相对路径时依次尝试 gen/seeders、internal/store/database/seeders）。
func ResolveSQLImportBase(serverGoRoot, fileArg string) (string, error) {
	if filepath.IsAbs(fileArg) {
		return filepath.Clean(fileArg), nil
	}
	fileArg = strings.TrimLeft(fileArg, "/")
	candidates := []string{
		filepath.Join(serverGoRoot, "gen", "seeders", fileArg),
		filepath.Join(serverGoRoot, "internal", "store", "database", "seeders", fileArg),
	}
	for _, p := range candidates {
		p = filepath.Clean(p)
		if _, err := os.Stat(p); err == nil {
			return p, nil
		}
	}
	return "", fmt.Errorf("找不到 SQL 文件（已尝试 gen/seeders 与 internal/store/database/seeders）: %s", fileArg)
}

// ChunkedSQLPaths 主文件 + 同目录 filename_part2.sql …
func ChunkedSQLPaths(mainPath string) ([]string, error) {
	if _, err := os.Stat(mainPath); err != nil {
		return nil, err
	}
	dir := filepath.Dir(mainPath)
	base := strings.TrimSuffix(filepath.Base(mainPath), filepath.Ext(mainPath))
	ext := strings.TrimPrefix(filepath.Ext(mainPath), ".")
	if ext == "" {
		ext = "sql"
	}
	out := []string{mainPath}
	for i := 2; ; i++ {
		part := filepath.Join(dir, fmt.Sprintf("%s_part%d.%s", base, i, ext))
		if _, err := os.Stat(part); err != nil {
			break
		}
		out = append(out, part)
	}
	return out, nil
}

// FilterExecStatements 去掉空语句与整段注释。
func FilterExecStatements(stmts []string) []string {
	var out []string
	for _, s := range stmts {
		t := strings.TrimSpace(s)
		if t == "" || IsSQLCommentStatement(t) {
			continue
		}
		out = append(out, t)
	}
	return out
}

// ImportSQLStatements 执行已切分的语句；useTransaction 且 !skipErrors 时用单事务；否则逐条 Exec。
func ImportSQLStatements(db *gorm.DB, stmts []string, useTransaction, skipErrors bool, batchSize int, onProgress func(done, total int)) (total, success, errors int, err error) {
	valid := FilterExecStatements(stmts)
	total = len(valid)
	if total == 0 {
		return 0, 0, 0, nil
	}
	if batchSize <= 0 {
		batchSize = 100
	}

	runOne := func(tx *gorm.DB, sql string) error {
		return tx.Exec(sql).Error
	}

	if useTransaction && !skipErrors {
		err = db.Transaction(func(tx *gorm.DB) error {
			for i, s := range valid {
				if e := runOne(tx, s); e != nil {
					return e
				}
				success++
				if onProgress != nil && (i+1)%batchSize == 0 {
					onProgress(i+1, total)
				}
			}
			if onProgress != nil && total%batchSize != 0 {
				onProgress(total, total)
			}
			return nil
		})
		if err != nil {
			return total, 0, 0, err
		}
		return total, success, 0, nil
	}

	for i, s := range valid {
		e := runOne(db, s)
		if e != nil {
			errors++
			if !skipErrors {
				return total, success, errors, fmt.Errorf("语句 %d/%d: %w", i+1, total, e)
			}
		} else {
			success++
		}
		if onProgress != nil && (i+1)%batchSize == 0 {
			onProgress(i+1, total)
		}
	}
	if onProgress != nil && total%batchSize != 0 {
		onProgress(total, total)
	}
	return total, success, errors, nil
}
