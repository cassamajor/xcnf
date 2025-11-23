# eBPF Test Harness - Complete Examples

This file contains complete, production-ready test examples demonstrating testing patterns for eBPF CNF programs. These examples complement the [SKILL.md](SKILL.md) guidance.

## Table of Contents

1. [Using stretchr/testify](#using-stretchrtestify)
2. [Table-Driven Tests with Cleanup](#table-driven-tests-with-cleanup)

---

## Using stretchr/testify

The testify library provides cleaner assertions than standard library testing. Use `require` for fatal assertions and `assert` for non-fatal ones.

### Example: Netkit Pair Creation Tests

From `examples/netkit-ipv6/netkit/netkit_test.go`:

```go
package netkit

import (
    "os"
    "testing"

    "github.com/stretchr/testify/assert"
    "github.com/stretchr/testify/require"
)

func TestCreatePair(t *testing.T) {
    if os.Geteuid() != 0 {
        t.Skip("Requires root privileges")
    }

    tests := []struct {
        name    string
        devName string
        opts    []Option
        wantErr bool
    }{
        {
            name:    "create L3 pair",
            devName: "test0",
            opts:    []Option{WithL3Mode()},
            wantErr: false,
        },
        {
            name:    "create with no scrub",
            devName: "test1",
            opts:    []Option{WithL3Mode(), WithNoScrub()},
            wantErr: false,
        },
        {
            name:    "empty name fails",
            devName: "",
            opts:    []Option{},
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            pair, err := CreatePair(tt.devName, tt.opts...)

            if tt.wantErr {
                assert.Error(t, err)
                return
            }

            // require stops test immediately on failure
            require.NoError(t, err)
            require.NotNil(t, pair)
            defer pair.Delete()

            // assert continues test even if assertion fails
            assert.NotNil(t, pair.Primary)
            assert.NotNil(t, pair.Peer)
            assert.Greater(t, pair.PrimaryIdx, 0)
            assert.Greater(t, pair.PeerIdx, 0)

            // Verify naming convention
            assert.Equal(t, tt.devName, pair.Primary.Attrs().Name)
            assert.Equal(t, tt.devName+"p", pair.Peer.Attrs().Name)
        })
    }
}

func TestDelete(t *testing.T) {
    if os.Geteuid() != 0 {
        t.Skip("Requires root privileges")
    }

    pair, err := CreatePair("test_del", WithL3Mode())
    require.NoError(t, err)

    err = pair.Delete()
    assert.NoError(t, err)

    // Delete should be idempotent
    err = pair.Delete()
    assert.NoError(t, err)
}
```

### require vs assert

| Function | Behavior | Use When |
|----------|----------|----------|
| `require.NoError(t, err)` | Stops test immediately | Error makes rest of test meaningless |
| `assert.NoError(t, err)` | Continues test | Want to see all failures |
| `require.NotNil(t, obj)` | Stops test immediately | Will dereference obj next |
| `assert.Equal(t, want, got)` | Continues test | Checking properties |

### Common testify Patterns

```go
// Check error occurred
assert.Error(t, err)
assert.EqualError(t, err, "expected message")
assert.ErrorContains(t, err, "substring")

// Check no error
require.NoError(t, err)  // Use require when continuing would panic

// Check values
assert.Equal(t, expected, actual)
assert.NotEqual(t, unexpected, actual)
assert.Greater(t, actual, minimum)
assert.Len(t, slice, expectedLen)

// Check nil/not nil
require.NotNil(t, ptr)  // Use require before dereferencing
assert.Nil(t, shouldBeNil)

// Check booleans
assert.True(t, condition)
assert.False(t, condition)
```

---

## Table-Driven Tests with Cleanup

Table-driven tests with proper cleanup ensure resources are released even when tests fail.

### Pattern: defer Cleanup in Test Loop

```go
func TestFeature(t *testing.T) {
    if os.Geteuid() != 0 {
        t.Skip("Requires root privileges")
    }

    tests := []struct {
        name    string
        input   string
        wantErr bool
    }{
        {"valid input", "test0", false},
        {"another valid", "test1", false},
        {"invalid input", "", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            resource, err := CreateResource(tt.input)

            if tt.wantErr {
                assert.Error(t, err)
                return  // Don't defer cleanup - nothing was created
            }

            require.NoError(t, err)
            require.NotNil(t, resource)
            defer resource.Cleanup()  // Always cleanup on success path

            // Test assertions here...
            assert.Equal(t, tt.input, resource.Name())
        })
    }
}
```

### Pattern: Using t.Cleanup

For more complex cleanup or when cleanup order matters:

```go
func TestWithCleanup(t *testing.T) {
    if os.Geteuid() != 0 {
        t.Skip("Requires root privileges")
    }

    // Create resources
    pair, err := CreatePair("test0", WithL3Mode())
    require.NoError(t, err)

    // Register cleanup - runs after test completes
    t.Cleanup(func() {
        pair.Delete()
    })

    // Test logic here...
    assert.Greater(t, pair.PrimaryIdx, 0)
}
```

### Pattern: TestMain for Global Setup/Teardown

```go
func TestMain(m *testing.M) {
    // Check prerequisites
    if os.Geteuid() != 0 {
        fmt.Fprintln(os.Stderr, "Tests require root privileges")
        os.Exit(1)
    }

    // Global setup
    setupTestEnvironment()

    // Run tests
    code := m.Run()

    // Global teardown
    cleanupTestEnvironment()

    os.Exit(code)
}
```

---

## Summary

- **Use testify** for cleaner, more readable assertions
- **require** stops test immediately; use before dereferencing or when error makes test meaningless
- **assert** continues test; use when you want to see all failures
- **defer cleanup** in test loop for per-test resources
- **t.Cleanup** for more complex cleanup scenarios
- **TestMain** for global setup/teardown

See `examples/netkit-ipv6/netkit/netkit_test.go` for a complete working implementation.
