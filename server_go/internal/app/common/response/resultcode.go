package response

// 。

const (
	ResultSuccess             = 200
	ResultFail                = 500
	ResultUnauthorized        = 401
	ResultForbidden           = 403
	ResultNotFound            = 404
	ResultMethodNotAllowed    = 405
	ResultNotAcceptable       = 406
	ResultUnprocessableEntity = 422
	ResultDisabled            = 423
)

// ResultMessageKey 业务码对应的 i18n 键。
func ResultMessageKey(code int) string {
	switch code {
	case ResultSuccess:
		return "result.success"
	case ResultFail:
		return "result.fail"
	case ResultUnauthorized:
		return "result.unauthorized"
	case ResultForbidden:
		return "result.forbidden"
	case ResultNotFound:
		return "result.not_found"
	case ResultMethodNotAllowed:
		return "result.method_not_allowed"
	case ResultNotAcceptable:
		return "result.not_acceptable"
	case ResultUnprocessableEntity:
		return "result.conflict"
	case ResultDisabled:
		return "result.disabled"
	default:
		return "result.fail"
	}
}
