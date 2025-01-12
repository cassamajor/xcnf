package main

import 	"github.com/cassamajor/xcnf/examples/flow/bytecode"

func loadObjects() (*bytecode.ProbeObjects, error) {
 objs := bytecode.ProbeObjects{}

 if err := bytecode.LoadProbeObjects(&objs, nil); err != nil {
  return nil, err
 }

 return &objs, nil
}