package datascope

import (
	"encoding/json"
	"errors"
	"strconv"
	"strings"

	"fastapp/internal/app/middleware"
	"fastapp/internal/app/model"

	"gorm.io/gorm"
)

const (
	DataScopeAll          = 1
	DataScopeCustom       = 2
	DataScopeDept         = 3
	DataScopeDeptAndChild = 4
	DataScopeSelf         = 5
)

// ApplyUserListScope 。
func ApplyUserListScope(db *gorm.DB, operatorID int64, q *gorm.DB) (*gorm.DB, error) {
	super, err := middleware.IsSuperAdmin(db, operatorID)
	if err != nil {
		return nil, err
	}
	if super {
		return q, nil
	}

	var roles []model.Role
	err = db.Model(&model.Role{}).
		Joins("JOIN "+model.P+"user_belongs_role ur ON ur.role_id = "+model.P+"role.id").
		Where("ur.user_id = ? AND "+model.P+"role.status = ?", operatorID, 1).
		Find(&roles).Error
	if err != nil {
		return nil, err
	}
	if len(roles) == 0 {
		return q.Where(model.P+"user.created_by = ?", operatorID), nil
	}

	scopes := map[int]struct{}{}
	for _, r := range roles {
		scopes[r.DataScope] = struct{}{}
	}
	if _, ok := scopes[DataScopeAll]; ok {
		return q, nil
	}

	if _, ok := scopes[DataScopeCustom]; ok {
		var roleIDs []int64
		for _, r := range roles {
			if r.DataScope == DataScopeCustom {
				roleIDs = append(roleIDs, r.ID)
			}
		}
		var deptIDs []int64
		if len(roleIDs) > 0 {
			if err := db.Model(&model.RoleBelongsDepartment{}).Where("role_id IN ?", roleIDs).Pluck("dept_id", &deptIDs).Error; err != nil {
				return nil, err
			}
		}
		return applyCreatedByDeptFilter(db, q, deptIDs)
	}

	if _, ok := scopes[DataScopeDeptAndChild]; ok {
		udepts, err := userDeptIDs(db, operatorID)
		if err != nil {
			return nil, err
		}
		if len(udepts) == 0 {
			return q.Where("1 = 0"), nil
		}
		all, err := expandDeptWithChildren(db, udepts)
		if err != nil {
			return nil, err
		}
		return applyCreatedByDeptFilter(db, q, all)
	}

	if _, ok := scopes[DataScopeDept]; ok {
		udepts, err := userDeptIDs(db, operatorID)
		if err != nil {
			return nil, err
		}
		return applyCreatedByDeptFilter(db, q, udepts)
	}

	return q.Where(model.P+"user.created_by = ?", operatorID), nil
}

func userDeptIDs(db *gorm.DB, userID int64) ([]int64, error) {
	var s model.UserAdminSetting
	err := db.Where("user_id = ?", userID).First(&s).Error
	if errors.Is(err, gorm.ErrRecordNotFound) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if len(s.DeptID) == 0 {
		return nil, nil
	}
	var arr []int64
	if err := json.Unmarshal(s.DeptID, &arr); err != nil {
		return nil, err
	}
	return arr, nil
}

func expandDeptWithChildren(db *gorm.DB, rootIDs []int64) ([]int64, error) {
	var all []model.Department
	if err := db.Model(&model.Department{}).Find(&all).Error; err != nil {
		return nil, err
	}
	byParent := map[int64][]int64{}
	for _, d := range all {
		byParent[d.ParentID] = append(byParent[d.ParentID], d.ID)
	}
	seen := map[int64]struct{}{}
	var walk func(int64)
	walk = func(id int64) {
		if _, ok := seen[id]; ok {
			return
		}
		seen[id] = struct{}{}
		for _, ch := range byParent[id] {
			walk(ch)
		}
	}
	for _, rid := range rootIDs {
		walk(rid)
	}
	out := make([]int64, 0, len(seen))
	for id := range seen {
		out = append(out, id)
	}
	return out, nil
}

func userIDsInDepts(db *gorm.DB, deptIDs []int64) ([]int64, error) {
	if len(deptIDs) == 0 {
		return nil, nil
	}
	parts := make([]string, 0, len(deptIDs))
	args := make([]any, 0, len(deptIDs))
	for _, did := range deptIDs {
		parts = append(parts, "JSON_CONTAINS("+model.P+"user_admin_setting.dept_id, CAST(? AS JSON), '$')")
		args = append(args, strconv.FormatInt(did, 10))
	}
	var uids []int64
	sql := "SELECT user_id FROM " + model.P + "user_admin_setting WHERE " + strings.Join(parts, " OR ")
	if err := db.Raw(sql, args...).Pluck("user_id", &uids).Error; err != nil {
		return nil, err
	}
	return uids, nil
}

func applyCreatedByDeptFilter(db *gorm.DB, q *gorm.DB, deptIDs []int64) (*gorm.DB, error) {
	if len(deptIDs) == 0 {
		return q.Where("1 = 0"), nil
	}
	uids, err := userIDsInDepts(db, deptIDs)
	if err != nil {
		return nil, err
	}
	if len(uids) == 0 {
		return q.Where("1 = 0"), nil
	}
	return q.Where(model.P+"user.created_by IN ?", uids), nil
}

// ClearUserScopeCache 占位：。
func ClearUserScopeCache(_ *gorm.DB, _ int64) {}
