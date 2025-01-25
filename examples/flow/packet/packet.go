package packet

import (
	"encoding/binary"
	"hash/fnv"
	"net/netip"
)

type Packet struct {
	SrcIP, DstIP netip.Addr
	SrcPort, DstPort uint16
	Protocol, TTL uint8
	Syn, Ack bool
	Timestamp uint64
}

// UnmarshalBinary unmarshals the flow data coming from the eBPF program
// src_ip: size = 16, offset = 0
// dst_ip: size = 16, offset = 16
// src_port: size = 2, offset = 32
// dst_port: size = 2, offset = 34
// protocol: size = 1, offset = 36
// ttl: size = 1, offset = 37
// syn: size = 1, offset = 38
// ack: size = 1, offset = 39
// ts: size = 8, offset = 40
func UnmarshalBinary(in []byte) (Packet, bool) {
	srcIP, ok := netip.AddrFromSlice(in[0:16])

	if !ok {
		return Packet{}, ok
	}

	dstIP, ok := netip.AddrFromSlice(in[16:32])

	if !ok {
		return Packet{}, ok
	}

	pkt := Packet{
		SrcIP: srcIP,
		DstIP: dstIP,
		SrcPort: binary.BigEndian.Uint16(in[32:34]),
		DstPort: binary.BigEndian.Uint16(in[34:36]),
		Protocol: in[36],
		TTL: in[37],
		Syn: in[38] == 1,
		Ack: in[39] == 1,
		Timestamp: binary.LittleEndian.Uint64(in[40:48]),
	}
	
	return pkt, ok
}

// Hash calculates a unique hash value for each network flow using a five-tuple hash.
func (pkt *Packet) Hash() uint64 {
	tmp := make([]byte, 2)

	var src, dst, proto []byte

	binary.BigEndian.PutUint16(tmp, pkt.SrcPort) // Writes the port number into tmp
	src = append(pkt.SrcIP.AsSlice(), tmp...) // Convert SrcPort to byte array

	binary.BigEndian.PutUint16(tmp, pkt.DstPort)
	dst = append(pkt.DstIP.AsSlice(), tmp...)

	binary.BigEndian.PutUint16(tmp, uint16(pkt.Protocol))
	proto = append(proto, tmp...)

	return hash(src) + hash(dst) + hash(proto)
}

// hash calculates a 64-bit hash value for each byte slice using the FNV-1a algorithm, which is a non-cryptographic hash function.
func hash(value[]byte) uint64 {
	hash := fnv.New64a()
	hash.Write(value)
	return hash.Sum64()
}