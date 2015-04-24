`timescale 1ns/1ns

module cocofdc (
  input clock_50,
  input c_eclk,
  input c_cts_n,
  input c_scs_n,
  output c_slenb_n,
  output c_nmi_n,
  output c_halt_n,
  inout [7:0] c_databus,
  input [14:0] c_addrbus,
  input c_reset_n,
  input c_rw,
  inout [7:0] sram_databus,
  output [15:0] sram_addrbus,
  output sram_we_n,
  output sram_oe_n,
  output sram_ce_n,
  output miso,
  input mosi,
  input ss,
  input sclk,
  input reset,
  output [3:0] led,
  output reg dirty);

// SPI states
localparam SPI_IDLE = 3'h0, SPI_ADDR1 = 3'h1, SPI_ADDR2 = 3'h2, SPI_WRITE = 3'h3, SPI_READ = 3'h4, SPI_BANK = 3'h5;
localparam STATE_IDLE = 2'h0, STATE_MEMREAD = 2'h1, STATE_MEMWRITE = 2'h2;

// SPI command bytes
localparam SPI_CMD_ADDR = 8'h01, SPI_CMD_WRITE = 8'h02, SPI_CMD_READ = 8'h03, SPI_CMD_BANK = 8'h04;

// Data from the SPI bus
wire spi_input_flag;     // Single clock tick flag indicating there is a byte available from SPI
wire [7:0] spi_rec;      // Databyte received from SPI - only valid on spi_input_flag high

reg [15:0] spi_address, spi_address_next;  // Stored SPI address - avoids having to send address for each read/write
reg [2:0] spi_state, spi_state_next;     // spi_state of the SPI spi_state machine
reg [1:0] state, state_next;
reg spi_send_ready, spi_send_ready_next;
reg [7:0] spi_readbuf, spi_readbuf_next;
reg [7:0] spi_writebuf, spi_writebuf_next;
reg [2:0] req, req_next;				// Flags for pending requests { SPI, SCS, CTS }
reg actor, actor_next;
reg dirty_next;
reg [7:0] c_readbuf, c_readbuf_next;    // SRAM stores in this register for the fairly long E Coco read cycle
reg [2:0] delay, delay_next;     // counter for SRAM read/write timing
reg scs, scs_next; // SCS or CTS op
reg [2:0] bank, bank_next;

// Synchonizers for Coco E clock and CPLD clock
reg [2:0] eclk_edge;
reg [2:0] cts_edge;
reg [2:0] scs_edge;

// We have to handle shared access to the SRAM bus by both the Coco and the SPI bus.  Fortunately, both of them
// are extremely slow compared to the 20ns CPLD clock and SRAM speeds (<= 55ns).  So our goal is to track when the SRAM
// bus is in use, and queue up a write operation when needed.  For read accesses, we need to go into a wait loop until the bus is
// free.  The bus will free up in < 4 ticks, which is much less than a single SPI clock transition (assuming a 4MHz clock).  So we
// can afford to spin through the state machine a few times until it's ready.  For a Coco read, we do the read into a temporary read
// buffer, so that the bus is not tied up for the entirety of the Coco read cycle.

// 4MHZ SPI = 250ns
// 0.89MHz/1.78MHz Coco E clock = 1117ns/559ns
// 50MHz CPLD clock = 20ns
	

wire cts_falling_edge = (cts_edge[2:1] == 2'b10);
wire scs_falling_edge = (scs_edge[2:1] == 2'b01); // it's flipped because of the eclk timing
wire c_regselect = ~c_scs_n & c_eclk;
wire c_memselect = ~c_cts_n;
wire c_select = c_reset_n & (c_regselect | c_memselect);

assign sram_ce_n = 1'b0;
assign sram_oe_n = ~sram_we_n;
assign sram_we_n = ~(state == STATE_MEMWRITE);
assign sram_databus = (sram_we_n ? 8'hzz : (actor ? spi_readbuf : c_databus ));
assign sram_addrbus = (actor ? spi_address : (scs ? { 10'h3ff, c_addrbus[5:0]} : { bank, c_addrbus[12:0] }));
assign c_databus = (c_rw & c_select ? c_readbuf : 8'bz); 
assign c_slenb_n = 1'bz;
assign c_nmi_n = 1'bz;
assign c_halt_n = 1'bz;
assign led = { req, sram_oe_n };

// sync E clock, CTS, SCS with 50MHz osc
always @(posedge clock_50) begin
  eclk_edge <= {eclk_edge[1:0], c_eclk};
  cts_edge <= {cts_edge[1:0], c_cts_n};
  scs_edge <= {scs_edge[1:0], ~c_scs_n & c_eclk};
end

always @(posedge clock_50 or negedge reset) begin
  if (!reset) begin
    state <= STATE_IDLE;
    spi_state <= SPI_IDLE;
    spi_address <= 16'h0000;
    spi_readbuf <= 8'h00;
    spi_writebuf <= 8'h00;
    spi_send_ready <= 1'b0;
    req <= 3'b000;
    actor <= 1'b0;
    dirty <= 1'b0;
    delay <= 3'h0;
    c_readbuf <= 8'h00;
    scs <= 1'b0;
    bank <= 3'b000;
  end else begin
    state <= state_next;
    spi_state <= spi_state_next;
    spi_address <= spi_address_next;
    spi_readbuf <= spi_readbuf_next;
    spi_writebuf <= spi_writebuf_next;
    spi_send_ready <= spi_send_ready_next;
    req <= req_next;
    actor <= actor_next;
    dirty <= dirty_next;
    delay <= delay_next;
    c_readbuf <= c_readbuf_next;
    scs <= scs_next;
    bank <= bank_next;
  end
end

always @* begin
  state_next = state;
  spi_state_next = spi_state;
  spi_address_next = spi_address;
  spi_readbuf_next = spi_readbuf;
  spi_writebuf_next = spi_writebuf;
  spi_send_ready_next = spi_send_ready;
  req_next = req;
  actor_next = actor;
  dirty_next = dirty;
  delay_next = delay;
  scs_next = scs;
  bank_next = bank;
  c_readbuf_next = c_readbuf;
  
  /* These can queue in any state */
  if (spi_input_flag) begin
    req_next[2] = 1'b1;
    spi_readbuf_next = spi_rec;
  end
  if (scs_falling_edge && c_reset_n) 
	  req_next[1] = 1'b1;
  if (cts_falling_edge && c_reset_n)
	  req_next[0] = 1'b1;
  
  case (state)
    STATE_IDLE:
	    casex (req)
  	    3'b1xx: begin // SPI byte waiting	 
          spi_command();
 		      req_next[2] = 1'b0;
		    end
		    3'b01x: begin // SCS request pending
          actor_next = 1'b0; // Coco
          scs_next = 1'b1;
          if (c_rw) begin
            state_next = STATE_MEMREAD;
          end else begin
            state_next = STATE_MEMWRITE;
            dirty_next = 1'b1;
          end
		      req_next[1] = 1'b0;
		    end
		    3'b001: begin // CTS request pending
          actor_next = 1'b0;  // Coco
          scs_next = 1'b0;
          state_next = STATE_MEMREAD;
		      req_next[0] = 1'b0;
		    end
        default: state_next = state;
		  endcase
    STATE_MEMWRITE: begin
	    if (delay == 3'h0)
        delay_next = 3'h7;
      else
        delay_next = delay - 1'b1;
      if (delay == 3'h1) begin
        if (actor)
          spi_address_next = spi_address + 1'b1;
        else
          dirty_next = 1'b1;
        state_next = STATE_IDLE;
      end
    end  
    STATE_MEMREAD: begin
      if (delay == 3'h0)
        delay_next = 3'h7;
      else
        delay_next = delay - 1'b1;
      if (delay == 3'h1) begin
        if (actor) begin
          spi_address_next = spi_address + 1'b1;
          spi_writebuf_next = sram_databus;
          spi_send_ready_next = 1'b1;
        end else
          c_readbuf_next = sram_databus;
        state_next = STATE_IDLE;
      end   
    end
    default: state_next = STATE_IDLE;
  endcase
end

task spi_command;
begin
  case (spi_state)
	  SPI_IDLE: // Waiting for command byte
		  case (spi_readbuf)
		    SPI_CMD_ADDR: spi_state_next = SPI_ADDR1; // set addr
		    SPI_CMD_WRITE: spi_state_next = SPI_WRITE; // write byte
		    SPI_CMD_READ: begin
          state_next = STATE_MEMREAD;
          spi_state_next = SPI_READ;
		      actor_next = 1'b1;
		    end
        SPI_CMD_BANK: spi_state_next = SPI_BANK; // write to bank register
		    default: spi_state_next = SPI_IDLE; // ignore bytes we don't know
		  endcase
    SPI_ADDR1: begin
		  spi_address_next[15:8] = spi_readbuf;
		  spi_state_next = SPI_ADDR2;
    end
	  SPI_ADDR2: begin // Set address, wait for ll
	    spi_address_next[7:0] = spi_readbuf;
		  spi_state_next = SPI_IDLE;
    end
	  SPI_WRITE: begin     // write byte xx
      state_next = STATE_MEMWRITE;
      spi_state_next = SPI_IDLE;
		  actor_next = 1'b1;
	  end
	  SPI_READ: begin // clock out read byte
		  if (!spi_address[15]) // Clear the read markers
		    dirty_next = 1'b0;
	    spi_state_next = SPI_IDLE;
	  end
    SPI_BANK: begin // write to bank reg
      bank_next = spi_readbuf[2:0];
      spi_state_next = SPI_IDLE;
    end
    default: spi_state_next = SPI_IDLE;
  endcase
end
endtask

SPI_slave u0(.clk(clock_50), .SCK(sclk), .MISO(miso), .MOSI(mosi), .SSEL(ss), .byte_received(spi_input_flag), .byte_data_received(spi_rec), 
	.byte_send(spi_writebuf), .send_latch(spi_send_ready));

endmodule
