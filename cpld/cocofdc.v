`timescale 1ns/1ns

module cocofdc (c_eclk, c_cts_n, c_scs_n, m_databus, c_databus, c_nmi_n, c_halt_n, c_reset_n, c_addrbus, m_addrbus, c_rw, miso, mosi, sclk, ss,
					m_cs1_n, m_cs2_n, m_we_n, m_oe_n, c_slenb_n, clock_50, reset, led);

input [14:0] c_addrbus; // Coco address bus
output [14:0] m_addrbus; // Memory address bus
inout [7:0] m_databus; // Memory databus
inout [7:0] c_databus; // 
input c_scs_n; // 0 = Coco register read/write 
input c_cts_n; // 0 = Coco ROM read
input c_eclk; // 1 = memory half of Coco bus cycle
output c_slenb_n;
output c_nmi_n;
input c_rw; // Coco read/write
input c_reset_n; // 0 = Coco reset
output [3:0] led;
output m_we_n;
output m_oe_n;
output m_cs1_n; // HIGH bank chip select
output m_cs2_n; // LOW bank chip select
output c_halt_n;
input sclk;
input clock_50;
input mosi;
input ss;
output miso;
input reset;

// SPI states
parameter SPI_IDLE = 3'b000, SPI_ADDR1 = 3'b001, SPI_ADDR2 = 3'b010, SPI_WRITE = 3'b011, SPI_READ = 3'b100, SPI_HALT1 = 3'b101, SPI_HALT2 = 3'b110;
// SPI command bytes
parameter SPI_CMD_ADDR = 8'h01, SPI_CMD_WRITE = 8'h02, SPI_CMD_READ = 8'h03, SPI_CMD_HALT = 8'h04, SPI_CMD_RESUME = 8'h05;

// Data from the SPI bus
wire spi_input_flag;     // Single clock tick flag indicating there is a byte available from SPI
wire [7:0] spi_rec;      // Databyte received from SPI - only valid on spi_input_flag high
reg [15:0] spi_address;  // Stored SPI address - avoids having to send address for each read/write
reg [3:0] spi_state;     // spi_state of the SPI spi_state machine
reg spi_cdisable;        // High if coco is disabled

reg [3:0] e_counter;     // E clock counter for HALT
reg [2:0] counter_50;     // 50MHz counter for SRAM read/write   
reg dirty;               // HIGH to indicate SCS register changes since last SPI read
reg [2:0] eclk_edge;     // Synchonizer for Coco E clock and 50MHz CPLD clock
reg c_halt_n;            // Coco HALT pin register

SPI_slave u0(.clk(clock_50), .SCK(sclk), .MISO(miso), .MOSI(mosi), .SSEL(ss), .byte_received(spi_input_flag), .byte_data_received(spi_rec), 
	.byte_send(spi_readbuf));

// We have to handle shared access to the SRAM bus by both the Coco and the SPI bus.  Fortunately, both of them
// are extremely slow compared to the 20ns CPLD clock and SRAM speeds (<= 55ns).  So our goal is to track when the SRAM
// bus is in use, and queue up a write operation when needed.  For read accesses, we need to go into a wait loop until the bus is
// free.  The bus will free up in < 4 ticks, which is much less than a single SPI clock transition (assuming a 4MHz clock).  So we
// can afford to spin through the state machine a few times until it's ready.  For a Coco read, we do the read into a temporary read
// buffer, so that the bus is not tied up for the entirety of the Coco read cycle.

// 4MHZ SPI = 250ns
// 0.89MHz/1.78MHz Coco E clock = 1117ns/559ns
// 50MHz CPLD clock = 20ns
	
reg [7:0] spi_readbuf;  // Databyte being sent to SPI - update only when spi_input_flag high (for next SPI cycle)
reg [7:0] c_readbuf;    // SRAM stores in this register for the fairly long E Coco read cycle
reg [7:0] writebuf;     // If the SRAM is in use, writes a buffered here
reg pending;
reg pending_type;       // Read or write action pending: 0 = write, 1 = read
reg actor;              // Who initiated read or write cycle, or added to pending: 0 = coco, 1 = spi

parameter COCO_W = 2'b00, COCO_R = 2'b10, SPI_W = 2'b01, SPI_R = 2'b11;

wire sram_inuse = |{counter_50};

reg [17:0] m_addrbus;
reg [15:0] m_databus;
reg m_we_n;

assign sram_lb_n = 1'b0;
assign sram_ub_n = 1'b1;
assign sram_ce_n = 1'b0;
assign sram_oe_n = ~m_we_n;

assign c_slenb_n = 1'bz;
assign c_cart_n = 1'bz;
assign c_nmi_n = 1'bz;

wire c_regselect = ~c_scs_n & c_eclk & c_reset_n;
wire c_memselect = ~c_cts_n & c_reset_n;
wire c_select = c_regselect | c_memselect;
assign c_dataen_n =  ~c_select | spi_cdisable;
assign c_databus = (c_rw & c_select ? c_readbuf : 8'bz); 


// sync E clock with 50MHz osc
always @(posedge clock_50)
  eclk_edge = {eclk_edge[1:0], c_eclk};
wire eclk_rising_edge = (eclk_edge[2:1] == 2'b01);

task spi_command;
input [7:0] b;
begin
  case (spi_state)
	 SPI_IDLE: // Waiting for command byte
		case (b)
		  SPI_CMD_ADDR: spi_state <= SPI_ADDR1; // set addr
		  SPI_CMD_WRITE: spi_state <= SPI_WRITE; // write byte
		  SPI_CMD_READ: begin
		    if (sram_inuse) begin
				pending <= 1'b1;
				pending_type <= 1'b1;
		    end else begin
				counter_50 <= 3'h4; // Use a 4 tick read cycle 20ns
				m_addrbus[15:0] <= spi_address;
				m_databus[7:0] <= 8'bz;
				m_we_n <= 1'b1;
		      actor <= 1'b1;
		    end
          spi_state <= SPI_READ;
		  end
		  SPI_CMD_HALT: begin
			 spi_readbuf <= 8'hff; // all ones if busy
			 c_halt_n <= 1'b0; // halt processor
			 e_counter <= 4'hf; // count 16 e clock cycles
			 spi_state <= SPI_HALT1;
		  end
		  SPI_CMD_RESUME: begin
		    spi_cdisable <= 1'b0; // release bus control
			 c_halt_n <= 1'bz; // unhalt processor
			 spi_state <= SPI_IDLE;
		  end
		  default: spi_state <= 4'h0; // ignore bytes we don't know
		endcase
    SPI_ADDR1: begin
		spi_address <= (b << 8);
		spi_state <= SPI_ADDR2;
    end
	 SPI_ADDR2: begin // Set address, wait for ll
	   spi_address <= spi_address + b;
		spi_state <= SPI_IDLE;
    end
	 SPI_WRITE: begin     // write byte xx
	   if (sram_inuse) begin
		  writebuf <= b;
		  pending <= 1'b1;
		  pending_type <= 1'b0;
		end else begin
		  counter_50 <= 3'h4; // Use a 4 tick write cycle 20ns
		  m_addrbus[15:0] <= spi_address;
		  m_databus[7:0] <= b;
		  m_we_n <= 1'b0;
		end
		actor <= 1'b1;
		spi_state <= SPI_IDLE;
	 end
	 SPI_READ: begin // clock out read byte
		if (!spi_address[15]) // Clear the read markers
		  dirty <= 1'b0;
	   spi_address <= spi_address + 1'b1;
	   spi_state <= SPI_IDLE;
	 end
	 SPI_HALT1: begin // wait until Coco is halted
	   if (!spi_cdisable) begin
		  spi_readbuf <= 8'hff;
		  spi_state <= SPI_HALT1;
		end else begin
		  spi_readbuf <= 8'h00;
		  spi_state <= SPI_HALT2;
	   end
	 end
	 SPI_HALT2: begin // clock out last status byte for halt spi_state
	   spi_state <= SPI_IDLE;
	 end
    default:
	   spi_state <= SPI_IDLE;
  endcase
end
endtask

always @(negedge reset or posedge clock_50) begin
  if (!reset) begin
    spi_state <= SPI_IDLE;
	 spi_address <= 16'h0;
	 c_halt_n <= 1'bz;
	 spi_cdisable <= 1'b0;
	 dirty <= 1'b0;
	 counter_50 <= 3'b0;
	 e_counter <= 4'b0;
	 m_databus <= 8'bz;
	 m_addrbus <= 16'bz;
	 m_we_n <= 1'b1;
	 pending <= 1'b0;
	 
  end else begin
    if (sram_inuse) begin // we're either in the process of reading or writing
	   if (counter_50 == 3'h1) begin // Last count in cycle
		  case ({m_we_n, actor})
	       COCO_R: begin
			   spi_readbuf <= m_databus[7:0];
			 end
			 SPI_R: begin
			   c_readbuf <= m_databus[7:0];
            spi_address <= spi_address + 1'b1;
			 end
			 COCO_W: begin
			   if (c_regselect & ~c_rw) // this may not be the correct timing...
	           dirty <= 1'b1;
			   m_we_n <= 1'b1;
			 end
			 SPI_W:
			   m_we_n <= 1'b1;
			endcase
			if (pending) begin // Another transaction?
			  case ({pending_type, ~actor})
			    COCO_W: begin
		         m_addrbus[15:0] <= { ~c_regselect, c_addrbus[14:0] };
		         m_databus[7:0] <= writebuf;
		         m_we_n <= 1'b0;	   
				 end
				 COCO_R: begin
		         m_addrbus[15:0] <= { ~c_regselect, c_addrbus[14:0] };
		         m_databus[7:0] <= 8'bz;
		         m_we_n <= 1'b1;	   
				 end
				 SPI_W: begin
		         m_addrbus[15:0] <= spi_address;
		         m_databus[7:0] <= writebuf;
		         m_we_n <= 1'b0;	   
				 end
				 SPI_R: begin
		         m_addrbus[15:0] <= spi_address;
		         m_databus[7:0] <= 8'bz;
		         m_we_n <= 1'b1;	   
				 end
			  endcase
			  actor <= ~actor;
			  pending <= 1'b0;
			  counter_50 <= 3'h4;
			end
		end
	   counter_50 <= counter_50 - 1'b1;
    end

	 // Deal with HALT request from SPI
	 if (spi_state == SPI_HALT1 && (eclk_rising_edge || !c_reset_n)) begin
	   if (e_counter == 4'h0)
		  spi_cdisable <= 1'b1;
	   e_counter <= e_counter - 1'b1;
	 end
	 
	 // Check for Coco SCS accesses
	 if (c_regselect) begin
	   if (sram_inuse) begin
		  pending <= 1'b1;
		  pending_type <= c_rw;
		end else begin
		  actor <= 1'b0;
		  counter_50 <= 3'h4;
		  m_addrbus[15:0] <= { 1'b0, c_addrbus[14:0]};
		  if (c_rw)
		    m_databus[7:0] <= 8'bz;
		  else begin
		    m_databus[7:0] <= c_databus;
			 dirty <= 1'b1;
		  end
		end
	 end
	 
	 // Check for Coco CTS accesses
	 if (c_memselect) begin
	   if (sram_inuse) begin
		  pending <= 1'b1;
		  pending_type <= 1'b1; // Force read
		end else begin
		  actor <= 1'b0;
		  counter_50 <= 3'h4;
		  m_addrbus[15:0] <= { 1'b0, c_addrbus[14:0]};
		  m_databus[7:0] <= 8'bz;
		end  
	 end 
	 
	 // Check SPI input
    if (spi_input_flag)
      spi_command(spi_rec);
  end
end

/*

SPI_slave u0(.clk(clock_50), .SCK(sclk), .MISO(miso), .MOSI(mosi), .SSEL(ss), .byte_received(spi_input_flag), .byte_data_received(spi_rec), 
    .byte_send(spi_databyte));

// State of the state machine
reg [2:0] state;
wire c_select;

// Data from the SPI bus
wire spi_input_flag;
wire [7:0] spi_rec;
reg [7:0] spi_databyte;
reg [15:0] spi_address;

// Does the SPI bus have control?
reg spi_control;
reg spi_haltreq;
reg spi_rw;
reg [3:0] counter;
reg [2:0] eclk_edge;
reg c_halt_n;

// sync E clock with 50MHz osc
always @(posedge clock_50)
  eclk_edge = {eclk_edge[1:0], c_eclk};
wire eclk_rising_edge = (eclk_edge[2:1] == 2'b01);

// Basic bus control logic
assign c_select = ((~c_scs_n & c_eclk) | ~c_cts_n) & c_reset_n;
assign m_addrbus = (spi_control ? spi_address[14:0] : (c_reset_n ? c_addrbus : 15'b0));

assign c_databus = (m_we_n ? m_databus : 8'bz);
assign m_databus = (m_we_n ? 8'bz : (spi_control ? spi_databyte : c_databus));

assign m_cs1_n = ~((spi_control & spi_address[15]) | (c_select & ~c_cts_n));
assign m_cs2_n = ~m_cs1_n;
assign m_oe_n = (spi_control ? ~spi_rw : ~(c_select & c_rw));
assign m_we_n = (spi_control ? spi_rw : c_rw);

// Safe defaults
assign c_slenb_n = 1'bz;
assign c_nmi_n = 1'bz;

assign led = { spi_control, state};

task statelogic;
input [7:0] b;
begin
  case (state)
	 3'h0: // Waiting for command byte
		case (b)
		  8'h01: state <= 3'h1; // set addr
		  8'h02: state <= 3'h3; // write byte
		  8'h03: begin // read byte
		    spi_databyte <= m_databus;
          state <= 3'h4;
		  end
		  8'h04: begin // request bus
			 spi_databyte <= 8'hff; // all ones if busy
			 c_halt_n <= 1'b0; // halt processor
			 counter <= 4'hf; // count 16 clock cycles
			 state <= 3'h5;
		  end
		  8'h05: begin
		    spi_control <= 1'b0; // release bus control
			 c_halt_n <= 1'bz; // unhalt processor
			 state <= 3'h0;
		  end
		  default: state <= 3'h0; // ignore bytes we don't know
		endcase
    3'h1: begin // Set address, wait for hh
		spi_address <= (b << 8);
		state <= 3'h2;
    end
	 3'h2: begin // Set address, wait for ll
	   spi_address <= spi_address + b;
		state <= 3'h0;
    end
	 3'h3: begin     // write byte xx
	   spi_databyte <= b;
		counter <= 3'h6;
		state <= 3'h0;
	 end
	 3'h4: begin // clock out read byte
	   spi_address <= spi_address + 1'b1;
	   state <= 3'h0;
	 end
	 3'h5: begin // wait until Coco is halted
	   if (!spi_control) begin
		  spi_databyte <= 8'hff;
		  state <= 3'h5;
		end else begin
		  spi_databyte <= 8'h00;
		  state <= 3'h6;
	   end
	 end
	 3'h6: begin // clock out last status byte for halt state
	   state <= 3'h0;
	 end
    default:
	   state <= 3'h0;
  endcase
end
endtask

always @(negedge reset or posedge clock_50) begin
  if (!reset) begin
    state <= 3'h0;
	 spi_address <= 16'h0;
	 spi_control <= 1'b0;
	 spi_rw <= 1'b1;
	 counter <= 4'b0;
  end else begin
	 if (state == 3'h5 && (eclk_rising_edge || !c_reset_n)) begin
	   if (counter == 4'h0)
		  spi_control <= 1'b1;
	   counter <= counter - 1'b1;
	 end
	 if (state == 3'h0) begin
      if (counter == 0)
  	     spi_rw <= 1'b1;
	   else if (counter == 1) begin
	     spi_rw <= 1'b0;
        spi_address <= spi_address + 1'b1;
		  counter <= counter - 1'b1;
	   end else begin
	     spi_rw <= 1'b0;
		  counter <= counter - 1'b1;
	   end
	 end
    if (spi_input_flag)
      statelogic(spi_rec);
  end
end
*/
endmodule
