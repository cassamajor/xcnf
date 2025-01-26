package probe

import (
	"log"

	"golang.org/x/sys/unix"
)

const (
	tenMB    = 1024 * 1024 * 10
	twentyMB = tenMB * 2
	fortyMB  = tenMB * 4
)

func setRlimit() error {
	log.Println("Setting rlimit")

	return unix.Setrlimit(unix.RLIMIT_MEMLOCK, &unix.Rlimit{
		Cur: twentyMB,
		Max: fortyMB,
	})
}
