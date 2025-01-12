// Code generated by bpf2go; DO NOT EDIT.
//go:build 386 || amd64 || arm || arm64 || loong64 || mips64le || mipsle || ppc64le || riscv64

package bytecode

import (
	"bytes"
	_ "embed"
	"fmt"
	"io"

	"github.com/cilium/ebpf"
)

// LoadProbe returns the embedded CollectionSpec for Probe.
func LoadProbe() (*ebpf.CollectionSpec, error) {
	reader := bytes.NewReader(_ProbeBytes)
	spec, err := ebpf.LoadCollectionSpecFromReader(reader)
	if err != nil {
		return nil, fmt.Errorf("can't load Probe: %w", err)
	}

	return spec, err
}

// LoadProbeObjects loads Probe and converts it into a struct.
//
// The following types are suitable as obj argument:
//
//	*ProbeObjects
//	*ProbePrograms
//	*ProbeMaps
//
// See ebpf.CollectionSpec.LoadAndAssign documentation for details.
func LoadProbeObjects(obj interface{}, opts *ebpf.CollectionOptions) error {
	spec, err := LoadProbe()
	if err != nil {
		return err
	}

	return spec.LoadAndAssign(obj, opts)
}

// ProbeSpecs contains maps and programs before they are loaded into the kernel.
//
// It can be passed ebpf.CollectionSpec.Assign.
type ProbeSpecs struct {
	ProbeProgramSpecs
	ProbeMapSpecs
	ProbeVariableSpecs
}

// ProbeProgramSpecs contains programs before they are loaded into the kernel.
//
// It can be passed ebpf.CollectionSpec.Assign.
type ProbeProgramSpecs struct {
	Flat *ebpf.ProgramSpec `ebpf:"flat"`
}

// ProbeMapSpecs contains maps before they are loaded into the kernel.
//
// It can be passed ebpf.CollectionSpec.Assign.
type ProbeMapSpecs struct {
}

// ProbeVariableSpecs contains global variables before they are loaded into the kernel.
//
// It can be passed ebpf.CollectionSpec.Assign.
type ProbeVariableSpecs struct {
}

// ProbeObjects contains all objects after they have been loaded into the kernel.
//
// It can be passed to LoadProbeObjects or ebpf.CollectionSpec.LoadAndAssign.
type ProbeObjects struct {
	ProbePrograms
	ProbeMaps
	ProbeVariables
}

func (o *ProbeObjects) Close() error {
	return _ProbeClose(
		&o.ProbePrograms,
		&o.ProbeMaps,
	)
}

// ProbeMaps contains all maps after they have been loaded into the kernel.
//
// It can be passed to LoadProbeObjects or ebpf.CollectionSpec.LoadAndAssign.
type ProbeMaps struct {
}

func (m *ProbeMaps) Close() error {
	return _ProbeClose()
}

// ProbeVariables contains all global variables after they have been loaded into the kernel.
//
// It can be passed to LoadProbeObjects or ebpf.CollectionSpec.LoadAndAssign.
type ProbeVariables struct {
}

// ProbePrograms contains all programs after they have been loaded into the kernel.
//
// It can be passed to LoadProbeObjects or ebpf.CollectionSpec.LoadAndAssign.
type ProbePrograms struct {
	Flat *ebpf.Program `ebpf:"flat"`
}

func (p *ProbePrograms) Close() error {
	return _ProbeClose(
		p.Flat,
	)
}

func _ProbeClose(closers ...io.Closer) error {
	for _, closer := range closers {
		if err := closer.Close(); err != nil {
			return err
		}
	}
	return nil
}

// Do not access this directly.
//
//go:embed probe_bpfel.o
var _ProbeBytes []byte