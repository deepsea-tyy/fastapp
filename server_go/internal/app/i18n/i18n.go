package i18n

import (
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"sync"

	"github.com/gin-gonic/gin"
)

// Init 在进程内只生效一次；须在任何 T / Merge 之前调用，localesDir 为工程根下 storage/locales（含 en.json、zh_CN.json）。
func Init(localesDir string) {
	initOnce.Do(func() {
		dir := filepath.Clean(localesDir)
		m := make(map[string]map[string]string)
		for _, name := range []string{"en", "zh_CN"} {
			b, err := os.ReadFile(filepath.Join(dir, name+".json"))
			if err != nil {
				panic("i18n: " + err.Error())
			}
			var parsed map[string]string
			if err := json.Unmarshal(b, &parsed); err != nil {
				panic("i18n: " + err.Error())
			}
			m[name] = parsed
		}
		mu.Lock()
		byLocale = m
		mu.Unlock()
	})
}

// ContextLocaleKey Gin 上下文中存放规范化 locale（en / zh_CN）的键，与 middleware.Translation 一致。
const ContextLocaleKey = "locale"

var (
	initOnce sync.Once
	mu       sync.RWMutex
	byLocale map[string]map[string]string
)

func ensureCore() {
	mu.RLock()
	ok := byLocale != nil
	mu.RUnlock()
	if !ok {
		panic("i18n: Init not called")
	}
}

// Merge 将词条合并进指定语言表（启动期调用；后写入覆盖先前列）。locale 须为 en / zh_CN。
func Merge(locale string, kv map[string]string) {
	if len(kv) == 0 {
		return
	}
	ensureCore()
	loc := NormalizeLocale(locale)
	if loc != "en" && loc != "zh_CN" {
		loc = "zh_CN"
	}
	mu.Lock()
	defer mu.Unlock()
	dst := byLocale[loc]
	for k, v := range kv {
		if k == "" || v == "" {
			continue
		}
		dst[k] = v
	}
}

// NormalizeLocale 仅支持 en、zh_CN；其余语种按 zh_CN。
func NormalizeLocale(acceptLanguage string) string {
	s := strings.TrimSpace(strings.ToLower(strings.ReplaceAll(acceptLanguage, "-", "_")))
	if strings.HasPrefix(s, "en") {
		return "en"
	}
	return "zh_CN"
}

// T 按语言与键取文案；无则返回 key。
func T(locale, key string) string {
	ensureCore()
	loc := NormalizeLocale(locale)
	mu.RLock()
	m := byLocale[loc]
	zh := byLocale["zh_CN"]
	mu.RUnlock()
	if m == nil {
		m = zh
	}
	if v, ok := m[key]; ok && v != "" {
		return v
	}
	if loc != "zh_CN" {
		if v, ok := zh[key]; ok && v != "" {
			return v
		}
	}
	return key
}

// FromGin 从上下文取 locale；若无则 zh_CN。
func FromGin(c *gin.Context) string {
	if c == nil {
		return "zh_CN"
	}
	v, ok := c.Get(ContextLocaleKey)
	s, _ := v.(string)
	if !ok || strings.TrimSpace(s) == "" {
		return "zh_CN"
	}
	return s
}
