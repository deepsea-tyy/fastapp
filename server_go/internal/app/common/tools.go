package tools

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha1"
	"encoding/base32"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net/url"
	"strconv"
	"strings"
	"time"

	"fastapp/internal/app/common/deps"
	"fastapp/internal/app/common/response"
	"fastapp/internal/app/model"
	"fastapp/internal/app/service/verifycode"
	cmsmodel "fastapp/plugin/ds/sysCms/src/model"

	"github.com/gin-gonic/gin"
	"github.com/go-playground/validator/v10"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// BindJSONOr422 解析并校验 JSON（binding tag）；失败时。
func BindJSONOr422(c *gin.Context, v any) bool {
	if err := c.ShouldBindJSON(v); err != nil {
		msg := validationFirstError(err)
		response.JSON(c, 200, response.WithCode(response.CodeUnprocessable, msg, nil))
		return false
	}
	return true
}

func validationFirstError(err error) string {
	var verrs validator.ValidationErrors
	if errors.As(err, &verrs) && len(verrs) > 0 {
		f := verrs[0]
		switch f.Tag() {
		case "required":
			return f.Field() + " is required"
		case "email":
			return f.Field() + " must be a valid email"
		case "min":
			return f.Field() + " is too short"
		case "max":
			return f.Field() + " is too long"
		default:
			return f.Field() + " invalid"
		}
	}
	return "invalid request"
}

const (
	LoginTypeUsernamePassword = 1
	LoginTypeMobileCode       = 2
	LoginTypeEmailCode        = 3
)

const (
	VerifyGoogle = "google2fa_code"
	VerifyEmail  = "email_code"
	VerifyMobile = "mobile_code"
	VerifyNone   = ""
)

func ParseFlexInt(raw json.RawMessage) (int, bool) {
	if len(raw) == 0 {
		return 0, false
	}
	var n int
	if err := json.Unmarshal(raw, &n); err == nil {
		return n, true
	}
	var s string
	if err := json.Unmarshal(raw, &s); err != nil {
		return 0, false
	}
	n, err := strconv.Atoi(strings.TrimSpace(s))
	return n, err == nil
}

func UserNo(id int64) int64 {
	s := fmt.Sprintf("5%07d", id)
	n, err := strconv.ParseInt(s, 10, 64)
	if err != nil {
		return 50000000 + id
	}
	return n
}

func AssignAppUsername(tx *gorm.DB, u *model.User) error {
	no := UserNo(u.ID)
	u.Username = fmt.Sprintf("@u%d", no)
	return tx.Model(u).Update("username", u.Username).Error
}

func HashPassword(plain string) (string, error) {
	b, err := bcrypt.GenerateFromPassword([]byte(plain), bcrypt.DefaultCost)
	if err != nil {
		return "", err
	}
	return string(b), nil
}

func DeviceIDOrNew(c *gin.Context, body string) string {
	s := strings.TrimSpace(body)
	if s != "" {
		return s
	}
	return randomUUID()
}

