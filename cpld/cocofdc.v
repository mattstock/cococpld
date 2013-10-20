`timescale 1ns/1ns

module cocofdc (c_eclk, c_cts_n, c_scs_n, sram_databus, c_databus, c_addrbus, c_nmi_n, c_halt_n, sram_addrbus, c_rw,
					sram_we_n, sram_oe_n, sram_ce_n, c_slenb_n, clock_50, reset_n, led, intr, a_databus, a_addrbus, a_rw, a_sel, c_power, levelin, levelout);

input [14:0] c_addrbus;
input [15:0] a_addrbus;
input a_rw;
input a_sel;
input c_power;
inout [7:0] a_databus;
output reg [15:0] sram_addrbus; // Memory address bus
inout [7:0] sram_databus; // Memory databus
output sram_ce_n;
inout [7:0] c_databus;
input c_scs_n; // 0 = Coco register read/write 
input c_cts_n; // 0 = Coco ROM read
input c_eclk; // 1 = memory half of Coco bus cycle
output c_slenb_n;
output c_nmi_n;
input c_rw; // Coco read/write
input reset_n; 
output [3:0] led;
output reg sram_we_n;
output sram_oe_n;
output c_halt_n;
output [1:0] intr;
input clock_50;
input [2:0] levelin;
output [2:0] levelout;

reg [1:0] counter_50;     // 50MHz counter for SRAM read/write   
reg [1:0] intr;               // HIGH to indicate SCS register changes since last SPI read
reg [2:0] eclk_edge;     // Synchonizer for Coco E clock and 50MHz CPLD clock
reg [2:0] cts_edge;
reg [2:0] scs_edge;
reg [2:0] avr_edge;

reg [7:0] avr_readbuf;
reg [7:0] c_readbuf;    // SRAM stores in this register for the fairly long E Coco read cycle
reg [7:0] sram_writebuf;
reg actor;              // Who initiated read or write cycle, or added to pending: 0 = coco, 1 = spi
reg [2:0] req;				// Flags for pending requests { SPI, SCS, CTS }

reg nmi;                // Set if NMI output to Coco
reg [7:0] dskreg;			// 0xff40
reg [7:0] fdcstatus;    // 0xff48 (r)
reg [7:0] fdccmd;       // 0xff48 (w)
reg [7:0] trkreg;       // 0xff49
reg [7:0] secreg;       // 0xff4a
reg [7:0] datareg;      // 0xff4b

// We have to handle shared access to the SRAM bus by both the Coco and the SPI bus.  Fortunately, both of them
// are extremely slow compared to the 20ns CPLD clock and SRAM speeds (<= 55ns).  So our goal is to track when the SRAM
// bus is in use, and queue up a write operation when needed.  For read accesses, we need to go into a wait loop until the bus is
// free.  The bus will free up in < 4 ticks, which is much less than a single SPI clock transition (assuming a 4MHz clock).  So we
// can afford to spin through the state machine a few times until it's ready.  For a Coco read, we do the read into a temporary read
// buffer, so that the bus is not tied up for the entirety of the Coco read cycle.

// 4MHZ SPI = 250ns
// 0.89MHz/1.78MHz Coco E clock = 1117ns/559ns
// 50MHz CPLD clock = 20ns
	
assign sram_oe_n = ~sram_we_n;

assign c_slenb_n = 1'bz;
assign sram_ce_n = 1'b0;

wire cts_falling_edge = (cts_edge[2:1] == 2'b10);
wire scs_falling_edge = (scs_edge[2:1] == 2'b01); // it's flipped because of the eclk timing
wire avr_falling_edge = (avr_edge[2:1] == 2'b10);
wire c_regselect = ~c_scs_n & c_eclk;
wire c_memselect = ~c_cts_n;
wire c_select = (c_regselect | c_memselect);
wire halt = dskreg[7] & ~fdcstatus[1];

assign c_databus = (c_rw & c_select ? c_readbuf : 8'hzz);
assign sram_databus = (sram_oe_n ? sram_writebuf : 8'hzz); 
assign c_nmi_n = (nmi ? 1'b0 : 1'bz); // for FDC
assign c_halt_n = (halt ? 1'b0 : 1'bz); // for FDC

assign a_databus = (a_rw & ~a_sel ? avr_readbuf : 8'hzz);

// I need some level converters
assign levelout = levelin;

assign led = 4'b0110;

// sync E clock, AVR, CTS, SCS with 50MHz osc
always @(posedge clock_50) begin
  eclk_edge <= {eclk_edge[1:0], c_eclk};
  cts_edge <= {cts_edge[1:0], c_cts_n};
  scs_edge <= {scs_edge[1:0], c_regselect};
  avr_edge <= {avr_edge[1:0], a_sel};
end

always @(negedge reset_n or posedge clock_50) begin
  if (!reset_n) begin
	 intr <= 2'b11;
	 counter_50 <= 2'b0;
	 sram_addrbus <= 16'h2000;
	 sram_we_n <= 1'b1;
	 req <= 3'b0;
 	 fdcstatus <= 8'b00000100;
	 fdccmd <= 8'h00;
	 dskreg <= 8'b10000000;
	 datareg <= 8'h00;
	 secreg <= 8'h00;
	 trkreg <= 8'h00;
 	 nmi <= 1'b0;
 end else begin
   if (avr_falling_edge)
	   req[2] <= 1'b1;
   if (scs_falling_edge && c_power) 
	   req[1] <= 1'b1;
   if (cts_falling_edge && c_power)
		req[0] <= 1'b1;
	if (counter_50) begin // Deal with SRAM timing and buffering
		counter_50 <= counter_50 - 1'b1; // doesn't apply until next tick!
	   if (counter_50 == 2'h1) begin // Last count in cycle
		  if (sram_we_n == 1'b0)
		    sram_we_n <= 1'b1;
		  if (!actor)
		    c_readbuf <= sram_databus;
		  else
		    avr_readbuf <= sram_databus;
	   end	 
	 end else
	   // All of these happen on the next clock tick!
		// This functions as a very simple arbiter - AVR first because it has tighter timing, then
		// Coco.
	   casex (req)
  	     3'b1xx: begin // AVR request pending	 
          avr_command();
 		    req[2] <= 1'b0;
		  end
		  3'b01x: begin // SCS request pending
          scs_handler();
		    req[1] <= 1'b0;
		  end
		  3'b001: begin // CTS request pending
	       cts_handler();
		    req[0] <= 1'b0;
		  end
		endcase
  end
end

task scs_handler;
begin
  if (c_rw)
    case (c_addrbus[3:0])
	 4'h8: begin
	   dskreg[7] <= 1'b0;
		nmi <= 1'b0;
		c_readbuf <= fdcstatus;
	 end
	 4'h9:
	   c_readbuf <= trkreg;
    4'ha:
	   c_readbuf <= secreg;
	 4'hb: begin
	   fdcstatus[1] <= 1'b0;
	   c_readbuf <= datareg;
	 end
  endcase else
	 case (c_addrbus[3:0])
    4'h0: begin // $ff40 (dskreg)
	   intr[0] <= 1'b0;
		dskreg <= c_databus;
		fdcstatus[0] <= 1'b0;
	 end
	 4'h8: begin // $ff48 (fdcstatus/fdccmd)
	   fdccmd <= c_databus; 
	   if (c_databus[7:6] == 2'b10) // Type II operations set halt
		  fdcstatus[1] <= 1'b0;
		intr[1] <= 1'b0;
	 end
	 4'h9: // $ff49 (trkreg)
	   trkreg <= c_databus;
	 4'ha: // $ff4a (secreg)
	   secreg <= c_databus;
	 4'hb: begin // $ ff4b (datareg)
	   fdcstatus[1] <= 1'b0;
		datareg <= c_databus;
	 end
  endcase
end
endtask

task cts_handler;
begin
    actor <= 1'b0;  // Coco
    counter_50 <= 2'h3;
    sram_addrbus[15:0] <= { 1'b1, c_addrbus[14:0]};
    sram_we_n <= 1'b1;	   
end
endtask

task avr_command;
begin
  if (a_rw)
    case (a_addrbus)
	 16'h1000: begin
 	   avr_readbuf <= dskreg;
	   intr[0] <= 1'b1;
 	 end
	 16'h1001: begin // Read from $ff48 status reg
 	   avr_readbuf <= fdcstatus;
		intr[1] <= 1'b1;
	 end
	 16'h1002:
	   avr_readbuf <= fdccmd;
	 16'h1003:
	   avr_readbuf <= trkreg;
	 16'h1004:
	   avr_readbuf <= secreg;
	 16'h1005:
	   avr_readbuf <= datareg;
	 default: begin
	   counter_50 <= 2'h3; // Use a 3 tick read cycle 60ns for 55ns memory
		sram_addrbus <= a_addrbus;
	   sram_we_n <= 1'b1;
		actor <= 1'b1;
 	 end
    endcase
  else
    case (a_addrbus)
	 16'h0100: begin
      if (a_databus[0])
		  fdcstatus[1] <= 1'b1;
	   if (a_databus[1])
		  nmi <= 1'b1;
		if (a_databus[2])
		  dskreg[7] <= 1'b0; // halt enable is cleared at the end of each command
    end
	 16'h1000:
	   dskreg <= a_databus;
	 16'h1001:
	   fdcstatus <= a_databus;
	 16'h1003:
	   trkreg <= a_databus;
	 16'h1004:
	   secreg <= a_databus;
	 16'h1005:
	   datareg <= a_databus;
    default: begin
      counter_50 <= 2'h3;
	   sram_addrbus[15:0] <= a_addrbus;
	   sram_writebuf <= a_databus;
	   sram_we_n <= 1'b0;
	   actor <= 1'b1;
	 end
  endcase
end
endtask

endmodule
