package gen

import (
	"database/sql"
	"fmt"
	"strings"
	"time"

	"gorm.io/gorm"
)

// DumpSeedersSQL 导出多表 INSERT（过滤空表、按字节体积分片）。
func DumpSeedersSQL(db *gorm.DB, tables []string, limit int, chunkSizeMB int) ([][]byte, error) {
	if limit <= 0 {
		limit = 1000
	}
	if chunkSizeMB <= 0 {
		chunkSizeMB = 10
	}
	chunkBytes := chunkSizeMB * 1024 * 1024

	header := buildSeederHeader()
	footer := "\nSET FOREIGN_KEY_CHECKS = 1;\n"

	var files [][]byte
	var cur strings.Builder
	cur.WriteString(header)
	curSize := len(header)

	flush := func() {
		if cur.Len() <= len(header) {
			return
		}
		cur.WriteString(footer)
		files = append(files, []byte(cur.String()))
		cur.Reset()
		cur.WriteString(header)
		curSize = len(header)
	}

	for _, tbl := range tables {
		n, block, err := dumpTableInserts(db, tbl, limit)
		if err != nil {
			return nil, err
		}
		if n == 0 || block == "" {
			continue
		}
		blockBytes := len(block)
		if curSize+blockBytes > chunkBytes && curSize > len(header) {
			flush()
		}
		cur.WriteString(block)
		curSize += blockBytes
	}

	if curSize > len(header) {
		flush()
	}
	return files, nil
}

func buildSeederHeader() string {
	return "-- Data seed SQL (fastapp-cli gen seeders)\n" +
		"-- " + time.Now().Format(time.RFC3339) + "\n\n" +
		"SET FOREIGN_KEY_CHECKS = 0;\n\n"
}

func dumpTableInserts(db *gorm.DB, fullTable string, limit int) (rowCount int, sqlBlock string, err error) {
	q := "SELECT * FROM " + quoteIdent(fullTable) + fmt.Sprintf(" LIMIT %d", limit)
	rows, err := db.Raw(q).Rows()
	if err != nil {
		return 0, "", err
	}
	defer rows.Close()

	cols, err := rows.Columns()
	if err != nil {
		return 0, "", err
	}
	if len(cols) == 0 {
		return 0, "", nil
	}

	colTypes, err := rows.ColumnTypes()
	if err != nil {
		return 0, "", err
	}
	dbTypes := make([]string, len(colTypes))
	for i, ct := range colTypes {
		dbTypes[i] = strings.ToUpper(ct.DatabaseTypeName())
	}

	colQuoted := make([]string, len(cols))
	for i, c := range cols {
		colQuoted[i] = quoteIdent(c)
	}
	colsJoined := strings.Join(colQuoted, ", ")

	var inserts []string
	for rows.Next() {
		raw := make([]sql.RawBytes, len(cols))
		ptr := make([]interface{}, len(cols))
		for i := range raw {
			ptr[i] = &raw[i]
		}
		if err := rows.Scan(ptr...); err != nil {
			return 0, "", err
		}
		vals := make([]string, len(cols))
		for i := range cols {
			if raw[i] == nil {
				vals[i] = "NULL"
			} else {
				vals[i] = formatSQLLiteral(string(raw[i]), dbTypes[i])
			}
		}
		inserts = append(inserts, "("+strings.Join(vals, ", ")+")")
	}
	if err := rows.Err(); err != nil {
		return 0, "", err
	}
	if len(inserts) == 0 {
		return 0, "", nil
	}

	var b strings.Builder
	b.WriteString("-- ============================================\n")
	b.WriteString("-- Table: ")
	b.WriteString(fullTable)
	b.WriteString(fmt.Sprintf(" (%d rows, limit %d)\n", len(inserts), limit))
	b.WriteString("-- ============================================\n\n")

	const batch = 100
	for i := 0; i < len(inserts); i += batch {
		j := i + batch
		if j > len(inserts) {
			j = len(inserts)
		}
		b.WriteString("INSERT INTO ")
		b.WriteString(quoteIdent(fullTable))
		b.WriteString(" (")
		b.WriteString(colsJoined)
		b.WriteString(") VALUES\n")
		b.WriteString(strings.Join(inserts[i:j], ",\n"))
		b.WriteString(";\n\n")
	}
	return len(inserts), b.String(), nil
}

func formatSQLLiteral(s, dbType string) string {
	switch dbType {
	case "BIGINT", "INT", "INTEGER", "SMALLINT", "TINYINT", "MEDIUMINT",
		"UNSIGNED BIGINT", "UNSIGNED INT",
		"FLOAT", "DOUBLE", "FLOAT4", "FLOAT8", "REAL", "DOUBLE PRECISION",
		"DECIMAL", "NUMERIC", "YEAR":
		if s == "" {
			return "NULL"
		}
		return s
	case "BIT":
		return "'" + escapeSQLString(s) + "'"
	default:
		return "'" + escapeSQLString(s) + "'"
	}
}

func escapeSQLString(s string) string {
	s = strings.ReplaceAll(s, "\\", "\\\\")
	s = strings.ReplaceAll(s, "'", "''")
	s = strings.ReplaceAll(s, "\r\n", "\\n")
	s = strings.ReplaceAll(s, "\n", "\\n")
	s = strings.ReplaceAll(s, "\r", "\\n")
	s = strings.ReplaceAll(s, "\x00", "")
	return s
}
