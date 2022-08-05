/* -*- P4_16 -*- */
#include <core.p4>
#include <v1model.p4>

const bit<16> TYPE_IPV4 = 0x800;
// green info packets
const bit<8> TYPE_GREEN_INFO = 0x8F;

/*************************************************************************
*********************** H E A D E R S  ***********************************
*************************************************************************/
#define CPU_PORT 254
#define ETHERTYPE_ARP 0x0806
#define ACCESS_SWITCH 0
#define AGGREG_SWITCH 1
#define CORE_SWITCH 2
#define AGGREG_NUM 3
#define HOST_NUM 2

typedef bit<9>  egressSpec_t;
typedef bit<48> macAddr_t;
typedef bit<32> ip4Addr_t;

header ethernet_t {
    macAddr_t dstAddr;
    macAddr_t srcAddr;
    bit<16>   etherType;
}

header arp_t {
    bit<16> hwType;
    bit<16> protoType;
    bit<8> hwAddrLen;
    bit<8> protoAddrLen;
    bit<16> opcode;
    bit<48> srcHwAddr;
    bit<32> srcProtoAddr;
    bit<48> dstHwAddr;
    bit<32> dstProtoAddr;
}

header ipv4_t {
    bit<4>    version;
    bit<4>    ihl;
    bit<8>    diffserv;
    bit<16>   totalLen;
    bit<16>   identification;
    bit<3>    flags;
    bit<13>   fragOffset;
    bit<8>    ttl;
    bit<8>    protocol;
    bit<16>   hdrChecksum;
    ip4Addr_t srcAddr;
    ip4Addr_t dstAddr;
}

header tcp_t {
    bit<16> srcPort;
    bit<16> dstPort;
    bit<32> seqNo;
    bit<32> ackNo;
    bit<4>  dataOffset;
    bit<3>  res;
    bit<3>  ecn;
    bit<1>  urg;
    bit<1>  ack;
    bit<1>  psh;
    bit<1>  rst;
    bit<1>  syn;
    bit<1>  fin;
    bit<16> window;
    bit<16> checksum;
    bit<16> urgentPtr;
}

header Tcp_option_end_h {
    bit<8> kind;
}
header Tcp_option_nop_h {
    bit<8> kind;
}
header Tcp_option_sz_h {
    bit<8> length;
}
header Tcp_option_ss_h {
    bit<8>  kind;
    bit<8> length;
    bit<32> maxSegmentSize;
}
header Tcp_option_s_h {
    bit<8>  kind;
    bit<24> scale;
}
header Tcp_option_sack_h {
    bit<8>         kind;
    bit<8>         length;
    varbit<256>    sack;
}

header Tcp_option_timestamp_h {
    bit<8>         kind;
    bit<8>         length;
    bit<32> tsval;
    bit<32> tsecr;
    /*
    bit<16>        tsval_msb;
    bit<16>        tsval_lsb;
    bit<16>        tsecr_msb;
    bit<16>        tsecr_lsb;
    */
}

//Versions without the kind for hop by hop
header Tcp_option_ss_e {
    bit<8> length;
    bit<16> maxSegmentSize;
}

header Tcp_option_sack_e {
    varbit<256>    sack;
}
header Tcp_option_timestamp_e {
    bit<8>         length;
    bit<32> tsval;
    bit<32> tsecr;
    //bit<16>        tsval_msb;
    //bit<16>        tsval_lsb;
    //bit<16>        tsecr_msb;
    //bit<16>        tsecr_lsb;
}

header_union Tcp_option_h {
    Tcp_option_end_h  end;
    Tcp_option_nop_h  nop;
    Tcp_option_ss_h   ss;
    Tcp_option_s_h    s;
    Tcp_option_sack_h sack;
    Tcp_option_timestamp_h timestamp;    
}

// Defines a stack of 10 tcp options
typedef Tcp_option_h[10] Tcp_option_stack;

header Tcp_option_padding_h {
    varbit<256> padding;
}

error {
    TcpDataOffsetTooSmall,
    TcpOptionTooLongForHeader,
    TcpBadSackOptionLength
}

struct Tcp_option_sack_top
{
    bit<8> kind;
    bit<8> length;
}

struct metadata {
    /* empty */
    bit<9> egress_candidate;
    bit<9> ecmp_candidate;
    bit<4> host_id;
}

