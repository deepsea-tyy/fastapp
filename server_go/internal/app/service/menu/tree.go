package menu

import (
	"encoding/json"
	"time"

	"fastapp/internal/app/model"
)

// BuildTree 将扁平菜单转为树（parent_id=0 为根）
func BuildTree(flat []model.Menu) []map[string]any {
	byID := make(map[int64]*mapNode, len(flat))
	var roots []*mapNode
	for i := range flat {
		m := flat[i]
		n := &mapNode{Menu: m}
		byID[m.ID] = n
	}
	for i := range flat {
		m := flat[i]
		n := byID[m.ID]
		if m.ParentID == 0 {
			roots = append(roots, n)
			continue
		}
		if p, ok := byID[m.ParentID]; ok {
			p.Children = append(p.Children, n)
		} else {
			roots = append(roots, n)
		}
	}
	out := make([]map[string]any, 0, len(roots))
	for _, r := range roots {
		out = append(out, r.toMap())
	}
	return out
}

type mapNode struct {
	Menu     model.Menu
	Children []*mapNode
}

func (n *mapNode) toMap() map[string]any {
	ch := make([]any, 0, len(n.Children))
	for _, c := range n.Children {
		ch = append(ch, c.toMap())
	}
	var meta any = map[string]any{}
	if len(n.Menu.Meta) > 0 {
		_ = json.Unmarshal(n.Menu.Meta, &meta)
	}
	m := map[string]any{
		"id":         n.Menu.ID,
		"parent_id":  n.Menu.ParentID,
		"name":       n.Menu.Name,
		"component":  n.Menu.Component,
		"redirect":   n.Menu.Redirect,
		"path":       n.Menu.Path,
		"status":     n.Menu.Status,
		"meta":       meta,
		"sort":       n.Menu.Sort,
		"remark":     n.Menu.Remark,
		"children":   ch,
		"created_by": n.Menu.CreatedBy,
		"updated_by": n.Menu.UpdatedBy,
	}
	if !n.Menu.CreatedAt.IsZero() {
		m["created_at"] = n.Menu.CreatedAt.Format(time.RFC3339)
	}
	if !n.Menu.UpdatedAt.IsZero() {
		m["updated_at"] = n.Menu.UpdatedAt.Format(time.RFC3339)
	}
	return m
}
