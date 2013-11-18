module cocofpga(SW, KEY, HEX0, HEX1, HEX2, HEX3, LEDR, LEDG, clock_50,
			c_addrbus, c_databus, c_eclk, c_slenb_n, c_rw, c_cts_n, c_qclk, c_cart_n,
			c_scs_n, c_dataen_n, c_reset_n, c_halt_n, c_nmi_n, 
			a_addrbus, a_databus, a_rw, a_sel, intr,
			sram_addrbus, sram_databus, sram_oe_n, sram_ce_n, sram_we_n, sram_ub_n, sram_lb_n,
			fl_addrbus, fl_databus, fl_oe_n, fl_ce_n, fl_we_n, fl_rst_n);

// FPGA board stuff
input clock_50;
input [9:0] SW;
input [3:0] KEY;
output [7:0] LEDG;
output [9:0] LEDR;
output [6:0] HEX0;
output [6:0] HEX1;
output [6:0] HEX2;
output [6:0] HEX3;

// FPGA FLASH
output [21:0] fl_addrbus;
inout [7:0] fl_databus;
output fl_oe_n;
output fl_ce_n;
output fl_we_n;
output fl_rst_n;

// FPGA SRAM
output [17:0] sram_addrbus;
inout [15:0] sram_databus;
output sram_oe_n;
output sram_ce_n;
output sram_we_n;
output sram_ub_n;
output sram_lb_n;

// Coco
input [15:0] c_addrbus;
inout [7:0] c_databus;
input c_qclk;
output c_cart_n;
input c_scs_n; // 0 = Coco register read/write 
input c_cts_n; // 0 = Coco ROM read
input c_eclk; // 1 = memory half of Coco bus cycle
output c_slenb_n;
output c_nmi_n;
input c_rw; // Coco read/write
input c_reset_n; 
output c_halt_n;
output c_dataen_n;

// AVR
input [15:0] a_addrbus;
inout [7:0] a_databus;
input a_rw;
input a_sel;
output [1:0] intr;

// SRAM
assign sram_addrbus = 18'b0;
assign sram_databus = 16'b0;
assign sram_ce_n = 1'b1;
assign sram_lb_n = 1'b1;
assign sram_oe_n = 1'b1;
assign sram_ub_n = 1'b1;
assign sram_we_n = 1'b1;

// FLASH
assign fl_oe_n = 1'b1;
assign fl_ce_n = 1'b1;
assign fl_rst_n = 1'b1;
assign fl_we_n = 1'b1;
assign fl_addrbus = 22'b0;
assign fl_databus = 8'b0;

wire [3:0] led;

wire avr_control = led[0] | ~c_power;

// Some debug info
assign LEDR = { 3'b0, c_rw, a_rw, ~c_dataen_n, led };
SEG7_LUT_4 h0(HEX0, HEX1, HEX2, HEX3, avr_control ? a_addrbus : c_addrbus );
assign LEDG = (avr_control ? a_databus : c_databus);

wire reset_n = KEY[0];
wire c_power = SW[1];
assign c_cart_n = (SW[0] ? c_qclk : 1'bz);

assign c_dataen_n = ~((~c_scs_n & c_eclk) | ~c_cts_n) | ~c_power;

cocofdc fdc0(c_eclk, c_scs_n, c_cts_n, c_slenb_n, c_databus, c_addrbus, c_nmi_n, c_halt_n, c_rw,
					clock_50, reset_n, intr, a_databus, a_addrbus, a_rw, a_sel, c_power, led);

endmodule
