package gen

import (
	"regexp"
	"strings"
)

var (
	reLineComment  = regexp.MustCompile(`(?m)--[^\n]*`)
	reBlockComment = regexp.MustCompile(`(?s)/\*.*?\*/`)
)

// SplitSQLStatements 。
func SplitSQLStatements(content string) []string {
	content = reLineComment.ReplaceAllString(content, "")
	content = reBlockComment.ReplaceAllString(content, "")

	b := []byte(content)
	var statements []string
	var current strings.Builder

	flush := func() {
		s := strings.TrimSpace(current.String())
		current.Reset()
		if s != "" {
			statements = append(statements, s)
		}
	}

	inString := false
	var stringChar byte
	for i := 0; i < len(b); i++ {
		c := b[i]
		var prev byte
		if i > 0 {
			prev = b[i-1]
		}
		if !inString && (c == '"' || c == '\'' || c == '`') {
			inString = true
			stringChar = c
			current.WriteByte(c)
			continue
		}
		if inString {
			current.WriteByte(c)
			if c == stringChar && prev != '\\' {
				inString = false
			}
			continue
		}
		if c == ';' {
			flush()
			continue
		}
		current.WriteByte(c)
	}
	flush()
	return statements
}

// IsSQLCommentStatement 整段为 SQL 注释（trim 后以 -- 开头）。
func IsSQLCommentStatement(s string) bool {
	return strings.HasPrefix(strings.TrimSpace(s), "--")
}
