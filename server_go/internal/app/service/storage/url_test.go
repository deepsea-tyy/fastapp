package storage

import "testing"

func TestObjectKeyFromPublicURL_Local(t *testing.T) {
	k, err := ObjectKeyFromPublicURL("/uploads/20250329/abc.png", "local")
	if err != nil {
		t.Fatal(err)
	}
	if k != "20250329/abc.png" {
		t.Fatalf("got %q", k)
	}
}

func TestObjectKeyFromPublicURL_Cloud(t *testing.T) {
	k, err := ObjectKeyFromPublicURL("https://cdn.example.com/20250329/abc.png", "oss")
	if err != nil {
		t.Fatal(err)
	}
	if k != "20250329/abc.png" {
		t.Fatalf("got %q", k)
	}
}
