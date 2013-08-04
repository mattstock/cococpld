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
inout reg [7:0] sram_databus; // Memory databus
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

parameter COCO_W = 2'b00, COCO_R = 2'b10, AVR_W = 2'b01, AVR_R = 2'b11;

reg [2:0] counter_50;     // 50MHz counter for SRAM read/write   
reg [1:0] intr;               // HIGH to indicate SCS register changes since last SPI read
reg [2:0] eclk_edge;     // Synchonizer for Coco E clock and 50MHz CPLD clock
reg [2:0] cts_edge;
reg [2:0] scs_edge;
reg [2:0] avr_edge;

reg [7:0] avr_readbuf;
reg [7:0] c_readbuf;    // SRAM stores in this register for the fairly long E Coco read cycle
reg [7:0] writebuf;     // If the SRAM is in use, writes a buffered here
reg actor;              // Who initiated read or write cycle, or added to pending: 0 = coco, 1 = spi
reg [2:0] req;				// Flags for pending requests { SPI, SCS, CTS }

reg nmi;                // Set if NMI output to Coco
reg halt;
reg [7:0] dskreg;			// 0xff40 kept in CPLD
reg [7:0] fdcstatus;    // 0xff48 read kept in CPLD


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
wire c_select = c_power & (c_regselect | c_memselect);

assign c_databus = (c_rw & c_select ? c_readbuf : 8'bz); 
assign c_nmi_n = (nmi ? 1'b0 : 1'bz); // for FDC
assign c_halt_n = (dskreg[7] & halt ? 1'b0 : 1'bz); // for FDC

assign a_databus = (a_rw & a_sel ? avr_readbuf : 8'bz);

// I need some level converters
assign levelout = levelin;

assign led = { intr, dskreg[7] & halt };

// sync E clock, AVR, CTS, SCS with 50MHz osc
always @(posedge clock_50) begin
  eclk_edge <= {eclk_edge[1:0], c_eclk};
  cts_edge <= {cts_edge[1:0], c_cts_n};
  scs_edge <= {scs_edge[1:0], ~c_scs_n & c_eclk};
  avr_edge <= {avr_edge[1:0], a_sel};
end

always @(negedge reset_n or posedge clock_50) begin
  if (!reset_n) begin
	 intr <= 2'b00;
	 counter_50 <= 3'b0;
	 sram_databus <= 8'bz;
	 sram_we_n <= 1'b1;
	 req <= 3'b0;
 	 fdcstatus <= 8'b00000100;
	 dskreg <= 8'h0;
 	 nmi <= 1'b0;
	 halt <= 1'b0;
 end else begin
    if (avr_falling_edge)
	   req[2] <= 1'b1;
    if (scs_falling_edge && c_power) 
	   req[1] <= 1'b1;
    if (cts_falling_edge && c_power)
		req[0] <= 1'b1;
	 if (counter_50) begin // Deal with SRAM timing and buffering
		counter_50 <= counter_50 - 1'b1; // doesn't apply until next tick!
	   if (counter_50 == 3'h1) // Last count in cycle
		    case ({sram_we_n, actor})
	       COCO_R: begin
			   if (c_regselect && c_addrbus[3:0] == 4'hb) begin
				  fdcstatus[1] <= 1'b0;
				  halt <= 1'b1;
			     c_readbuf <= sram_databus[7:0];
				end else if (c_regselect && c_addrbus[3:0] == 4'h8) begin
				  dskreg[7] <= 1'b0;
				  nmi <= 1'b0;
				  c_readbuf <= fdcstatus;
				end else begin
			     c_readbuf <= sram_databus;
				end
			 end
			 AVR_R: begin
			   avr_readbuf <= sram_databus;
			 end
			 COCO_W: begin
			   if (c_addrbus[3:0] == 4'h0) begin
				  intr[0] <= 1'b1;
				  dskreg <= c_databus;
				  fdcstatus[0] <= 1'b0;
				end else if (c_addrbus[3:0] == 4'h8) begin
			     if (c_databus[7:6] == 2'b10) // Type II operations set halt
				    halt <= 1'b1;
				  nmi <= 1'b0;
				  dskreg[7] <= 1'b0;
				  intr[1] <= 1'b1;
				end else if (c_addrbus[3:0] == 4'hb) begin
				  halt <= 1'b1;
				  fdcstatus[1] <= 1'b0;
				end
			   sram_we_n <= 1'b1;
			 end
			 AVR_W: begin
			   sram_we_n <= 1'b1;
			 end
		  endcase	 
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
  actor <= 1'b0;
  counter_50 <= 3'h4;
  sram_addrbus[15:0] <= { 11'b0000000000, c_addrbus[3:0], c_rw}; 
  if (c_rw)
    sram_databus <= 8'bz;
  else begin
    sram_we_n <= 1'b0;	   
    sram_databus <= c_databus;
  end
end
endtask

task cts_handler;
begin
    actor <= 1'b0;  // Coco
    counter_50 <= 3'h6;
    sram_addrbus[15:0] <= { 1'b1, c_addrbus[14:0]};
    sram_databus <= 8'bz;
    sram_we_n <= 1'b1;	   
end
endtask

task avr_command;
begin
  if (a_rw) begin
    if (a_addrbus == 16'h0000) begin  // Read from $ff40
	   avr_readbuf <= dskreg;
	   intr[0] <= 1'b0;
 	 end else if (a_addrbus == 16'h0011) begin // Read from $ff48 status reg
 	   avr_readbuf <= fdcstatus;
		intr[1] <= 1'b0;
	 end else begin
	   counter_50 <= 3'h4; // Use a 4 tick read cycle 20ns
		sram_addrbus <= a_addrbus;
		sram_databus <= 8'bz;
	   sram_we_n <= 1'b1;
		actor <= 1'b1;
 	 end
  end else begin
    if (a_addrbus == 16'h0011) begin // Write to $ff48
      fdcstatus <= a_databus;
    end else if (a_addrbus == 16'h0100) begin // Magic control port
      if (a_databus[0])
	     halt <= 1'b0;
	   if (a_databus[1]) begin
		  nmi <= 1'b1;
		  dskreg[7] <= 1'b0; // halt enable is cleared at the end of each command
		  halt <= 1'b0;	 
	   end
    end else begin
      counter_50 <= 3'h4; // Use a 4 tick write cycle 20ns
	   sram_addrbus[15:0] <= a_addrbus;
	   sram_databus[7:0] <= a_databus;
	   sram_we_n <= 1'b0;
	   actor <= 1'b1;
	 end
  end
end
endtask

endmodule
