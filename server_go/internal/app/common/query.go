package tools

import (
	"encoding/json"
	"fmt"
	"io"
	"strconv"

	"fastapp/internal/app/common/response"

	"github.com/gin-gonic/gin"
)

// ParsePage 解析 page / page_size，默认 1 / 10。
func ParsePage(c *gin.Context) (page, pageSize int) {
	page, pageSize = 1, 10
	_, _ = fmt.Sscan(c.Query("page"), &page)
	_, _ = fmt.Sscan(c.Query("page_size"), &pageSize)
	if page < 1 {
		page = 1
	}
	if pageSize < 1 {
		pageSize = 10
	}
	return page, pageSize
}

// ParseIDParam 解析路径参数 id；失败时写 JSON 422 风格业务响应并返回 ok=false。
func ParseIDParam(c *gin.Context, name string) (id int64, ok bool) {
	s := c.Param(name)
	if s == "" {
		response.JSON(c, 200, response.WithCode(response.CodeUnprocessable, "id required", nil))
		return 0, false
	}
	n, err := strconv.ParseInt(s, 10, 64)
	if err != nil || n <= 0 {
		response.JSON(c, 200, response.WithCode(response.CodeUnprocessable, "id invalid", nil))
		return 0, false
	}
	return n, true
}

// ParseFlexibleIDList 解析 DELETE 请求体：JSON 数组或 {"ids":[...]}。
func ParseFlexibleIDList(c *gin.Context) ([]int64, error) {
	raw, err := io.ReadAll(c.Request.Body)
	if err != nil {
		return nil, err
	}
	var arr []int64
	if json.Unmarshal(raw, &arr) == nil && len(arr) > 0 {
		return arr, nil
	}
	var wrap struct {
		IDs []int64 `json:"ids"`
	}
	if json.Unmarshal(raw, &wrap) == nil && len(wrap.IDs) > 0 {
		return wrap.IDs, nil
	}
	if json.Unmarshal(raw, &wrap) == nil {
		return wrap.IDs, nil
	}
	return arr, nil
}
