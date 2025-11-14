package netkit

const (
	netkitL2 = 0
	netkitL3 = 1
)

type config struct {
	mode         int
	headroom     int
	tailroom     int
	scrubPrimary bool
	scrubPeer    bool
}

type Option func(*config)

func defaultConfig() *config {
	return &config{
		mode:         netkitL3,
		scrubPrimary: true,
		scrubPeer:    true,
	}
}

func WithL2Mode() Option {
	return func(c *config) {
		c.mode = netkitL2
	}
}

func WithL3Mode() Option {
	return func(c *config) {
		c.mode = netkitL3
	}
}

func WithHeadroom(bytes int) Option {
	return func(c *config) {
		c.headroom = bytes
	}
}

func WithTailroom(bytes int) Option {
	return func(c *config) {
		c.tailroom = bytes
	}
}

func WithNoScrub() Option {
	return func(c *config) {
		c.scrubPrimary = false
		c.scrubPeer = false
	}
}
