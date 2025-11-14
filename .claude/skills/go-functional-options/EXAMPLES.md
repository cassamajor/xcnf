# Go Functional Options Pattern - Complete Examples

This file contains complete, production-ready code examples demonstrating different implementations of the Functional Options Pattern. These examples complement the [SKILL.md](SKILL.md) guidance.

## Table of Contents

1. [Closure-Based Examples](#closure-based-examples)
   - [Line Counter](#example-1-line-counter-closure-based)
   - [Text Matcher](#example-2-text-matcher-closure-based)
2. [Interface-Based Examples](#interface-based-examples)
   - [Database Connection (Uber Style)](#example-3-database-connection-interface-based)
3. [Generic Interface Examples](#generic-interface-examples)
   - [Reusable Option Utilities](#example-4-generic-interface-based-options)

---

## Closure-Based Examples

The following examples use the closure-based pattern with error handling, ideal for application code and CLI tools.

### Example 1: Line Counter (Closure-Based)

A complete implementation of a line counter that demonstrates error handling and file I/O.

**Why closure-based?**
- Options need error handling (`WithInputFromArgs` can fail when opening files)
- Application code (CLI tool), not a reusable library
- Simplicity and readability are priorities
- Dynamic validation during option application

```go
package count

import (
    "bufio"
    "errors"
    "fmt"
    "io"
    "os"
)

// counter is the main struct that holds configuration
type counter struct {
    files  []io.Reader
    input  io.Reader
    output io.Writer
}

// option is the functional option type
type option func(*counter) error

// WithInput sets a custom input reader
func WithInput(input io.Reader) option {
    return func(c *counter) error {
        if input == nil {
            return errors.New("nil input reader")
        }
        c.input = input
        return nil
    }
}

// WithInputFromArgs opens files from command-line arguments
func WithInputFromArgs(args []string) option {
    return func(c *counter) error {
        if len(args) < 1 {
            return nil // Empty args is valid - use default stdin
        }
        c.files = make([]io.Reader, len(args))
        for i, path := range args {
            f, err := os.Open(path)
            if err != nil {
                return err
            }
            c.files[i] = f
        }
        c.input = io.MultiReader(c.files...)
        return nil
    }
}

// WithOutput sets a custom output writer
func WithOutput(output io.Writer) option {
    return func(c *counter) error {
        if output == nil {
            return errors.New("nil output writer")
        }
        c.output = output
        return nil
    }
}

// NewCounter creates a new counter with the given options
func NewCounter(opts ...option) (*counter, error) {
    c := &counter{
        input:  os.Stdin,  // Sensible defaults
        output: os.Stdout,
    }
    for _, opt := range opts {
        err := opt(c)
        if err != nil {
            return nil, err
        }
    }
    return c, nil
}

// Lines counts the lines in the input
func (c *counter) Lines() int {
    lines := 0
    input := bufio.NewScanner(c.input)
    for input.Scan() {
        lines++
    }
    // Clean up file handles if any were opened
    for _, f := range c.files {
        f.(io.Closer).Close()
    }
    return lines
}

// Main function showing CLI usage
func Main() {
    c, err := NewCounter(
        WithInputFromArgs(os.Args[1:]),
    )
    if err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
    fmt.Println(c.Lines())
}
```

**Usage:**
```bash
# Count lines from stdin
echo -e "line1\nline2\nline3" | counter

# Count lines from files
counter file1.txt file2.txt
```

---

### Example 2: Text Matcher (Closure-Based)

A simpler example showing pattern matching with functional options.

**Key characteristics:**
- Error handling for nil input validation
- Simple, readable option factories
- Appropriate for CLI application code
- Demonstrates real-world text processing tool pattern

```go
package match

import (
    "bufio"
    "errors"
    "fmt"
    "io"
    "os"
    "strings"
)

type matcher struct {
    input  io.Reader
    output io.Writer
    text   string
}

type option func(*matcher) error

func WithInput(input io.Reader) option {
    return func(m *matcher) error {
        if input == nil {
            return errors.New("nil input reader")
        }
        m.input = input
        return nil
    }
}

func WithSearchTextFromArgs(args []string) option {
    return func(m *matcher) error {
        if len(args) < 1 {
            return nil
        }
        m.text = args[0]
        return nil
    }
}

func WithOutput(output io.Writer) option {
    return func(m *matcher) error {
        if output == nil {
            return errors.New("nil output writer")
        }
        m.output = output
        return nil
    }
}

func NewMatcher(opts ...option) (*matcher, error) {
    m := &matcher{
        input:  os.Stdin,
        output: os.Stdout,
    }
    for _, opt := range opts {
        err := opt(m)
        if err != nil {
            return nil, err
        }
    }
    return m, nil
}

func (m *matcher) PrintMatchingLines() {
    input := bufio.NewScanner(m.input)
    for input.Scan() {
        if strings.Contains(input.Text(), m.text) {
            fmt.Fprintln(m.output, input.Text())
        }
    }
}

func Main() {
    m, err := NewMatcher(
        WithSearchTextFromArgs(os.Args[1:]),
    )
    if err != nil {
        fmt.Fprintln(os.Stderr, err)
        os.Exit(1)
    }
    m.PrintMatchingLines()
}
```

**Usage:**
```bash
# Find lines containing "error"
cat logfile.txt | match error
```

---

## Interface-Based Examples

The following examples use Uber's interface-based pattern for maximum testability and debuggability.

### Example 3: Database Connection (Interface-Based)

Complete implementation using Uber's recommended pattern.

**Why interface-based?**
- Library code for external consumption
- Options need to be testable/comparable
- Can implement `fmt.Stringer` for debugging
- No dynamic validation needed during application

```go
package db

import (
    "fmt"
    "time"

    "go.uber.org/zap"
)

// options holds internal configuration
type options struct {
    cache        bool
    logger       *zap.Logger
    timeout      time.Duration
    maxConns     int
}

// Option is the public option interface
type Option interface {
    apply(*options)
}

// cacheOption configures caching
type cacheOption bool

func (c cacheOption) apply(opts *options) {
    opts.cache = bool(c)
}

func (c cacheOption) String() string {
    return fmt.Sprintf("WithCache(%v)", bool(c))
}

// WithCache enables or disables caching
func WithCache(c bool) Option {
    return cacheOption(c)
}

// loggerOption configures the logger
type loggerOption struct {
    Log *zap.Logger
}

func (l loggerOption) apply(opts *options) {
    opts.logger = l.Log
}

func (l loggerOption) String() string {
    return "WithLogger(<logger>)"
}

// WithLogger sets a custom logger
func WithLogger(log *zap.Logger) Option {
    return loggerOption{Log: log}
}

// timeoutOption configures connection timeout
type timeoutOption time.Duration

func (t timeoutOption) apply(opts *options) {
    opts.timeout = time.Duration(t)
}

func (t timeoutOption) String() string {
    return fmt.Sprintf("WithTimeout(%v)", time.Duration(t))
}

// WithTimeout sets the connection timeout
func WithTimeout(d time.Duration) Option {
    return timeoutOption(d)
}

// maxConnsOption configures max connections
type maxConnsOption int

func (m maxConnsOption) apply(opts *options) {
    opts.maxConns = int(m)
}

func (m maxConnsOption) String() string {
    return fmt.Sprintf("WithMaxConns(%d)", int(m))
}

// WithMaxConns sets the maximum number of connections
func WithMaxConns(n int) Option {
    return maxConnsOption(n)
}

// Connection represents a database connection
type Connection struct {
    opts options
}

// Open creates a new database connection
func Open(addr string, opts ...Option) (*Connection, error) {
    options := options{
        cache:    true,              // Default values
        logger:   zap.NewNop(),
        timeout:  5 * time.Second,
        maxConns: 10,
    }

    for _, o := range opts {
        o.apply(&options)
    }

    // Use options to configure connection
    conn := &Connection{opts: options}

    options.logger.Info("opening connection",
        zap.String("addr", addr),
        zap.Bool("cache", options.cache),
        zap.Duration("timeout", options.timeout),
    )

    return conn, nil
}
```

**Usage:**
```go
// Minimal configuration
conn, err := db.Open("localhost:5432")

// With custom options
conn, err := db.Open("localhost:5432",
    db.WithCache(false),
    db.WithLogger(logger),
    db.WithTimeout(10*time.Second),
    db.WithMaxConns(50),
)
```

**Testing:**
```go
func TestOptions(t *testing.T) {
    t.Parallel()

    // Options are comparable
    opt1 := db.WithCache(true)
    opt2 := db.WithCache(true)
    if opt1 != opt2 {
        t.Error("expected equal options")
    }

    // Can test String() for debugging
    got := db.WithTimeout(5 * time.Second).String()
    want := "WithTimeout(5s)"
    if got != want {
        t.Errorf("got %q, want %q", got, want)
    }
}
```

---

## Generic Interface Examples

Advanced examples combining generics with interface-based options for maximum reusability.

### Example 4: Generic Interface-Based Options

Reusable option utilities that work across multiple configuration types.

**Why generic interfaces?**
- Creating option utility libraries
- Same option pattern applies to multiple config types
- Type safety and testability both critical
- Maximum code reuse

```go
package options

import (
    "fmt"
    "time"
)

// Option is a generic option interface
type Option[T any] interface {
    apply(*T)
    fmt.Stringer
}

// fieldSetter is a generic option that sets a field
type fieldSetter[T any, V comparable] struct {
    value  V
    setter func(*T, V)
    name   string
}

func (f fieldSetter[T, V]) apply(cfg *T) {
    f.setter(cfg, f.value)
}

func (f fieldSetter[T, V]) String() string {
    return fmt.Sprintf("%s(%v)", f.name, f.value)
}

// WithField creates a generic option for any field
func WithField[T any, V comparable](
    name string,
    setter func(*T, V),
    value V,
) Option[T] {
    return fieldSetter[T, V]{
        value:  value,
        setter: setter,
        name:   name,
    }
}

// Timeout option that works with any config
type timeoutOption[T any] struct {
    duration time.Duration
    setter   func(*T, time.Duration)
}

func (t timeoutOption[T]) apply(cfg *T) {
    t.setter(cfg, t.duration)
}

func (t timeoutOption[T]) String() string {
    return fmt.Sprintf("WithTimeout(%v)", t.duration)
}

// WithTimeout creates a timeout option for any config type
func WithTimeout[T any](
    d time.Duration,
    setter func(*T, time.Duration),
) Option[T] {
    return timeoutOption[T]{duration: d, setter: setter}
}

// ApplyOptions applies options to a configuration
func ApplyOptions[T any](cfg *T, opts ...Option[T]) {
    for _, opt := range opts {
        opt.apply(cfg)
    }
}
```

**Usage with multiple types:**
```go
// Database config
type DBConfig struct {
    ConnTimeout time.Duration
    QueryTimeout time.Duration
    MaxConns int
}

// HTTP config
type HTTPConfig struct {
    ReadTimeout time.Duration
    WriteTimeout time.Duration
    MaxRequests int
}

// Use the same option utilities with different types
func main() {
    dbConfig := &DBConfig{MaxConns: 5}
    ApplyOptions(dbConfig,
        WithTimeout(10*time.Second, func(c *DBConfig, d time.Duration) {
            c.ConnTimeout = d
        }),
        WithField("MaxConns", func(c *DBConfig, n int) {
            c.MaxConns = n
        }, 100),
    )

    httpConfig := &HTTPConfig{MaxRequests: 50}
    ApplyOptions(httpConfig,
        WithTimeout(30*time.Second, func(c *HTTPConfig, d time.Duration) {
            c.ReadTimeout = d
        }),
        WithField("MaxRequests", func(c *HTTPConfig, n int) {
            c.MaxRequests = n
        }, 1000),
    )
}
```

**Testing:**
```go
func TestGenericOptions(t *testing.T) {
    t.Parallel()

    type Config struct {
        Timeout time.Duration
        Value   int
    }

    cfg := &Config{}

    opts := []Option[Config]{
        WithTimeout(5*time.Second, func(c *Config, d time.Duration) {
            c.Timeout = d
        }),
        WithField("Value", func(c *Config, v int) {
            c.Value = v
        }, 42),
    }

    ApplyOptions(cfg, opts...)

    if cfg.Timeout != 5*time.Second {
        t.Errorf("expected timeout 5s, got %v", cfg.Timeout)
    }
    if cfg.Value != 42 {
        t.Errorf("expected value 42, got %d", cfg.Value)
    }

    // Options are still comparable and have String()
    opt := WithField("Value", func(c *Config, v int) { c.Value = v }, 42)
    if got := opt.String(); got != "Value(42)" {
        t.Errorf("expected String() = %q, got %q", "Value(42)", got)
    }
}
```

---

## Summary

- **Closure-based**: Best for applications with error handling needs (Examples 1-2)
- **Interface-based**: Best for libraries requiring testability (Example 3)
- **Generic interface**: Best for reusable option utilities across types (Example 4)

Refer back to [SKILL.md](SKILL.md) for guidance on choosing between these approaches.