func randomUUID() string {
	b := make([]byte, 16)
	if _, err := rand.Read(b); err != nil {
		slog.Warn("randomUUID", "err", err)
		return fmt.Sprintf("%d", time.Now().UnixNano())
	}
	b[6] = (b[6] & 0x0f) | 0x40
	b[8] = (b[8] & 0x3f) | 0x80
	return fmt.Sprintf("%x-%x-%x-%x-%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:16])
}

func InsertAccountLog(d *deps.Deps, userID int64, typ int, c *gin.Context, deviceID string) {
	if d == nil || d.DB == nil {
		return
	}
	row := model.UserAccountLog{
		UserID:      userID,
		Type:        typ,
		IP:          c.ClientIP(),
		OS:          c.GetHeader("X-OS"),
		DeviceID:    deviceID,
		CountryCode: "",
		Country:     "",
		Region:      "",
		City:        "",
		CreatedAt:   time.Now(),
	}
	if err := d.DBx(c).Create(&row).Error; err != nil {
		slog.Warn("user account log insert", "err", err, "user_id", userID, "type", typ)
	}
}

func IssueAPIToken(d *deps.Deps, uid int64, c *gin.Context, deviceID string, logType int) (map[string]any, error) {
	if d.JWTAPI == nil {
		return nil, fmt.Errorf("jwt api not configured")
	}
	access, refresh, ttl, err := d.JWTAPI.IssuePair(uid)
	if err != nil {
		return nil, err
	}
	InsertAccountLog(d, uid, logType, c, deviceID)
	return map[string]any{
		"access_token":  access,
		"refresh_token": refresh,
		"expire_at":     ttl,
		"device_id":     deviceID,
	}, nil
}

func DetectVerifyMethod(u *model.User) map[string]any {
	out := map[string]any{"verify_again": VerifyNone}
	if u.Google2fa != "" {
		out["verify_again"] = VerifyGoogle
		return out
	}
	if u.Email != "" {
		out["verify_again"] = VerifyEmail
		out["email"] = u.Email
		return out
	}
	if u.Mobile != "" {
		out["verify_again"] = VerifyMobile
		out["mobile"] = u.Mobile
		out["code"] = fmt.Sprintf("%d", u.Code)
	}
	return out
}

func NeedsSecondStep(info map[string]any, googleCode, vcode string) bool {
	switch info["verify_again"] {
	case VerifyGoogle:
		return strings.TrimSpace(googleCode) == ""
	case VerifyEmail, VerifyMobile:
		return strings.TrimSpace(vcode) == ""
	default:
		return false
	}
}

func VerifySecondFactor(ctx context.Context, d *deps.Deps, u *model.User, googleCode, vcode, email, mobile, countryStr, scene string) error {
	if u.Google2fa != "" {
		if strings.TrimSpace(googleCode) == "" {
			return fmt.Errorf("google2fa required")
		}
		if IsProd() && !Validate(u.Google2fa, googleCode, 1) {
			return fmt.Errorf("google2fa invalid")
		}
		return nil
	}
	if u.Email != "" {
		target := email
		if target == "" {
			target = u.Email
		}
		if !verifycode.Verify(ctx, d.RDB, verifycode.TypeEmail, target, vcode, scene, true, 0) {
			return fmt.Errorf("email code invalid")
		}
		return nil
	}
	if u.Mobile != "" {
		m := mobile
		if m == "" {
			m = u.Mobile
		}
		cc := u.Code
		if countryStr != "" {
			if v, err := strconv.Atoi(countryStr); err == nil {
				cc = v
			}
		}
		if !verifycode.Verify(ctx, d.RDB, verifycode.TypeSMS, m, vcode, scene, true, cc) {
			return fmt.Errorf("mobile code invalid")
		}
	}
	return nil
}

func VerifyGoogle2FA(secret, code string) error {
	if strings.TrimSpace(secret) == "" {
		return fmt.Errorf("no secret")
	}
	if IsProd() && !Validate(secret, code, 1) {
		return fmt.Errorf("invalid")
	}
	return nil
}

const stepSec = 30

// GenerateSecret 返回 Base32 密钥（无空格、大写），与常见 Authenticator 一致。
func GenerateSecret() (string, error) {
	raw := make([]byte, 20)
	if _, err := rand.Read(raw); err != nil {
		return "", err
	}
	return strings.TrimRight(base32.StdEncoding.EncodeToString(raw), "="), nil
}

// Validate 校验 TOTP 码，允许 ±skew 个时间步。
func Validate(secret, code string, skew int) bool {
	secret = strings.ToUpper(strings.ReplaceAll(strings.TrimSpace(secret), " ", ""))
	// 补齐 base32 padding
	if m := len(secret) % 8; m != 0 {
		secret += strings.Repeat("=", 8-m)
	}
	key, err := base32.StdEncoding.DecodeString(secret)
	if err != nil {
		return false
	}
	if skew < 0 {
		skew = 1
	}
	now := time.Now().Unix() / stepSec
	for i := -skew; i <= skew; i++ {
		if hotpString(key, now+int64(i)) == strings.TrimSpace(code) {
			return true
		}
	}
	return false
}

func hotpString(key []byte, counter int64) string {
	buf := make([]byte, 8)
	binary.BigEndian.PutUint64(buf, uint64(counter))
	mac := hmac.New(sha1.New, key)
	_, _ = mac.Write(buf)
	sum := mac.Sum(nil)
	off := sum[len(sum)-1] & 0xf
	c := binary.BigEndian.Uint32(sum[off:off+4]) & 0x7fffffff
	return fmt.Sprintf("%06d", c%1000000)
}

// ProvisioningURI 生成 otpauth URL（可交给前端生成二维码）。
func ProvisioningURI(account, issuer, secret string) string {
	q := url.Values{}
	q.Set("secret", strings.TrimSpace(secret))
	q.Set("issuer", issuer)
	label := issuer + ":" + account
	u := url.URL{
		Scheme:   "otpauth",
		Host:     "totp",
		Path:     "/" + url.PathEscape(label),
		RawQuery: q.Encode(),
	}
	return u.String()
}

// ProfileLang 从用户 profile 取语言，默认 zh_CN。
func ProfileLang(db *gorm.DB, userID int64) string {
	if userID <= 0 {
		return "zh_CN"
	}
	var p model.UserProfile
	if err := db.Where("user_id = ?", userID).First(&p).Error; err != nil {
		return "zh_CN"
	}
	if strings.TrimSpace(p.Lang) == "" {
		return "zh_CN"
	}
	return strings.TrimSpace(p.Lang)
}

// CmsUserProfileMap 管理端/接口展示用用户摘要。
func CmsUserProfileMap(db *gorm.DB, userID int64) map[string]any {
	var p model.UserProfile
	if err := db.Where("user_id = ?", userID).First(&p).Error; err != nil {
		return map[string]any{"user_id": userID, "nickname": "", "avatar": "", "signed": "", "lang": "zh_CN"}
	}
	return map[string]any{
		"user_id":  p.UserID,
		"nickname": p.Nickname,
		"avatar":   p.Avatar,
		"signed":   p.Signed,
		"lang":     p.Lang,
	}
}

// FormatArticleRow 文章行转 API map（ds/sysCms）。
func FormatArticleRow(a cmsmodel.Article) map[string]any {
	uid := int64(0)
	if a.CreatedBy != nil {
		uid = *a.CreatedBy
	}
	return map[string]any{
		"id":            a.ID,
		"profile":       nil,
		"title":         a.Title,
		"subtitle":      a.Subtitle,
		"brief":         a.Brief,
		"content":       a.Content,
		"cover":         a.Cover,
		"author":        a.Author,
		"view_count":    a.ViewCount,
		"like_count":    a.LikeCount,
		"comment_count": a.CommentCount,
		"share_count":   a.ShareCount,
		"collect_count": a.CollectCount,
		"created_at":    a.CreatedAt.Format(time.DateTime),
		"created_by":    uid,
	}
}

// JSONToObject 将 JSON 列（RawMessage）解析为与原文一致的 map/slice/标量；空或非法返回 nil。
func JSONToObject(raw json.RawMessage) any {
	if len(raw) == 0 {
		return nil
	}
	var v any
	if err := json.Unmarshal(raw, &v); err != nil {
		return nil
	}
	return v
}

// data 可为 json.RawMessage / []byte（会先 JSON 解析）、JSONToObject 得到的 string / map / []any。
func FormatLang(data any, acceptLang string) string {
	lang := strings.TrimSpace(acceptLang)
	if lang == "" {
		lang = "zh_CN"
	}
	if data == nil {
		return ""
	}
	switch v := data.(type) {
	case []byte:
		if len(v) == 0 {
			return ""
		}
		var parsed any
		if json.Unmarshal(v, &parsed) != nil {
			return ""
		}
		return FormatLang(parsed, lang)
	case json.RawMessage:
		return FormatLang([]byte(v), lang)
	case string:
		return v
	case map[string]any:
		if s, _ := v[lang].(string); s != "" {
			return s
		}
		if s, _ := v["zh_CN"].(string); s != "" {
			return s
		}
		for _, x := range v {
			if s, ok := x.(string); ok && s != "" {
				return s
			}
		}
		return ""
	case []any:
		if len(v) == 0 {
			return ""
		}
		for _, it := range v {
			kv, ok := it.(map[string]any)
			if !ok {
				continue
			}
			l, _ := kv["lang"].(string)
			t, _ := kv["text"].(string)
			if l == lang {
				return t
			}
		}
		kv0, ok := v[0].(map[string]any)
		if !ok {
			return ""
		}
		t, _ := kv0["text"].(string)
		return t
	default:
		return ""
	}
}

