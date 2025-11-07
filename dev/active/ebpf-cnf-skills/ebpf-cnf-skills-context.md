# eBPF CNF Skills - Context

## SESSION PROGRESS (2025-11-05)

### ✅ COMPLETED
- Created `.claude/skills/` directory structure
- Created all 6 eBPF CNF development skills:
  1. ebpf-cnf-scaffold - Scaffolding new CNF projects
  2. ebpf-packet-parser - Verifier-safe packet parsing
  3. ebpf-map-handler - Map creation and userspace handling
  4. ebpf-attach-hook - Program attachment to kernel hooks
  5. cnf-networking - netkit and tcx infrastructure (kernel 6.6+)
  6. ebpf-test-harness - Test infrastructure and validation
- Updated CLAUDE.md with eBPF development guidance

### 🟡 IN PROGRESS
- None

### ⚠️ BLOCKERS
- None

## Key Files Created

**.claude/skills/ebpf-cnf-scaffold/SKILL.md**
- Scaffolds complete eBPF CNF projects
- Provides templates for C kernel code and Go userspace
- Includes hook-specific boilerplate (XDP, tcx, netkit, kprobe, tracepoint)
- Sets up bpf2go generation and Go modules

**.claude/skills/ebpf-packet-parser/SKILL.md**
- Generates verifier-safe packet parsing code
- Covers Ethernet, IPv4/IPv6, TCP/UDP/ICMP parsing
- Implements IPv4-Mapped IPv6 address handling (RFC4291)
- Provides complete 5-tuple extraction template
- Includes bounds checking patterns required by verifier

**.claude/skills/ebpf-map-handler/SKILL.md**
- Creates eBPF maps (hash, array, ringbuf, LRU, per-CPU)
- Generates C map definitions with proper sizing
- Provides Go code for lookup/update/delete/iterate operations
- Includes ringbuf event streaming patterns
- Complete flow tracker CNF example

**.claude/skills/ebpf-attach-hook/SKILL.md**
- Implements attachment logic for all hook types
- XDP with auto-mode selection (driver/generic)
- TC/tcx with kernel version detection
- netkit (primary and peer attachment)
- kprobe/kretprobe, tracepoint, cgroup hooks
- Multi-interface attachment patterns
- Signal handling and graceful shutdown

**.claude/skills/cnf-networking/SKILL.md**
- **netkit devices** - BPF-programmable network device (kernel 6.6+)
- **tcx (Traffic Control eXpress)** - Modern TC with eBPF (kernel 6.6+)
- Network namespace management
- Virtual interface creation (veth, netkit, bridges)
- Complete multi-namespace CNF testing setups
- Routing configuration and IP forwarding
- Debugging with bpftool and tcpdump

**.claude/skills/ebpf-test-harness/SKILL.md**
- Network namespace setup/teardown for isolated testing
- Virtual interface creation (veth/netkit pairs)
- Traffic generation (ICMP, TCP, UDP)
- Packet injection with gopacket
- Map validation (counters, flow tables)
- Ringbuf event collection and validation
- Complete integration test examples
- Benchmarking patterns

**CLAUDE.md**
- Project instructions for Claude Code
- eBPF development environment setup (OrbStack)
- Common development commands (compile, build, run, test)
- Code generation with bpf2go
- Project architecture documentation

## Important Decisions

### Technology Choices
1. **netkit over veth** - Used BPF-programmable netkit devices (kernel 6.6+) instead of traditional veth pairs for better eBPF integration
2. **tcx over legacy TC** - Documented tcx (Traffic Control eXpress) as the modern replacement for TC, with fallback patterns for older kernels
3. **No DPDK** - All CNF implementations use pure eBPF approach, no DPDK references
4. **cilium/ebpf library** - Standard Go library for all userspace eBPF interactions
5. **Restricted C** - Kernel-space programs written in Restricted C (eBPF subset)

### Skill Design Principles
- Each skill is focused on a specific aspect of CNF development
- All skills include comprehensive code examples
- Both C (kernel) and Go (userspace) code provided
- Production-ready patterns with error handling
- Verifier-compliant code throughout
- Best practices emphasized

### Skill Organization
- Skills stored in `.claude/skills/` for project-wide availability
- Each skill in its own directory with SKILL.md file
- YAML frontmatter with name and description
- Clear "When to Use" and "What This Skill Does" sections
- Information gathering questions for user interaction

## Technical Constraints

### Kernel Version Requirements
- **netkit**: Linux 6.6+
- **tcx**: Linux 6.6+
- **Legacy TC with eBPF**: Linux 4.1+
- **XDP**: Linux 4.8+
- **Ringbuf**: Linux 5.8+ (preferred over perf events)

### eBPF Verifier Requirements
- Always bounds check before pointer dereferences
- Use `static __always_inline` for helper functions
- Avoid unbounded loops
- Use `__builtin_memset` for struct initialization
- Careful pointer arithmetic with bounds verification

### Go/C Interop
- Struct layout must match exactly between C and Go
- Use `__attribute__((packed))` in C if needed
- Padding must be explicit in both languages
- Use `-type` flag in bpf2go to auto-generate Go structs
- Network byte order conversions (bpf_ntohs/bpf_ntohl)

## Quick Resume

All skills have been successfully created and are ready for use. The skills provide comprehensive guidance for:
1. Scaffolding new CNF projects
2. Parsing packets safely
3. Managing eBPF maps
4. Attaching to kernel hooks
5. Setting up CNF networking infrastructure
6. Testing CNF implementations

No further work needed unless user requests modifications or additional skills.

## Next Steps (if requested)

Potential enhancements:
- Add more specialized skills (e.g., ebpf-rate-limiter, ebpf-load-balancer)
- Create example CNF implementations using these skills
- Add CI/CD integration documentation
- Create troubleshooting/debugging skill
- Add performance optimization skill