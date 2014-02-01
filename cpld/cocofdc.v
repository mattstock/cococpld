`timescale 1ns/1ns

module cocofdc (c_eclk, c_cts_n, c_scs_n, sram_databus, c_databus, c_addrbus, c_nmi_n, c_halt_n, sram_addrbus, c_rw, 
  sram_we_n, sram_oe_n, sram_ce_n, c_slenb_n, clock_50, reset_n, led, dsk_cmd_intr, dsk_cfg_intr, c_power,
  miso, avr_mosi, avr_mem_ss, avr_sclk, avr_sd_ss,
  sd_mosi, sd_ss, sd_sclk);

// SRAM
output [15:0] sram_addrbus;
inout [7:0] sram_databus;
output sram_ce_n;
output sram_we_n;
output sram_oe_n;

// Coco
input [14:0] c_addrbus;
input c_power;
inout [7:0] c_databus;
input c_scs_n; // 0 = Coco register read/write 
input c_cts_n; // 0 = Coco ROM read
input c_eclk; // 1 = memory half of Coco bus cycle
output c_slenb_n;
output c_nmi_n;
input c_rw; // Coco read/write
input reset_n; 
output c_halt_n;

// AVR
input avr_mosi;
output miso;
input avr_mem_ss;
input avr_sd_ss;
input avr_sclk;
output sd_mosi;
output sd_sclk;
output sd_ss;
output reg dsk_cmd_intr;
output reg dsk_cfg_intr;

// Misc
output [3:0] led;
input clock_50;

assign sd_mosi = avr_mosi;
assign sd_sclk = avr_sclk;
assign sd_ss = avr_sd_ss;

reg actor;              // Who initiated read or write cycle, or added to pending: 0 = coco, 1 = spi
reg [2:0] mem_delay;     // 50MHz counter for SRAM read/write   
reg [2:0] cts_edge;
reg [2:0] scs_edge;

reg [2:0] spi_state;    // State machine for SPI commands
reg [7:0] spi_tx;
reg spi_tx_flag;
reg [7:0] cocobuf;
reg [2:0] req;				// Flags for pending requests { AVR, SCS }

reg nmi;                // Set if NMI output to Coco
reg avr_control; // set when AVR wants control of the flash

reg [15:0] spi_addr;
reg [7:0] srambuf;
reg sram_we_n;

reg [7:0] dskreg;			// 0xff40
reg [7:0] fdcstatus;    // 0xff48 (r)
reg [7:0] fdccmd;

// We have to handle shared access to the SRAM bus by both the Coco and the SPI bus.  Fortunately, both of them
// are extremely slow compared to the 20ns CPLD clock and SRAM speeds (<= 55ns).  So our goal is to track when the SRAM
// bus is in use, and queue up a write operation when needed.  For read accesses, we need to go into a wait loop until the bus is
// free.  The bus will free up in < 4 ticks, which is much less than a single SPI clock transition (assuming a 4MHz clock).  So we
// can afford to spin through the state machine a few times until it's ready.  For a Coco read, we do the read into a temporary read
// buffer, so that the bus is not tied up for the entirety of the Coco read cycle.

// 4MHZ SPI = 250ns
// 0.89MHz/1.78MHz Coco E clock = 1117ns/559ns
// 50MHz CPLD clock = 20ns

assign led = { 2'b00, nmi, halt };

wire miso;
wire spi_rx_flag;
wire [7:0] spi_rx;
	
assign sram_oe_n = ~sram_we_n;

assign c_slenb_n = 1'bz;
assign sram_ce_n = 1'b0;

wire cts_falling_edge = (cts_edge[2:1] == 2'b10);
wire scs_falling_edge = (scs_edge[2:1] == 2'b01); // it's flipped because of the eclk timing
wire c_regselect = ~c_scs_n & c_eclk;
wire c_memselect = ~c_cts_n;
wire c_select = (c_regselect | c_memselect) & c_power;

assign c_databus = (c_rw & c_select ? cocobuf : 8'hzz);
assign sram_databus = (sram_we_n ? 8'hzz : srambuf); 
assign sram_addrbus = (actor ? spi_addr : c_addrbus);
wire fdc_halt = dskreg[7] & ~fdcstatus[1];
wire halt = fdc_halt | avr_control;
assign c_nmi_n = (nmi ? 1'b0 : 1'bz); // for FDC
assign c_halt_n = (halt ? 1'b0 : 1'bz); // for FDC

// sync E clock, AVR, CTS, SCS with 50MHz osc
always @(posedge clock_50) begin
  cts_edge <= {cts_edge[1:0], c_cts_n};
  scs_edge <= {scs_edge[1:0], c_regselect};
end

// SPI state machine nodes
parameter SPI_IDLE = 3'h0, SPI_ADDR1 = 3'h1, SPI_ADDR2 = 3'h2, SPI_WRITE = 3'h3, SPI_READ = 3'h4, SPI_DEVCON = 3'h5;

// SPI commands
parameter SPI_CMD_ADDR = 8'h1, SPI_CMD_WRITE = 8'h2, SPI_CMD_READ = 8'h3, SPI_CMD_READ_STATUS = 8'h4, SPI_CMD_DEVCON = 8'h5;

// Helpers
parameter COCO_W = 2'b00, COCO_R = 2'b10, SPI_W = 2'b01, SPI_R = 2'b11;

always @(negedge reset_n or posedge clock_50) begin
  if (!reset_n) begin
    spi_state <= SPI_IDLE;
    spi_addr <= 16'hffff;
    spi_tx <= 8'h00;
    spi_tx_flag <= 1'b0;
    mem_delay <= 'b0;
    sram_we_n <= 1'b1;
    cocobuf <= 8'h00;
    srambuf <= 8'h00;
    avr_control <= 1'b1;
    dsk_cmd_intr <= 1'b1;
    dsk_cfg_intr <= 1'b1;
    req <= 3'b000;
    fdcstatus <= 8'b00000100;
    dskreg <= 8'h00;
    nmi <= 1'b0;
  end else begin
    if (spi_rx_flag) begin
      spi_tx_flag <= 1'b0;
      req[2] <= 1'b1;
    end
    if (scs_falling_edge && c_power) 
      req[1] <= 1'b1;
    if (cts_falling_edge)
      req[0] <= 1'b1;
    if (mem_delay) begin // Deal with memory timing and buffering
      mem_delay <= mem_delay - 1'b1; // doesn't apply until next tick!
      if (mem_delay == 3'h1)
        case ({sram_we_n, actor})
          COCO_R:
            cocobuf <= sram_databus[7:0];
          SPI_R: begin
            spi_addr <= spi_addr + 1'b1;
            spi_tx_flag <= 1'b1;
            spi_tx <= sram_databus[7:0];
          end
          COCO_W:
            sram_we_n <= 1'b1;
          SPI_W: begin
            spi_addr <= spi_addr + 1'b1;
            sram_we_n <= 1'b1;
          end
        endcase
    end else
      // All of these happen on the next clock tick!
      // This functions as a very simple arbiter - SPI first because it has tighter timing, then
      // Coco.
      casex (req)
        3'b1??: begin // SPI request pending	 
          spi_command();
          req[2] <= 1'b0;
        end
        3'b01?: begin // SCS request pending
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

task cts_handler;
begin
  actor <= 1'b0;
  mem_delay <= 3'h6;
  sram_we_n <= 1'b1;
end
endtask

task spi_command;
begin
  case (spi_state)
    SPI_IDLE: // Waiting for command byte
      case (spi_rx)
        SPI_CMD_ADDR:  spi_state <= SPI_ADDR1;
        SPI_CMD_WRITE: spi_state <= SPI_WRITE;
        SPI_CMD_READ: begin
          spi_state <= SPI_READ;
          case (spi_addr)
            16'hff40: begin
              spi_tx <= dskreg;
              spi_tx_flag <= 1'b1;
              dsk_cfg_intr <= 1'b1;
            end
            16'hff48: begin
              spi_tx <= fdccmd;
              spi_tx_flag <= 1'b1;
              dsk_cmd_intr <= 1'b1;
            end
            default: begin
              mem_delay <= 3'h6;
              actor <= 1'b1;
            end
          endcase
        end
        SPI_CMD_READ_STATUS: begin
          spi_tx <= fdcstatus;
          spi_tx_flag <= 1'b1;
          spi_state <= SPI_READ;
        end
        SPI_CMD_DEVCON: spi_state <= SPI_DEVCON;
        default: spi_state <= SPI_IDLE;
		endcase
    SPI_ADDR1: begin
      spi_addr <= (spi_rx << 8);
      spi_state <= SPI_ADDR2;
    end
    SPI_ADDR2: begin
      spi_addr <= spi_addr + spi_rx;
      spi_state <= SPI_IDLE;
    end
    SPI_READ: // clocking out result byte
      spi_state <= SPI_IDLE;
    SPI_WRITE: begin
      spi_state <= SPI_IDLE;
      case (spi_addr)
        16'hff40:
          dskreg <= spi_rx;
        16'hff48:
          fdcstatus <= spi_rx;
        default: begin
          mem_delay <= 3'h6;
          srambuf <= spi_rx;
          sram_we_n <= 1'b0;
          actor <= 1'b1;
        end
      endcase
    end
    SPI_DEVCON: begin
      avr_control <= spi_rx[0];
      if (spi_rx[1])
        fdcstatus[1] <= 1'b1;
      if (spi_rx[2])
        nmi <= 1'b1;
      if (spi_rx[3])
        dskreg[7] <= 1'b0; // halt enable is cleared at the end of each command
      spi_state <= SPI_IDLE;
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
      16'hff4b: begin
        fdcstatus[1] <= 1'b0;
        actor <= 1'b0;
        mem_delay <= 3'h6;
      end
      default: begin
        actor <= 1'b0;
        mem_delay <= 3'h6;
      end
    endcase else
    case (c_addrbus)
      16'hff40: begin // $ff40 (dskreg)
        dsk_cfg_intr <= 1'b0;
        dskreg <= c_databus;
        fdcstatus[0] <= 1'b0;
      end
      16'hff48: begin // $ff48 (fdccmd)
        fdccmd <= c_databus; 
        if (c_databus[7:6] == 2'b10) // Type II operations set halt
          fdcstatus[1] <= 1'b0;
        dsk_cmd_intr <= 1'b0;
      end
      16'hff4b: begin // $ ff4b (datareg)
        fdcstatus[1] <= 1'b0;
        actor <= 1'b0;
        mem_delay <= 3'h6;
      end
      default: begin
        actor <= 1'b0;
        mem_delay <= 3'h6;
      end
    endcase
end
endtask

SPI_slave spi0(.clk(clock_50), .SCK(avr_sclk), .MISO(miso), .MOSI(avr_mosi), .SSEL(avr_mem_ss), .byte_received(spi_rx_flag), .byte_received_data(spi_rx),
	.byte_send_data(spi_tx), .byte_send(spi_tx_flag));

endmodule
