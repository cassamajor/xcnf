package main

import (
	"log"

	"github.com/cassamajor/xcnf/examples/flow/bytecode"
)

func loadObjects() (*bytecode.ProbeObjects, error) {
 var objs bytecode.ProbeObjects

 if err := bytecode.LoadProbeObjects(&objs, nil); err != nil {
  return nil, err
 }

 return &objs, nil
}

func main() {
var objs bytecode.ProbeObjects

 if err := bytecode.LoadProbeObjects(&objs, nil); err != nil {
    log.Fatal("Loading eBPF objects:", err)
 }
}