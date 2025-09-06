package timer

import (
	"log"
	"time"

	"golang.org/x/sys/unix"
)

// GetNanosecSeinceBoot returns the nanoseconds since system boot time
func GetNanosecSeinceBoot() uint64 {
	var ts unix.Timespec

	err := unix.ClockGettime(unix.CLOCK_MONOTONIC, &ts)

	if err != nil {
		log.Println("Cloud not get MONOTONIC Clock time ", err)
		return 0
	}

	seconds := ts.Sec*int64(time.Second)
	nanoseconds := ts.Nsec + seconds

	return uint64(nanoseconds)
}