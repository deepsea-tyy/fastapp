package main

import (
	"log/slog"
	"os"

	"fastapp/internal/cli"
)

func main() {
	if err := cli.Execute(); err != nil {
		slog.Error("cli", "err", err)
		os.Exit(1)
	}
}
