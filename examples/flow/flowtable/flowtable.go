package flowtable

import (
	"log"
	"sync"
	"time"

	"github.com/cassamajor/xcnf/examples/flow/timer"
)

type FlowTable struct {
	Ticker *time.Ticker
	sync.Map
}

// NewFlowTable creates a new flow table
func NewFlowTable() *FlowTable {
	return &FlowTable{
		Ticker: time.NewTicker(time.Second  * 10),
	}
}

// Insert stores a hash and a timestamp in the flow table as key/value pairs
func (table *FlowTable) Insert(hash, timestamp uint64) {
	table.Store(hash, timestamp)
}

// Get returns the value of a provided key
func (table *FlowTable) Get(hash uint64) (uint64, bool) {
	value, ok := table.Load(hash)

	if !ok {
		return 0, ok
	}

	return value.(uint64), ok
}

// Remove deletes a flow hash and its timestamp from the flow table
func (table *FlowTable) Remove(hash uint64) {
	_, found := table.Load(hash)

	if found {
		table.Delete(hash)
	} else {
		log.Printf("hash %v is not in flow table", hash)
	}
}

// Prune removes entries from the flow table that are older than 10 seconds.
func (table *FlowTable) Prune() {
	now := timer.GetNanosecSeinceBoot()	

	table.Range(func(hash, timestamp interface{}) bool {
		if (now-timestamp.(uint64))/1000000 > 10000 {
			log.Printf("Pruning stale entry from flow table: %v", hash)

			table.Delete(hash)

			return true
		}

		return false
	})
}