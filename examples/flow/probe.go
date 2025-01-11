package probe

func loadObjects() (*probeObjects, error) {
 objs := probeObjects{}

 if err := loadProbeObjects(&objs, nil); err != nil {
  return nil, err
 }

 return &objs, nil
}