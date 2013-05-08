`timescale 1ns/1ns

module cocofdc (c_power, a_power, eclk, cts_n, scs_n, c_databus, nmi_n, halt_n, reset_n, c_addrbus, c_rw, a_miso, a_mosi, a_sclk, a_sel,
					e_cs_n, s_cs_n, m_rw, m_oe_n, m_addrbus, m_databus, slenb_n, a_busmaster, a_regint, led);

input c_power;  // 1 = Coco power on
input a_power; // 1 = AVR power on
input [14:0] c_addrbus; // Coco address bus
inout [7:0] c_databus; // Coco data bus
input scs_n; // 0 = Coco register read/write 
input cts_n; // 0 = Coco ROM read
input eclk; // 1 = memory half of Coco bus cycle
output slenb_n;
output nmi_n;
input c_rw; // Coco read/write
input reset_n; // 0 = Coco reset
output[14:0] m_addrbus;
inout [7:0] m_databus;
output reg [2:0] led;
output m_rw;
output m_oe_n;
output s_cs_n; // SRAM chip select
output e_cs_n; // EEPROM chip select
output reg halt_n;
output reg a_busmaster; // indicate that AVR has the bus
output reg a_regint;
input a_sclk;
input a_mosi;
input a_sel;
output a_miso;

SPI_slave u0(eclk, a_sclk, a_mosi, a_miso, a_sel);

reg [3:0] count; // used to count eclk cycles
reg a_busreq;
reg a_rw;
reg a_een_n;
reg [15:0] a_addrbus;
reg [7:0] a_databus;

wire c_busreq_n = (cts_n & scs_n) | ~eclk; // Coco bus request

// Memory bus controls
assign m_addrbus = a_busmaster ? a_addrbus[14:0] : c_addrbus;
assign m_databus = (~a_busmaster & ~c_rw) ? c_databus : 8'bz;
assign c_databus = (~a_busmaster & c_rw) ? m_databus : 8'bz;
assign m_databus = (a_busmaster & ~a_rw) ? a_databus : 8'bz;
//assign a_databus = (a_busmaster & a_rw)? m_databus : 8'bz;
assign m_oe_n = a_busmaster ? a_een_n : c_busreq_n;
assign s_cs_n = a_busmaster ? a_addrbus[15] : scs_n;  // SRAM low 32K to AVR
assign e_cs_n = a_busmaster ? ~a_addrbus[15] : cts_n; // EEPROM high 32K to AVR
assign m_rw = a_busmaster ? a_rw : c_rw;

// Hardcode outputs for now
assign slenb_n = 1'bz;
assign nmi_n = 1'bz;

always @(posedge eclk) begin
  if (~a_busreq) begin // AVR doesn't want the bus
    count <= 4'b0;
	 halt_n <= 1'bz;
	 a_busmaster <= ~c_power;
  end else begin // Initiate halt process
    count <= count + 4'b1;
	 halt_n <= 1'b0;
  end
  // check to make sure we're in a halt state
  // if cts or scs are asserted, we wait another
  // 16 clock cycles and try again (count rollover)
  // we're stuck in this loop until reset or the bus clears
  led <= count[2:0];
  if ((count == 3) && cts_n && scs_n)
    a_busmaster <= 1'b1;
end

always @(posedge eclk) begin
  if (eclk)
    if (!scs_n && c_power && !c_rw)
	   a_regint <= 1'b1;
  else if (a_busreq)
    a_regint <= 1'b0;
end



endmodule
