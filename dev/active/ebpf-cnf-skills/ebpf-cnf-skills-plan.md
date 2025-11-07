# eBPF CNF Skills - Implementation Plan

## Executive Summary

Create a comprehensive set of Claude Code skills for developing eBPF-based Cloud Native Network Functions (CNFs) using modern kernel features (netkit, tcx) and best practices. The skills will cover the complete development lifecycle from scaffolding to testing, using Go for userspace and Restricted C for kernel programs.

## Current State

**Before:**
- No skills available for eBPF CNF development
- No standardized patterns for common tasks
- Manual scaffolding required for each new CNF
- Knowledge scattered across examples

**Challenges:**
- eBPF has a steep learning curve
- Verifier requirements are strict and complex
- Modern features (netkit, tcx) are new and poorly documented
- Testing CNFs requires complex network namespace setups

## Proposed Future State

**After:**
- 6 comprehensive skills covering all aspects of CNF development
- Automated scaffolding for new projects
- Production-ready code patterns
- Complete test infrastructure templates
- Modern kernel features properly documented

## Requirements

### Functional Requirements
1. Skills must follow Claude Code SKILL.md format
2. Each skill must have clear name, description, and use cases
3. Code examples must be verifier-compliant
4. Must emphasize netkit and tcx (kernel 6.6+)
5. No DPDK references (pure eBPF approach)
6. Use cilium/ebpf library for Go code

### Technical Requirements
1. C code must be Restricted C (eBPF subset)
2. Go code must use cilium/ebpf library
3. All code must include error handling
4. Proper cleanup patterns (defer, t.Cleanup)
5. Production-ready examples

### Non-Functional Requirements
1. Skills must be comprehensive yet focused
2. Examples must be copy-pasteable
3. Best practices emphasized throughout
4. Common pitfalls documented

## Implementation Phases

### Phase 1: Setup ✅ COMPLETE
**Duration:** 5 minutes

Tasks:
- Create `.claude/skills/` directory structure
- Research Claude Code skills documentation
- Understand SKILL.md format requirements

**Acceptance Criteria:**
- Directory structure created
- Format requirements understood

### Phase 2: Core Skills ✅ COMPLETE
**Duration:** 2 hours

#### Skill 2.1: ebpf-cnf-scaffold ✅
- Scaffolds complete CNF projects
- Templates for all hook types (XDP, tcx, netkit, kprobe, tracepoint)
- bpf2go generation setup
- Go module initialization
- README and Dockerfile templates

**Acceptance:** Can scaffold a working CNF project from scratch

#### Skill 2.2: ebpf-packet-parser ✅
- Verifier-safe packet parsing patterns
- Ethernet, IPv4/IPv6, TCP/UDP/ICMP parsing
- IPv4-Mapped IPv6 address handling (RFC4291)
- Complete 5-tuple extraction
- Bounds checking patterns

**Acceptance:** Provides all necessary parsing code for CNFs

#### Skill 2.3: ebpf-map-handler ✅
- All map types (hash, array, ringbuf, LRU, per-CPU)
- C map definitions
- Go userspace code (lookup, update, delete, iterate)
- Ringbuf event streaming
- Complete examples

**Acceptance:** Covers all common map use cases

### Phase 3: Integration Skills ✅ COMPLETE
**Duration:** 2 hours

#### Skill 3.1: ebpf-attach-hook ✅
- XDP attachment (with auto-mode selection)
- TC/tcx attachment (with version detection)
- netkit attachment (primary and peer)
- kprobe/kretprobe attachment
- Tracepoint and cgroup hooks
- Multi-interface patterns
- Signal handling

**Acceptance:** Complete attachment logic for all hook types

#### Skill 3.2: cnf-networking ✅
- **netkit devices** - BPF-programmable network device (kernel 6.6+)
- **tcx** - Traffic Control eXpress (kernel 6.6+)
- Network namespace management
- Virtual interfaces (veth, netkit, bridges)
- Multi-namespace CNF setups
- Routing and forwarding
- Debugging techniques

