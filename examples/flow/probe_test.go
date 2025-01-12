package main

import (
 "testing"

 "github.com/stretchr/testify/require"
 "os"

)

func TestProbeLoad(t *testing.T) {
 _, err := loadObjects()

 require.NoError(t, err)
}

func TestMain(m *testing.M) {
    exitCode := m.Run()
    os.Exit(exitCode)
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