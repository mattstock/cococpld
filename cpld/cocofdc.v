module cocofdc (c_power, a_power, eclk, cts_n, scs_n, c_databus, reset_n, c_addrbus, c_rw, a_databus, a_addrbus, a_rw, a_busreq, a_een_n, e_rw, e_oe_n, e_addrbus, e_databus);

input c_power;  // 1 = Coco power on
input a_power; // 1 = AVR power on
input [14:0] c_addrbus; // Coco address bus
inout [7:0] c_databus; // Coco data bus
input scs_n; // 0 = Coco register read/write 
input cts_n; // 0 = Coco ROM read
input eclk; // 1 = memory half of Coco bus cycle
input c_rw; // Coco read/write
input reset_n; // 0 = Coco reset
inout [7:0] a_databus; // AVR data bus
input [14:0] a_addrbus; // AVR address bus
input a_rw; // AVR read/write
input a_busreq; // 1 = AVR controls bus (Coco isolated)
input a_een_n; // When AVR has bus control, also control the EEPROM output
output[14:0] e_addrbus;
inout [7:0] e_databus;
output e_rw;
output e_oe_n;

wire c_busen_n;
wire c_busreq_n;
wire c_reg;
tri [14:0] commonaddr;
tri [7:0] commondata;

// Coco bus controls
assign c_busen_n = (c_power ? a_power & a_busreq : 1'b1); // If coco is on, let it control the address bus unless arduino wants it (neg)
assign c_busreq_n = (cts_n & scs_n) | c_busen_n; // Coco bus request (neg)
assign c_databus = (~c_busreq_n & c_rw) ? commondata : 8'bz;

// EEPROM bus controls
assign e_addrbus = commonaddr;
assign e_databus = e_oe_n ? commondata : 8'bz;
assign e_oe_n = ~c_busen_n ? cts_n : a_een_n;
assign e_rw = a_power ? a_rw : 1'b1;

// AVR bus controls
assign a_databus = (a_busreq & a_rw)? commondata : 8'bz;

// Register access signals
assign c_reg = ~c_busen_n & ~scs_n;

// Common (in CPLD) bus inputs
assign commonaddr = ~c_busen_n ? c_addrbus : 15'bz;
assign commonaddr = a_busreq ? a_addrbus : 15'bz;
assign commondata = (~c_busreq_n & ~c_rw) ? c_databus : 8'bz;
assign commondata = (a_busreq & ~a_rw) ? a_databus : 8'bz;
assign commondata = ~e_oe_n ? e_databus : 8'bz;

endmodule
