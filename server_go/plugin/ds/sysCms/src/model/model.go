package model

import (
	"encoding/json"
	"time"

	basemodel "fastapp/internal/app/model"
)

// Article 表 article。
type Article struct {
	ID           int64     `gorm:"primaryKey;autoIncrement"`
	Title        string    `gorm:"size:255"`
	Subtitle     string    `gorm:"size:255"`
	Lang         string    `gorm:"size:8"`
	Author       string    `gorm:"size:32"`
	Cover        string    `gorm:"size:255"`
	Video        string    `gorm:"size:255"`
	ReleaseAt    string    `gorm:"column:release_at;size:8"`
	Brief        string    `gorm:"size:300"`
	Content      string    `gorm:"type:text"`
	Remark       string    `gorm:"size:255"`
	Sort         int       `gorm:"default:100"`
	ViewCount    int       `gorm:"column:view_count"`
	LikeCount    int       `gorm:"column:like_count"`
	CommentCount int       `gorm:"column:comment_count"`
	ShareCount   int       `gorm:"column:share_count"`
	CollectCount int       `gorm:"column:collect_count"`
	Status       int       `gorm:"default:1"`
	Code         *string   `gorm:"size:32;uniqueIndex"`
	CreatedBy    *int64    `gorm:"column:created_by"`
	UpdatedBy    *int64    `gorm:"column:updated_by"`
	CreatedAt    time.Time `gorm:"column:created_at"`
	UpdatedAt    time.Time `gorm:"column:updated_at"`
}

func (Article) TableName() string { return basemodel.P + "article" }

// Category 表 category。
type Category struct {
	ID        int64           `gorm:"primaryKey;autoIncrement"`
	Name      json.RawMessage `gorm:"type:json"`
	Icon      string          `gorm:"size:255"`
	Sort      int             `gorm:"default:100"`
	ParentID  int64           `gorm:"column:parent_id;default:0"`
	Status    int             `gorm:"default:1"`
	Remark    string          `gorm:"size:255"`
	Code      *string         `gorm:"size:32;index"`
	CreatedBy *int64          `gorm:"column:created_by"`
	UpdatedBy *int64          `gorm:"column:updated_by"`
	CreatedAt time.Time       `gorm:"column:created_at"`
	UpdatedAt time.Time       `gorm:"column:updated_at"`
}

func (Category) TableName() string { return basemodel.P + "category" }

// CategoryCorrelation 表 category_correlation。
type CategoryCorrelation struct {
	ID         int64  `gorm:"primaryKey;autoIncrement"`
	CategoryID *int64 `gorm:"column:category_id;index"`
	DataID     *int64 `gorm:"column:data_id"`
	Type       *int   `gorm:"column:type"`
}

func (CategoryCorrelation) TableName() string { return basemodel.P + "category_correlation" }

// PlacementPosition 表 placement_position。
type PlacementPosition struct {
	ID        int64     `gorm:"primaryKey;autoIncrement"`
	Code      *string   `gorm:"size:32;uniqueIndex"`
	Name      string    `gorm:"size:128"`
	Status    int       `gorm:"default:1"`
	CreatedBy *int64    `gorm:"column:created_by"`
	UpdatedBy *int64    `gorm:"column:updated_by"`
	CreatedAt time.Time `gorm:"column:created_at"`
	UpdatedAt time.Time `gorm:"column:updated_at"`
}

func (PlacementPosition) TableName() string { return basemodel.P + "placement_position" }

// PlacementContent 表 placement_content。
type PlacementContent struct {
	ID         int64           `gorm:"primaryKey;autoIncrement"`
	Code       *string         `gorm:"size:32;uniqueIndex"`
	Name       string          `gorm:"size:128"`
	ObjectType int             `gorm:"column:object_type;default:1"`
	ObjectID   int64           `gorm:"column:object_id;default:0"`
	URL        string          `gorm:"size:512"`
	Target     int             `gorm:"default:1"`
	Title      json.RawMessage `gorm:"type:json"`
	Cover      string          `gorm:"size:512"`
	Desc       json.RawMessage `gorm:"type:json"`
	Content    json.RawMessage `gorm:"type:json"`
	StartAt    *int            `gorm:"column:start_at"`
	EndAt      *int            `gorm:"column:end_at"`
	Fixed      int             `gorm:"default:0"`
	Status     int             `gorm:"default:1"`
	Sort       int             `gorm:"default:0"`
	Remark     string          `gorm:"size:255"`
	Views      int             `gorm:"default:0"`
	Clicks     int             `gorm:"default:0"`
	CreatedBy  *int64          `gorm:"column:created_by"`
	UpdatedBy  *int64          `gorm:"column:updated_by"`
	CreatedAt  time.Time       `gorm:"column:created_at"`
	UpdatedAt  time.Time       `gorm:"column:updated_at"`
}

func (PlacementContent) TableName() string { return basemodel.P + "placement_content" }

// PlacementPositionContent 表 placement_position_content。
type PlacementPositionContent struct {
	ID         int64     `gorm:"primaryKey;autoIncrement"`
	PositionID int64     `gorm:"column:position_id;index"`
	ContentID  int64     `gorm:"column:content_id;index"`
	CreatedAt  time.Time `gorm:"column:created_at"`
	UpdatedAt  time.Time `gorm:"column:updated_at"`
}

func (PlacementPositionContent) TableName() string { return basemodel.P + "placement_position_content" }

// AppPageContent 表 app_page_content。
type AppPageContent struct {
	ID            int64           `gorm:"primaryKey;autoIncrement"`
	Code          *string         `gorm:"size:64;uniqueIndex"`
	PageCode      string          `gorm:"column:page_code;size:32"`
	ComponentCode *string         `gorm:"column:component_code;size:32"`
	ContentType   int             `gorm:"column:content_type;default:1"`
	Data          json.RawMessage `gorm:"type:json"`
	Platform      int             `gorm:"default:2"`
	StartAt       *int            `gorm:"column:start_at"`
	EndAt         *int            `gorm:"column:end_at"`
	Fixed         int             `gorm:"default:1"`
	Status        int             `gorm:"default:1"`
	Sort          int             `gorm:"default:100"`
	Remark        string          `gorm:"size:255"`
	CreatedBy     *int64          `gorm:"column:created_by"`
	UpdatedBy     *int64          `gorm:"column:updated_by"`
	CreatedAt     time.Time       `gorm:"column:created_at"`
	UpdatedAt     time.Time       `gorm:"column:updated_at"`
}

func (AppPageContent) TableName() string { return basemodel.P + "app_page_content" }

// AppPageContentSync 表 app_page_content_sync。
type AppPageContentSync struct {
	ID          int64      `gorm:"primaryKey;autoIncrement"`
	Version     string     `gorm:"size:32;index"`
	Platform    int        `gorm:"index"`
	FilePath    string     `gorm:"column:file_path;size:255"`
	FileSize    int        `gorm:"column:file_size"`
	RecordCount int        `gorm:"column:record_count"`
	GeneratedAt *time.Time `gorm:"column:generated_at"`
	CreatedAt   time.Time  `gorm:"column:created_at"`
	UpdatedAt   time.Time  `gorm:"column:updated_at"`
}

func (AppPageContentSync) TableName() string { return basemodel.P + "app_page_content_sync" }
