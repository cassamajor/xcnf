package probe

import (
	"log"

	"github.com/cassamajor/xcnf/examples/flow/bytecode"
	"golang.org/x/sys/unix"
)

const (
	tenMB    = 1024 * 1024 * 10
	twentyMB = tenMB * 2
	fortyMB  = tenMB * 4
)

func loadObjects() (*bytecode.ProbeObjects, error) {
	var objs bytecode.ProbeObjects

	if err := bytecode.LoadProbeObjects(&objs, nil); err != nil {
		return nil, err
	}

	return &objs, nil
}

func setRlimit() error {
	log.Println("Setting rlimit")

	return unix.Setrlimit(unix.RLIMIT_MEMLOCK, &unix.Rlimit{
		Cur: twentyMB,
		Max: fortyMB,
	})
}
