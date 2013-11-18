`timescale 1ns/1ns

module cocofdc (c_eclk, c_scs_n, c_cts_n, c_slenb_n, c_databus, c_addrbus, c_nmi_n, c_halt_n, c_rw,
					clock_50, reset_n, intr, a_databus, a_addrbus, a_rw, a_sel, c_power, led);

// AVR
input [15:0] a_addrbus;
inout [7:0] a_databus;
input a_rw;
input a_sel;
output [1:0] intr;

// Coco
input [15:0] c_addrbus;
inout [7:0] c_databus;
input c_scs_n; // 0 = Coco register read/write 
input c_cts_n;
output c_slenb_n;
input c_eclk;
output c_halt_n;
output c_nmi_n;
input c_rw; // Coco read/write
input c_power;
input reset_n;

// Misc
input clock_50;
output [3:0] led;

reg [2:0] counter_50;     // 50MHz counter for SRAM read/write   
reg [1:0] intr;           // LOW to indicate SCS register changes since last SPI read
reg [2:0] cts_edge;
reg [2:0] scs_edge;
reg [2:0] avr_edge;

reg [7:0] avrbuf;
reg [7:0] cocobuf;
reg [2:0] req;				// Flags for pending requests { AVR, SCS }

reg nmi;                // Set if NMI output to Coco
reg avr_control; // set when AVR wants control of the flash
reg [7:0] dskreg;			// 0xff40
reg [7:0] fdcstatus;    // 0xff48 (r)
reg [7:0] fdccmd;       // 0xff48 (w)
reg [7:0] fdcsec;
reg [7:0] fdctrk;
reg [7:0] datareg;      // 0xff4b

// We have to handle shared access to the SRAM bus by both the Coco and the SPI bus.  Fortunately, both of them
// are extremely slow compared to the 20ns CPLD clock and SRAM speeds (<= 55ns).  So our goal is to track when the SRAM
// bus is in use, and queue up a write operation when needed.  For read accesses, we need to go into a wait loop until the bus is
// free.  The bus will free up in < 4 ticks, which is much less than a single SPI clock transition (assuming a 4MHz clock).  So we
// can afford to spin through the state machine a few times until it's ready.  For a Coco read, we do the read into a temporary read
// buffer, so that the bus is not tied up for the entirety of the Coco read cycle.
wire [7:0] a_memout;
wire [7:0] c_memout;

// 4MHZ SPI = 250ns
// 0.89MHz/1.78MHz Coco E clock = 1117ns/559ns
// 50MHz CPLD clock = 20ns

// Coco interrupt logic
wire fdc_halt = dskreg[7] & ~fdcstatus[1]; // high if FDC logic would halt coco
wire halt = fdc_halt | avr_control;
assign c_nmi_n = (nmi ? 1'b0 : 1'bz); // for FDC
assign c_halt_n = (halt ? 1'b0 : 1'bz); // for FDC

assign c_slenb_n = 1'bz;

wire c_memselect = ~c_cts_n;
wire c_regselect = ~c_scs_n & c_eclk;

assign a_databus = (~a_sel & a_rw ? avrbuf : 8'hzz);
assign c_databus = (c_rw ? (c_cts_n ? cocobuf : c_memout) : 8'hzz);

assign led = {1'b0, nmi, halt, avr_control};

// sync E clock, AVR, CTS, SCS with 50MHz osc
wire cts_falling_edge = (cts_edge[2:1] == 2'b10);
wire scs_falling_edge = (scs_edge[2:1] == 2'b01); // it's flipped because of the eclk timing
wire avr_falling_edge = (avr_edge[2:1] == 2'b10);

always @(posedge clock_50) begin
  cts_edge <= {cts_edge[1:0], c_cts_n};
  scs_edge <= {scs_edge[1:0], c_regselect};
  avr_edge <= {avr_edge[1:0], a_sel};
end

always @(negedge reset_n or posedge clock_50) begin
  if (!reset_n) begin
	 avr_control <= 1'b0;
	 intr <= 2'b11;
    req <= 3'b000;
 	 fdcstatus <= 8'b00000100;
	 dskreg <= 8'b0;
 	 nmi <= 1'b0;
  end else begin
   if (avr_falling_edge)
	   req[2] <= 1'b1;
   if (scs_falling_edge && c_power) 
	   req[1] <= 1'b1;
	if (cts_falling_edge)
		req[0] <= 1'b1;
	if (counter_50) begin // Deal with FLASH timing and buffering
		counter_50 <= counter_50 - 1'b1; // doesn't apply until next tick!
	   if (counter_50 == 3'h1  && a_rw) // Last count in cycle
		  avrbuf <= a_memout;
	 end else
	   // All of these happen on the next clock tick!
		// This functions as a very simple arbiter - AVR first because it has tighter timing, then
		// Coco.
	   casex (req)
  	     3'b1??: begin // AVR request pending	 
          avr_command();
 		    req[2] <= 1'b0;
		  end
		  3'b01?: begin // SCS request pending
          scs_handler();
		    req[1] <= 1'b0;
		  end
		  3'b001: begin // CTS request pending
			 cocobuf <= c_memout;
			 req[0] <= 1'b0;
		  end
		endcase
  end
end

task avr_command;
begin
  if (a_rw)
    case (a_addrbus)
	 16'hff40: begin
 	   avrbuf <= dskreg;
	   intr[0] <= 1'b1;
 	 end
	 16'hff51: // Read from $ff48 status reg
 	   avrbuf <= fdcstatus;
	 16'hff48: begin
	   avrbuf <= fdccmd;
		intr[1] <= 1'b1;
	 end
	 16'hff49:
	   avrbuf <= fdcsec;
	 16'hff4a:
	   avrbuf <= fdctrk;
	 16'hff4b:
	   avrbuf <= datareg;
	 default: begin
	   counter_50 <= 3'h1;
 	 end
    endcase
  else
    case (a_addrbus)
	 16'hff50: begin // device control register
	   avr_control <= a_databus[0];
      if (a_databus[1])
		  fdcstatus[1] <= 1'b1;
	   if (a_databus[2])
		  nmi <= 1'b1;
		if (a_databus[3])
		  dskreg[7] <= 1'b0; // halt enable is cleared at the end of each command
	 end  
	 16'hff40:
	   dskreg <= a_databus;
	 16'hff51:
	   fdcstatus <= a_databus;
	 16'hff49:
	   fdcsec <= a_databus;
	 16'hff4a:
	   fdctrk <= a_databus;
	 16'hff4b:
	   datareg <= a_databus;
	 default: begin
      counter_50 <= 3'h1;
	 end
  endcase
end
endtask

task scs_handler;
begin
  if (c_rw)
    case (c_addrbus)
	 16'hff48: begin
	   dskreg[7] <= 1'b0;
		nmi <= 1'b0;
		cocobuf <= fdcstatus;
	 end
	 16'hff49:
	   cocobuf <= fdcsec;
	 16'hff4a:
	   cocobuf <= fdctrk;
	 16'hff4b: begin
	   fdcstatus[1] <= 1'b0;
	   cocobuf <= datareg;
	 end
  endcase else
	 case (c_addrbus)
    16'hff40: begin // $ff40 (dskreg)
	   intr[0] <= 1'b0;
		dskreg <= c_databus;
		fdcstatus[0] <= 1'b0;
	 end
	 16'hff48: begin // $ff48 (fdccmd)
	   fdccmd <= c_databus; 
	   if (c_databus[7:6] == 2'b10) // Type II operations set halt
		  fdcstatus[1] <= 1'b0;
		intr[1] <= 1'b0;
	 end
	 16'hff49:
	   fdcsec <= c_databus;
	 16'hff4a:
	   fdctrk <= c_databus;
	 16'hff4b: begin // $ ff4b (datareg)
	   fdcstatus[1] <= 1'b0;
		datareg <= c_databus;
	 end
  endcase
end
endtask

dualmem m0(a_addrbus, c_addrbus, clock_50, a_databus, c_databus, ~a_rw, 1'b0, a_memout, c_memout);

endmodule
