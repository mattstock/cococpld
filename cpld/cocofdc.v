`timescale 1ns/1ns

module cocofdc (c_eclk, c_cts_n, c_scs_n, sram_databus, c_databus, c_nmi_n, c_halt_n, c_reset_n, c_addrbus, sram_addrbus, c_rw, miso, mosi, sclk, ss,
					sram_we_n, sram_oe_n, c_slenb_n, clock_50, reset, led, dirty);

input [14:0] c_addrbus; // Coco address bus
output reg [15:0] sram_addrbus; // Memory address bus
inout reg [7:0] sram_databus; // Memory databus
inout [7:0] c_databus; // 
input c_scs_n; // 0 = Coco register read/write 
input c_cts_n; // 0 = Coco ROM read
input c_eclk; // 1 = memory half of Coco bus cycle
output c_slenb_n;
output c_nmi_n;
input c_rw; // Coco read/write
input c_reset_n; // 0 = Coco reset
output [3:0] led;
output reg sram_we_n;
output sram_oe_n;
output c_halt_n;
output dirty;
input sclk;
input clock_50;
input mosi;
input ss;
output miso;
input reset;

// SPI states
parameter SPI_IDLE = 3'b000, SPI_ADDR1 = 3'b001, SPI_ADDR2 = 3'b010, SPI_WRITE = 3'b011, SPI_READ = 3'b100;
// SPI command bytes
parameter SPI_CMD_ADDR = 8'h01, SPI_CMD_WRITE = 8'h02, SPI_CMD_READ = 8'h03;
parameter COCO_W = 2'b00, COCO_R = 2'b10, SPI_W = 2'b01, SPI_R = 2'b11;

// Data from the SPI bus
wire spi_input_flag;     // Single clock tick flag indicating there is a byte available from SPI
wire [7:0] spi_rec;      // Databyte received from SPI - only valid on spi_input_flag high
reg [15:0] spi_address;  // Stored SPI address - avoids having to send address for each read/write
reg [3:0] spi_state;     // spi_state of the SPI spi_state machine
reg spi_send_ready;
reg [7:0] spi_readbuf;  // Databyte being sent to SPI - update only when spi_input_flag high (for next SPI cycle)

reg [2:0] counter_50;     // 50MHz counter for SRAM read/write   
reg dirty;               // HIGH to indicate SCS register changes since last SPI read
reg [2:0] eclk_edge;     // Synchonizer for Coco E clock and 50MHz CPLD clock
reg [2:0] cts_edge;
reg [2:0] scs_edge;

reg [7:0] c_readbuf;    // SRAM stores in this register for the fairly long E Coco read cycle
reg [7:0] writebuf;     // If the SRAM is in use, writes a buffered here
reg actor;              // Who initiated read or write cycle, or added to pending: 0 = coco, 1 = spi
reg [2:0] req;				// Flags for pending requests { SPI, SCS, CTS }

SPI_slave u0(.clk(clock_50), .SCK(sclk), .MISO(miso), .MOSI(mosi), .SSEL(ss), .byte_received(spi_input_flag), .byte_data_received(spi_rec), 
	.byte_send(spi_readbuf), .send_latch(spi_send_ready));

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
assign c_nmi_n = 1'bz;
assign c_halt_n = 1'bz;

assign led = {req, c_rw };

wire cts_falling_edge = (cts_edge[2:1] == 2'b10);
wire scs_falling_edge = (scs_edge[2:1] == 2'b01); // it's flipped because of the eclk timing
wire c_regselect = ~c_scs_n & c_eclk;
wire c_memselect = ~c_cts_n;
wire c_select = c_reset_n & (c_regselect | c_memselect);

assign c_databus = (c_rw & c_select ? c_readbuf : 8'bz); 

// sync E clock, CTS, SCS with 50MHz osc
always @(posedge clock_50) begin
  eclk_edge <= {eclk_edge[1:0], c_eclk};
  cts_edge <= {cts_edge[1:0], c_cts_n};
  scs_edge <= {scs_edge[1:0], ~c_scs_n & c_eclk};
end

always @(negedge reset or posedge clock_50) begin
  if (!reset) begin
    spi_state <= SPI_IDLE;
	 spi_address <= 16'h0;
    spi_send_ready <= 1'b0;
	 dirty <= 1'b0;
	 counter_50 <= 3'b0;
	 sram_databus <= 8'bz;
//	 sram_addrbus <= 16'b0;
	 sram_we_n <= 1'b1;
	 req <= 3'b0;
  end else begin
    if (spi_input_flag)
	   req[2] <= 1'b1;
    if (scs_falling_edge && c_reset_n) 
	   req[1] <= 1'b1;
    if (cts_falling_edge && c_reset_n)
		req[0] <= 1'b1;
	 if (counter_50) begin // Deal with SRAM timing and buffering
		counter_50 <= counter_50 - 1'b1; // doesn't apply until next tick!
	   if (counter_50 == 3'h1) // Last count in cycle
		  case ({sram_we_n, actor})
	       COCO_R: begin
			   c_readbuf <= sram_databus[7:0];
			 end
			 SPI_R: begin
            spi_address <= spi_address + 1'b1;
			   spi_readbuf <= sram_databus;
				spi_send_ready <= 1'b1;
			 end
			 COCO_W: begin
			   if (~c_rw)
	           dirty <= 1'b1;
			   sram_we_n <= 1'b1;
			 end
			 SPI_W: begin
			   sram_we_n <= 1'b1;
				spi_address <= spi_address + 1'b1;
			 end
		  endcase	 
	 end else
	   // All of these happen on the next clock tick!
		// This functions as a very simple arbiter - SPI first because it has tighter timing, then
		// Coco.
	   casex (req)
  	     3'b1xx: begin // SPI byte waiting	 
          spi_command();
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
    actor <= 1'b0; // Coco
    counter_50 <= 3'h4;
    sram_addrbus <= { 1'b0, c_addrbus};
    if (c_rw)
      sram_databus <= 8'bz;
    else begin
      sram_we_n <= 1'b0;	   
      sram_databus <= c_databus;
      dirty <= 1'b1;
    end
end
endtask

task cts_handler;
begin
    actor <= 1'b0;  // Coco
    counter_50 <= 3'h4;
    sram_addrbus <= { 1'b1, c_addrbus};
    sram_databus <= 8'bz;
    sram_we_n <= 1'b1;	   
end
endtask

task spi_command;
begin
  case (spi_state)
	 SPI_IDLE: // Waiting for command byte
		case (spi_rec)
		  SPI_CMD_ADDR: spi_state <= SPI_ADDR1; // set addr
		  SPI_CMD_WRITE: spi_state <= SPI_WRITE; // write byte
		  SPI_CMD_READ: begin
		    counter_50 <= 3'h4; // Use a 4 tick read cycle 20ns
			 sram_addrbus <= spi_address;
			 sram_databus <= 8'bz;
			 sram_we_n <= 1'b1;
		    spi_send_ready <= 1'b0;
		    actor <= 1'b1;
          spi_state <= SPI_READ;
		  end
		  default: spi_state <= SPI_IDLE; // ignore bytes we don't know
		endcase
    SPI_ADDR1: begin
		spi_address <= (spi_rec << 8);
		spi_state <= SPI_ADDR2;
    end
	 SPI_ADDR2: begin // Set address, wait for ll
	   spi_address <= spi_address + spi_rec;
		spi_state <= SPI_IDLE;
    end
	 SPI_WRITE: begin     // write byte xx
	   counter_50 <= 3'h4; // Use a 4 tick write cycle 20ns
		sram_addrbus <= spi_address;
		sram_databus <= spi_rec;
		sram_we_n <= 1'b0;
		actor <= 1'b1;
		spi_state <= SPI_IDLE;
	 end
	 SPI_READ: begin // clock out read byte
		if (!spi_address[15]) // Clear the read markers
		  dirty <= 1'b0;
	   spi_state <= SPI_IDLE;
	 end
    default:
	   spi_state <= SPI_IDLE;
  endcase
end
endtask

endmodule
