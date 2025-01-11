package probe

import (
 "testing"

 "github.com/stretchr/testify/require"
)

func TestProbeLoad(t *testing.T) {
 _, err := loadObjects()

 require.NoError(t, err)
}

func TestPacket(t *testing.T) {

 objs, err := loadObjects()

 require.NoError(t, err)

 in := []byte{1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 1, 2, 3, 4, 5}

 ret, out, err := objs.Flat.Test(in)

 require.NoError(t, err)
 require.Equal(t, uint32(0), ret)
 require.Equal(t, in, out)
}