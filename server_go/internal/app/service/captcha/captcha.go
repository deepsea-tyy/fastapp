// Package captcha 生成。
package captcha

import (
	"bytes"
	"crypto/rand"
	"encoding/binary"
	"image"
	"image/color"
	"image/draw"
	"image/png"
	"math"

	"golang.org/x/image/font"
	"golang.org/x/image/font/basicfont"
	"golang.org/x/image/math/fixed"
)

const pool = "abcdefghjkmnpqrstuvwxyz23456789"

// RandomCode 生成长度 n 的验证码字符，字符集。
func RandomCode(n int) string {
	b := make([]byte, n)
	_, _ = rand.Read(b)
	s := make([]byte, n)
	for i := range b {
		s[i] = pool[int(b[i])%len(pool)]
	}
	return string(s)
}

// PNG 将验证码渲染为 PNG 字节。
func PNG(code string) ([]byte, error) {
	const w, h = 120, 36
	img := image.NewRGBA(image.Rect(0, 0, w, h))
	rb := make([]byte, 3)
	_, _ = rand.Read(rb)
	bg := color.RGBA{230 + rb[0]%26, 230 + rb[1]%26, 230 + rb[2]%26, 255}
	draw.Draw(img, img.Bounds(), image.NewUniform(bg), image.Point{}, draw.Src)

	face := basicfont.Face7x13
	dr := &font.Drawer{Dst: img, Face: face}
	dot := fixed.P(15, 26)
	for _, ch := range code {
		_, _ = rand.Read(rb)
		tc := color.RGBA{uint8(80 + rb[0]%70), uint8(80 + rb[1]%70), uint8(80 + rb[2]%70), 255}
		dr.Src = image.NewUniform(tc)
		dr.Dot = dot
		dr.DrawString(string(ch))
		dot.X += fixed.I(24)
	}

	for i := 0; i < 5; i++ {
		var buf [8]byte
		_, _ = rand.Read(buf[:])
		x1 := int(binary.LittleEndian.Uint16(buf[0:2])) % w
		y1 := int(binary.LittleEndian.Uint16(buf[2:4])) % h
		x2 := int(binary.LittleEndian.Uint16(buf[4:6])) % w
		y2 := int(binary.LittleEndian.Uint16(buf[6:8])) % h
		_, _ = rand.Read(rb)
		lc := color.RGBA{uint8(180 + rb[0]%50), uint8(180 + rb[1]%50), uint8(180 + rb[2]%50), 255}
		line(img, x1, y1, x2, y2, lc)
	}

	for i := 0; i < 40; i++ {
		var buf [4]byte
		_, _ = rand.Read(buf[:])
		px := int(binary.LittleEndian.Uint16(buf[0:2])) % w
		py := int(binary.LittleEndian.Uint16(buf[2:4])) % h
		_, _ = rand.Read(rb)
		pc := color.RGBA{uint8(150 + rb[0]%50), uint8(150 + rb[1]%50), uint8(150 + rb[2]%50), 255}
		img.Set(px, py, pc)
	}

	var buf bytes.Buffer
	if err := png.Encode(&buf, img); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

func line(img *image.RGBA, x0, y0, x1, y1 int, c color.RGBA) {
	dx := float64(x1 - x0)
	dy := float64(y1 - y0)
	steps := int(math.Max(math.Abs(dx), math.Abs(dy)))
	if steps < 1 {
		steps = 1
	}
	for i := 0; i <= steps; i++ {
		t := float64(i) / float64(steps)
		x := int(float64(x0) + dx*t)
		y := int(float64(y0) + dy*t)
		if x >= 0 && x < img.Bounds().Dx() && y >= 0 && y < img.Bounds().Dy() {
			img.Set(x, y, c)
		}
	}
}
