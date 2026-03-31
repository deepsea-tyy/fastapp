package websocket

import (
	"encoding/json"
	"time"
)

// Response
type Response struct {
	Success   bool           `json:"success"`
	OpID      string         `json:"op_id"`
	Message   string         `json:"message,omitempty"`
	Data      map[string]any `json:"data,omitempty"`
	Timestamp int64          `json:"timestamp"`
}

func SuccessResp(data map[string]any, message, opID string) Response {
	r := Response{Success: true, OpID: opID, Message: message, Timestamp: time.Now().Unix()}
	if len(data) > 0 {
		r.Data = data
	}
	return r
}

func ErrorResp(message, opID string) Response {
	return Response{Success: false, OpID: opID, Message: message, Timestamp: time.Now().Unix()}
}

func (r Response) WithOpID(id string) Response {
	r.OpID = id
	return r
}

func (r Response) JSON() []byte {
	b, _ := json.Marshal(r)
	return b
}
