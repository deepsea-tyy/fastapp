package response

import (
	"encoding/json"
	"net/http"

	"fastapp/internal/app/i18n"

	"github.com/gin-gonic/gin"
)

// Result
type Result struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
	Data    any    `json:"data"`
}

const (
	CodeSuccess          = ResultSuccess
	CodeFail             = ResultFail
	CodeUnauthorized     = ResultUnauthorized
	CodeForbidden        = ResultForbidden
	CodeNotFound         = ResultNotFound
	CodeMethodNotAllowed = ResultMethodNotAllowed
	CodeNotAcceptable    = ResultNotAcceptable
	CodeUnprocessable    = ResultUnprocessableEntity
	CodeDisabled         = ResultDisabled
)

func OK(data any) Result {
	return Result{Code: CodeSuccess, Message: defaultMessage(CodeSuccess), Data: data}
}

// OKWithMessage 成功但自定义 message（如短信发送提示）
func OKWithMessage(message string, data any) Result {
	if data == nil {
		data = emptyObject{}
	}
	return Result{Code: CodeSuccess, Message: message, Data: data}
}

func Fail(message string) Result {
	if message == "" {
		message = defaultMessage(CodeFail)
	}
	return Result{Code: CodeFail, Message: message, Data: emptyObject{}}
}

// WithCode 任意业务码
func WithCode(code int, message string, data any) Result {
	if message == "" {
		message = defaultMessage(code)
	}
	if data == nil {
		data = emptyObject{}
	}
	return Result{Code: code, Message: message, Data: data}
}

func defaultMessage(code int) string {
	switch code {
	case ResultSuccess:
		return "success"
	case ResultUnauthorized:
		return "unauthorized"
	case ResultForbidden:
		return "forbidden"
	case ResultNotFound:
		return "not found"
	case ResultMethodNotAllowed:
		return "method not allowed"
	case ResultNotAcceptable:
		return "not acceptable"
	case ResultUnprocessableEntity:
		return "unprocessable entity"
	case ResultDisabled:
		return "disabled"
	default:
		return "fail"
	}
}

// emptyObject 序列化为 JSON 对象 {}
type emptyObject struct{}

func (r Result) MarshalJSON() ([]byte, error) {
	data := r.Data
	if data == nil {
		data = map[string]any{}
	}
	aux := struct {
		Code    int    `json:"code"`
		Message string `json:"message"`
		Data    any    `json:"data"`
	}{Code: r.Code, Message: r.Message, Data: data}
	return json.Marshal(aux)
}

// JSON 写入 Gin 上下文（对象键统一为 snake_case）
func JSON(c *gin.Context, status int, r Result) {
	if c != nil {
		if def := defaultMessage(r.Code); r.Message == def {
			r.Message = i18n.T(i18n.FromGin(c), ResultMessageKey(r.Code))
		}
	}
	b, err := marshalJSONSnake(r)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"code": 500, "message": "json encode failed", "data": emptyObject{}})
		return
	}
	c.Data(status, "application/json; charset=utf-8", b)
}

// Stub 占位响应（HTTP 200 + 业务 code 200）
func Stub(c *gin.Context) {
	JSON(c, http.StatusOK, OK(map[string]any{
		"_stub":   true,
		"_server": "server_go",
		"_path":   c.Request.URL.Path,
		"_method": c.Request.Method,
	}))
}