struct headers {
    ethernet_t   ethernet;
    arp_t        arp;
    ipv4_t       ipv4;
    tcp_t            tcp;
    //Tcp_option_stack tcp_options_vec;
    //Tcp_option_padding_h tcp_options_padding;
    Tcp_option_nop_h nop1;
    Tcp_option_nop_h nop2;
    //Linux MSS SACK TS
    Tcp_option_ss_e ss;
    Tcp_option_nop_h nop3;
    Tcp_option_sz_h sackw;
    Tcp_option_sack_e sack;
    Tcp_option_nop_h nop4;
    Tcp_option_timestamp_e timestamp;
}

/*************************************************************************
*********************** P A R S E R  ***********************************
*************************************************************************/


parser Tcp_option_parser(packet_in b,
                         in bit<4> tcp_hdr_data_offset,
                         out Tcp_option_stack vec,
                         out Tcp_option_padding_h padding)
{
    bit<7> tcp_hdr_bytes_left;
    
    state start {
        // RFC 793 - the Data Offset field is the length of the TCP
        // header in units of 32-bit words.  It must be at least 5 for
        // the minimum length TCP header, and since it is 4 bits in
        // size, can be at most 15, for a maximum TCP header length of
        // 15*4 = 60 bytes.
        verify(tcp_hdr_data_offset >= 5, error.TcpDataOffsetTooSmall);
        tcp_hdr_bytes_left = 4 * (bit<7>) (tcp_hdr_data_offset - 5);
        // always true here: 0 <= tcp_hdr_bytes_left <= 40
        transition next_option;
    }
    state next_option {
        transition select(tcp_hdr_bytes_left) {
            0 : accept;  // no TCP header bytes left
            default : next_option_part2;
        }
    }
    
    state next_option_part2 {
        // precondition: tcp_hdr_bytes_left >= 1
        transition select(b.lookahead<bit<8>>()) {
            0: parse_tcp_option_end;
            1: parse_tcp_option_nop;
            2: parse_tcp_option_ss;
            3: parse_tcp_option_s;
            5: parse_tcp_option_sack;
	    8: parse_tcp_option_timestamp;
        }
    }

    state parse_tcp_option_timestamp {
        verify(tcp_hdr_bytes_left >= 10, error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 10;
        b.extract(vec.next.timestamp);
        transition next_option;
    }
    
    state parse_tcp_option_end {
        b.extract(vec.next.end);
        // TBD: This code is an example demonstrating why it would be
        // useful to have sizeof(vec.next.end) instead of having to
        // put in a hard-coded length for each TCP option.
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 1;
        transition consume_remaining_tcp_hdr_and_accept;
    }
    state consume_remaining_tcp_hdr_and_accept {
        // A more picky sub-parser implementation would verify that
        // all of the remaining bytes are 0, as specified in RFC 793,
        // setting an error and rejecting if not.  This one skips past
        // the rest of the TCP header without checking this.

        // tcp_hdr_bytes_left might be as large as 40, so multiplying
        // it by 8 it may be up to 320, which requires 9 bits to avoid
        // losing any information.
        b.extract(padding, (bit<32>) (8 * (bit<9>) tcp_hdr_bytes_left));
        transition accept;
    }
    state parse_tcp_option_nop {
        b.extract(vec.next.nop);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 1;
        transition next_option;
    }
    state parse_tcp_option_ss {
        verify(tcp_hdr_bytes_left >= 5, error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 5;
        b.extract(vec.next.ss);
        transition next_option;
    }
    state parse_tcp_option_s {
        verify(tcp_hdr_bytes_left >= 4, error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - 4;
        b.extract(vec.next.s);
        transition next_option;
    }
    state parse_tcp_option_sack {
        bit<8> n_sack_bytes = b.lookahead<Tcp_option_sack_top>().length;
        // I do not have global knowledge of all TCP SACK
        // implementations, but from reading the RFC, it appears that
        // the only SACK option lengths that are legal are 2+8*n for
        // n=1, 2, 3, or 4, so set an error if anything else is seen.
        verify(n_sack_bytes == 10 || n_sack_bytes == 18 ||
               n_sack_bytes == 26 || n_sack_bytes == 34,
               error.TcpBadSackOptionLength);
        verify(tcp_hdr_bytes_left >= (bit<7>) n_sack_bytes,
               error.TcpOptionTooLongForHeader);
        tcp_hdr_bytes_left = tcp_hdr_bytes_left - (bit<7>) n_sack_bytes;
        b.extract(vec.next.sack, (bit<32>) (8 * n_sack_bytes - 16));
        transition next_option;
    }
}

parser MyParser(packet_in packet,
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {

    state start {
        transition parse_ethernet;
    }

    state parse_ethernet {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            TYPE_IPV4: parse_ipv4;
            ETHERTYPE_ARP: parse_arp;	    
            default: accept;
        }
    }

    state parse_arp {
	packet.extract(hdr.arp);
    }

    state parse_ipv4 {
        packet.extract(hdr.ipv4);
        transition select(hdr.ipv4.protocol) {
            6: parse_tcp;
            default: accept;
	}
    }

    state parse_tcp {
        packet.extract(hdr.tcp);
        //Tcp_option_parser.apply(packet, hdr.tcp.dataOffset,
        //                        hdr.tcp_options_vec, hdr.tcp_options_padding);
        packet.extract(hdr.nop1);
        transition select(hdr.nop1.kind){
		1: parse_nop;
            2: parse_ss;
            4: parse_sack;
            8: parse_ts;
		default: accept;
	}
    }	

    state parse_nop {
        packet.extract(hdr.nop2);
         transition select(hdr.nop2.kind){
            1: parse_nop2;
            8: parse_ts;
		default: accept;
	}
    }
    state parse_nop2 {
        packet.extract(hdr.nop3);
         transition select(hdr.nop3.kind){
            8: parse_ts;
		default: accept;
	}
    }
    state parse_ss {
        //Finish parsing SS
        packet.extract(hdr.ss);
        packet.extract(hdr.nop3);
        transition select(hdr.nop3.kind){
            4: parse_sack;
            8: parse_ts;
		default: accept;
	}
    }

    state parse_sack {
        //Finish parsing sack
        packet.extract(hdr.sackw);
        packet.extract(hdr.sack, (bit<32>)hdr.sackw.length - 2);
        packet.extract(hdr.nop4);
        transition select(hdr.nop4.kind){
            8: parse_ts;
		default: accept;
	}
    }

    state parse_ts {
        //Finish parsing ts
        packet.extract(hdr.timestamp);
        transition accept;
    }

}

/*************************************************************************
************   C H E C K S U M    V E R I F I C A T I O N   *************
*************************************************************************/

control MyVerifyChecksum(inout headers hdr, inout metadata meta) {
    apply {  }
}


/*************************************************************************
**************  I N G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyIngress(inout headers hdr,
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {

    register<bit<8>>(2) load_counter;
    register<bit<8>>(1) max_load;
    register<bit<2>>(1) switch_type;
    register<bit<1>>(1) ecmp_mode;
    register<bit<32>>(1) meter_data;
    register<bit<32>>(1) ecmp_width;
    register<bit<19>>(1) deq_qdepth;
    register<bit<19>>(1) enq_qdepth;
    direct_meter<bit<32>>(MeterType.packets) my_meter;
    counter(1, CounterType.packets) my_pkt_counts;
    register<bit<48>>(1) epoch_start;
    register<bit<48>>(1) epoch_length;
    
    register<bit<32>>(1) packet_size_threshold1;
    register<bit<32>>(1) packet_size_threshold2;
    register<bit<32>>(1) packet_size_threshold3;
    
    register<bit<32>>(1) packet_size_counter;
    register<bit<32>>(1) vip_ip;
    register<bit<48>>(1) timestamp_log;

    // Incremental checksum fix adapted from the pseudocode at https://p4.org/p4-spec/docs/PSA-v1.1.0.html#appendix-internetchecksum-implementation
    action ones_complement_sum(in bit<16> x, in bit<16> y, out bit<16> sum) {
	bit<17> ret = (bit<17>) x + (bit<17>) y;
	if (ret[16:16] == 1) {
            ret = ret + 1;
	}
	sum = ret[15:0];
    }

    // Restriction: data is a multiple of 16 bits long
    action subtract(inout bit<16> sum, bit<16> d) {
        ones_complement_sum(sum, ~d, sum);
    }

    action subtract32(inout bit<16> sum, bit<32> d) {
        ones_complement_sum(sum, ~(bit<16>)d[15:0], sum);
        ones_complement_sum(sum, ~(bit<16>)d[31:16], sum);
    }

    action add(inout bit<16> sum, bit<16> d) {
        ones_complement_sum(sum, d, sum);
    }

    action add32(inout bit<16> sum, bit<32> d) {
        ones_complement_sum(sum, (bit<16>)(d[15:0]), sum);
        ones_complement_sum(sum, (bit<16>)(d[31:16]), sum);
    }


    
    action drop() {
        mark_to_drop(standard_metadata);
    }

    action send_to_host(macAddr_t dstAddr, egressSpec_t port, ip4Addr_t dstIPAddr) {
	standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 10;
	hdr.ipv4.dstAddr = dstIPAddr;
	//hdr.timestamp.tsval = 0;
    }

    action send_back(){
	hdr.arp.opcode = 2;
	hdr.arp.srcProtoAddr = hdr.arp.dstProtoAddr;
	standard_metadata.egress_spec = standard_metadata.ingress_port;
	//meta.egress_candidate = standard_metadata.ingress_port;
    }
/*
    action broadcast(){
       standard_metadata.mcast_grp = 1;
    }
*/
    action ipv4_forward(macAddr_t dstAddr, egressSpec_t port) {
        standard_metadata.egress_spec = port;
        hdr.ethernet.srcAddr = hdr.ethernet.dstAddr;
        hdr.ethernet.dstAddr = dstAddr;
        hdr.ipv4.ttl = hdr.ipv4.ttl - 1;
    }

    table ipv4_lpm {
        key = {
            hdr.ipv4.dstAddr: lpm;
        }
        actions = {
            ipv4_forward;
            NoAction;
        }
        size = 1024;
	meters = my_meter;
    }

    table hosts {
        key = {
            meta.host_id: exact;
        }
        actions = {
            send_to_host;
            NoAction;
        }
        size = 1024;
    }

    apply {
	if (hdr.arp.isValid()){
	     send_back();	
	}
	else if (hdr.ipv4.isValid() && hdr.ipv4.protocol == TYPE_GREEN_INFO){
	      bit<8> value;
	      bit<32> index;
              index = (bit<32>)standard_metadata.ingress_port - (bit<32>)1;
	      value = (bit<8>)((bit<32>)hdr.ipv4.dstAddr & (bit<32>)255);
	      load_counter.write(index, value);
	}
        else if (hdr.ipv4.isValid()) {
	    bit<2> type;
            bit<1> ecmp_md;
	    bit<32> aggreg_num;
	    bit<48> epoch_st;
	    bit<48> epoch_ln;
	    bit<32> packet_th1;
	    bit<32> packet_th2;
	    bit<32> packet_th3;
	    bit<32> packet_sz_cn;

	    bit<48> timestamp = standard_metadata.ingress_global_timestamp;
            timestamp_log.write(0, timestamp);
	    
	    epoch_start.read(epoch_st, 0);
	    epoch_length.read(epoch_ln, 0);
	    packet_size_threshold1.read(packet_th1, 0);
	    packet_size_threshold2.read(packet_th2, 0);
	    packet_size_threshold3.read(packet_th3, 0);
            packet_size_counter.read(packet_sz_cn, 0);
	    packet_size_counter.write(0, packet_sz_cn + standard_metadata.packet_length);
	    
	    aggreg_num = 1;
	    
	    if (timestamp > epoch_st + epoch_ln){
                if (packet_sz_cn > packet_th3){
                    ecmp_width.write(0, 3);
		    //aggreg_num = 3;
		}
		else if (packet_sz_cn > packet_th2){
		    ecmp_width.write(0, 2);
		    //aggreg_num = 2;
		}
		else{
                    ecmp_width.write(0, 1);		    
		    //aggreg_num = 1;
		}
		epoch_start.write(0, timestamp);
		packet_size_counter.write(0, 0);
            }

            /*
	    deq_qdepth.write(0, standard_metadata.deq_qdepth);
	    enq_qdepth.write(0, standard_metadata.enq_qdepth);
	    */
            switch_type.read(type, 0);
	    ecmp_mode.read(ecmp_md, 0);
	    ecmp_width.read(aggreg_num, 0);
	    
            my_pkt_counts.count((bit<32>) 0)
	    ;
	    if (ecmp_md == 1 && type == CORE_SWITCH && standard_metadata.ingress_port == AGGREG_NUM+1) {
		    hash(standard_metadata.egress_spec, HashAlgorithm.crc16, (bit<16>)1,
			{ hdr.ipv4.srcAddr,
			  hdr.ipv4.dstAddr,
			  hdr.ipv4.protocol
			}, aggreg_num);
	    }
	    else{
		ipv4_lpm.apply();

		if (ecmp_md == 1 && type == ACCESS_SWITCH) {
		    if (standard_metadata.egress_spec > HOST_NUM) {
			// outgoing packet: ecmp on
			hash(standard_metadata.egress_spec, HashAlgorithm.crc16, (bit<16>)(HOST_NUM+1),
			    { hdr.ipv4.srcAddr,
				hdr.ipv4.dstAddr,
				hdr.ipv4.protocol
			    }, aggreg_num);
		    }
	    }

	   if (type == ACCESS_SWITCH && hdr.tcp.isValid()){
	       bit<32> vip;
	       vip_ip.read(vip, 0);
	       if(hdr.ipv4.dstAddr==vip){
	          if(hdr.tcp.syn == 0 && hdr.timestamp.isValid()){
			    //existing incoming connection
			    meta.host_id = (bit<4>)((bit<32>)hdr.timestamp.tsecr & (bit<32>)15);
			    //meta.host_id = (bit<4>)hdr.timestamp.tsecr;
		            if (hdr.tcp.rst == 1){
				// reset: decrease the counter load
				 bit<8> current;
				 load_counter.read(current, (bit<32>)standard_metadata.egress_spec-1);
                                 load_counter.write((bit<32>)standard_metadata.egress_spec-1, current-1);
			    }
			    bit<16> sum = 0;
			}
		 else if (hdr.tcp.syn == 1){
			    // new connection
			    bit<8> load1;
			    bit<8> load2;
			    load_counter.read(load1, 0);
			    load_counter.read(load2, 1);
			    bit<8> max_load_value;
			    max_load.read(max_load_value, 0);

			    if (load1 < max_load_value || load1 <= load2){
				meta.host_id = 1;
			    }
			    else{
				meta.host_id = 2;
			    }
			}
			bit<16> sum = 0;
			subtract(sum, hdr.tcp.checksum);
                        subtract32(sum, hdr.ipv4.dstAddr);			    
			hosts.apply();
			add32(sum, hdr.ipv4.dstAddr);
			hdr.tcp.checksum = ~sum;    
		}
	        else if (standard_metadata.ingress_port <= HOST_NUM && hdr.tcp.isValid()){
			// outgoing packet from server to client
			bit<16> sum = 0;
			subtract(sum, hdr.tcp.checksum);
                        subtract32(sum, hdr.ipv4.srcAddr);
		        subtract32(sum, hdr.timestamp.tsval);
			hdr.ipv4.srcAddr = vip;
			hdr.timestamp.tsval = (bit<32>)(hdr.timestamp.tsval & 4294967280) + (bit<32>)standard_metadata.ingress_port;
			//hdr.timestamp.tsval = (bit<32>)standard_metadata.ingress_port;
                        add32(sum, hdr.ipv4.srcAddr);
			add32(sum, hdr.timestamp.tsval);
			hdr.tcp.checksum = ~sum;
			
			bit<8> current;
			if (hdr.tcp.rst == 1 || hdr.tcp.fin == 1){
				// reset: decrease the counter load
				 load_counter.read(current, (bit<32>)standard_metadata.ingress_port-1);
                                 load_counter.write((bit<32>)standard_metadata.ingress_port-1, current-1);
			}
			else if (hdr.tcp.syn == 1 && hdr.tcp.ack == 1){
                            load_counter.read(current, (bit<32>)standard_metadata.ingress_port-1);
			    load_counter.write((bit<32>)standard_metadata.ingress_port-1, current+1);
			}
		    }
		}
		
	    }
	    bit<32> meter_data_value;
	    my_meter.read(meter_data_value);
	    meter_data.write(0, meter_data_value);
        }
	//standard_metadata.egress_spec = meta.egress_candidate;
    }
}

/*************************************************************************
****************  E G R E S S   P R O C E S S I N G   *******************
*************************************************************************/

control MyEgress(inout headers hdr,
                 inout metadata meta,
    inout standard_metadata_t standard_metadata) {


    apply {

    }
}

/*************************************************************************
*************   C H E C K S U M    C O M P U T A T I O N   **************
*************************************************************************/

control MyComputeChecksum(inout headers  hdr, inout metadata meta) {
     apply {
        update_checksum(
        hdr.ipv4.isValid(),
            { hdr.ipv4.version,
              hdr.ipv4.ihl,
              hdr.ipv4.diffserv,
              hdr.ipv4.totalLen,
              hdr.ipv4.identification,
              hdr.ipv4.flags,
              hdr.ipv4.fragOffset,
              hdr.ipv4.ttl,
              hdr.ipv4.protocol,
              hdr.ipv4.srcAddr,
              hdr.ipv4.dstAddr },
            hdr.ipv4.hdrChecksum,
            HashAlgorithm.csum16);
    }
}

/*************************************************************************
***********************  D E P A R S E R  *******************************
*************************************************************************/

control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.arp);
        packet.emit(hdr.ipv4);
        packet.emit(hdr.tcp);
        packet.emit(hdr.nop1);
        packet.emit(hdr.nop2);
        packet.emit(hdr.ss);
        packet.emit(hdr.nop3);
        packet.emit(hdr.sackw);
        packet.emit(hdr.sack);
        packet.emit(hdr.nop4);
        packet.emit(hdr.timestamp);
    }
}

/*************************************************************************
***********************  S W I T C H  *******************************
*************************************************************************/

V1Switch(
MyParser(),
MyVerifyChecksum(),
MyIngress(),
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