**Acceptance:** Complete networking infrastructure guidance with modern features

#### Skill 3.3: ebpf-test-harness ✅
- Network namespace setup/teardown
- Virtual interface creation
- Traffic generation (ICMP, TCP, UDP)
- Packet injection with gopacket
- Map validation
- Event collection
- Integration test patterns
- Benchmarking

**Acceptance:** Complete test infrastructure for CNFs

### Phase 4: Documentation ✅ COMPLETE
**Duration:** 30 minutes

Tasks:
- Update CLAUDE.md with eBPF development guidance
- Create dev docs for this task

**Acceptance Criteria:**
- CLAUDE.md provides clear project overview
- Dev docs capture decisions and progress

## Key Decisions

### Technology Stack
- **Userspace:** Go with cilium/ebpf library
- **Kernel:** Restricted C (eBPF subset)
- **Build:** bpf2go for code generation
- **Testing:** Go testing framework with network namespaces
- **Networking:** netkit and tcx (kernel 6.6+)

### Skill Organization
- Each skill focuses on one aspect of CNF development
- Skills are composable (use multiple together)
- All skills include comprehensive examples
- Best practices emphasized throughout

### Modern Features Priority
- netkit over veth (BPF-programmable)
- tcx over legacy TC (kernel 6.6+)
- Ringbuf over perf events (kernel 5.8+)
- Auto-detection and fallback patterns for older kernels

## Risk Assessment

### Low Risk
- ✅ Skill format is well-documented
- ✅ Code patterns are proven in examples
- ✅ cilium/ebpf library is mature

### Medium Risk
- ⚠️ netkit and tcx are new (kernel 6.6+) - **Mitigated:** Provide fallback patterns
- ⚠️ eBPF verifier complexity - **Mitigated:** All examples are verifier-compliant

### High Risk
- None identified

## Success Metrics

1. ✅ All 6 skills created
2. ✅ Each skill has comprehensive examples
3. ✅ netkit and tcx properly documented
4. ✅ No DPDK references
5. ✅ Production-ready code patterns
6. ✅ Test infrastructure complete

## Timeline

**Total Estimated Time:** 4.5 hours
**Actual Time:** ~3 hours

- Phase 1 (Setup): 5 minutes ✅
- Phase 2 (Core Skills): 2 hours ✅
- Phase 3 (Integration Skills): 2 hours ✅
- Phase 4 (Documentation): 30 minutes ✅

## Deliverables

### Primary Deliverables ✅
1. 6 comprehensive SKILL.md files
2. Updated CLAUDE.md
3. Dev docs (plan, context, tasks)

### Skill Deliverables ✅
1. `.claude/skills/ebpf-cnf-scaffold/SKILL.md`
2. `.claude/skills/ebpf-packet-parser/SKILL.md`
3. `.claude/skills/ebpf-map-handler/SKILL.md`
4. `.claude/skills/ebpf-attach-hook/SKILL.md`
5. `.claude/skills/cnf-networking/SKILL.md`
6. `.claude/skills/ebpf-test-harness/SKILL.md`

## Future Enhancements

Potential additional skills:
1. **ebpf-rate-limiter** - Token bucket, sliding window algorithms
2. **ebpf-load-balancer** - Connection tracking, backend selection
3. **ebpf-firewall** - Packet filtering, stateful inspection
4. **ebpf-metrics** - Prometheus integration, metrics collection
5. **ebpf-debug** - Troubleshooting, bpftool usage, trace logs
6. **ebpf-optimize** - Performance tuning, per-CPU patterns
7. **ebpf-security** - Security best practices, capability handling

## Conclusion

Successfully created a comprehensive skill set for eBPF CNF development covering the complete lifecycle from scaffolding to testing. Skills emphasize modern kernel features (netkit, tcx) and follow production-ready patterns using Go and Restricted C with the cilium/ebpf library.