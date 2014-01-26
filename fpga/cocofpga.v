module cocofpga(SW, KEY, HEX0, HEX1, HEX2, HEX3, LEDR, LEDG, clock_50,
			c_addrbus, c_databus, c_eclk, c_slenb_n, c_rw, c_cts_n, c_qclk, c_cart_n,
			c_scs_n, c_dataen_n, c_reset_n, c_halt_n, c_nmi_n, 
			miso, mosi, ss, sclk, dsk_cfg_intr, dsk_cmd_intr,
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
input mosi;
output miso;
input ss;
input sclk;
output reg dsk_cmd_intr;
output reg dsk_cfg_intr;

// SRAM
assign sram_ce_n = 1'b0;
assign sram_lb_n = 1'b0;
assign sram_oe_n = ~sram_we_n;
assign sram_ub_n = 1'b1;

// FLASH
assign fl_oe_n = 1'b1;
assign fl_ce_n = 1'b1;
assign fl_rst_n = 1'b1;
assign fl_we_n = 1'b1;
assign fl_addrbus = 22'b0;
assign fl_databus = 8'b0;

reg actor;

reg [2:0] counter_50;     // 50MHz counter for SRAM read/write   
reg [2:0] cts_edge;
reg [2:0] scs_edge;

reg [3:0] spi_state;    // State machine for SPI commands
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
// 4MHZ SPI = 250ns
// 0.89MHz/1.78MHz Coco E clock = 1117ns/559ns
// 50MHz CPLD clock = 20ns

// Some debug info
assign LEDR = { 3'b0, c_rw, ~c_dataen_n, spi_rx_flag, spi_tx_flag, nmi, halt, avr_control };
assign LEDG = (KEY[1] ? spi_tx : c_databus);

wire reset_n = KEY[0];
wire c_power = SW[1];

wire spi_rx_flag;
wire [7:0] spi_rx;

assign c_cart_n = (SW[0] ? c_qclk : 1'bz);

assign c_dataen_n = ~((c_regselect | c_memselect) & c_power);

// Coco interrupt logic
wire fdc_halt = dskreg[7] & ~fdcstatus[1]; // high if FDC logic would halt coco
wire halt = fdc_halt | avr_control;
assign c_nmi_n = (nmi ? 1'b0 : 1'bz); // for FDC
assign c_halt_n = (halt ? 1'b0 : 1'bz); // for FDC

assign c_slenb_n = 1'bz;

wire c_memselect = ~c_cts_n;
wire c_regselect = ~c_scs_n & c_eclk;

assign c_databus = (c_rw ? cocobuf : 8'hzz);

assign sram_addrbus = {2'b00, (actor ? spi_addr : c_addrbus)};
assign sram_databus = {8'hzz, (sram_we_n ? 8'hzz : srambuf) }; 

// sync E clock, AVR, CTS, SCS with 50MHz osc
wire cts_falling_edge = (cts_edge[2:1] == 2'b10);
wire scs_falling_edge = (scs_edge[2:1] == 2'b01); // it's flipped because of the eclk timing

// SPI state machine nodes
parameter SPI_IDLE = 4'h0, SPI_ADDR1 = 4'h1, SPI_ADDR2 = 4'h2, SPI_WRITE = 4'h3, SPI_READ = 4'h4, SPI_DEVCON = 4'h5;

// SPI commands
parameter SPI_CMD_ADDR = 8'h1, SPI_CMD_WRITE = 8'h2, SPI_CMD_READ = 8'h3, SPI_CMD_READ_STATUS = 8'h4, SPI_CMD_DEVCON = 8'h5;

// Helpers
parameter COCO_W = 2'b00, COCO_R = 2'b10, SPI_W = 2'b01, SPI_R = 2'b11;

always @(posedge clock_50) begin
  cts_edge <= {cts_edge[1:0], c_cts_n};
  scs_edge <= {scs_edge[1:0], c_regselect};
end

always @(negedge reset_n or posedge clock_50) begin
  if (!reset_n) begin
    spi_state <= SPI_IDLE;
    spi_addr <= 16'hffff;
    spi_tx <= 8'h00;
    spi_tx_flag <= 1'b0;
    sram_we_n <= 1'b1;
    cocobuf <= 8'h00;
    srambuf <= 8'h00;
    avr_control <= 1'b1;
    dsk_cmd_intr <= 1'b1;
    dsk_cfg_intr <= 1'b1;
    req <= 3'b000;
    fdcstatus <= 8'b00000100;
    dskreg <= 8'b0;
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
    if (counter_50) begin // Deal with memory timing and buffering
      counter_50 <= counter_50 - 1'b1; // doesn't apply until next tick!
      if (counter_50 == 3'h1)
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
  counter_50 <= 3'h6;
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
            16'hff49: begin
              spi_tx <= fdcsec;
              spi_tx_flag <= 1'b1;
            end
            16'hff4a: begin
              spi_tx <= fdctrk;
              spi_tx_flag <= 1'b1;
            end
            16'hff4b: begin
              spi_tx <= datareg;
              spi_tx_flag <= 1'b1;
            end
            default: begin
              counter_50 <= 3'h6;
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
        16'hff49:
          fdcsec <= spi_rx;
        16'hff4a:
          fdctrk <= spi_rx;
        16'hff4b:
          datareg <= spi_rx;
        default: begin
          counter_50 <= 3'h6;
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
      16'hff49:
        cocobuf <= fdcsec;
      16'hff4a:
        cocobuf <= fdctrk;
      16'hff4b: begin
        fdcstatus[1] <= 1'b0;
        cocobuf <= datareg;
      end
      default: begin
        actor <= 1'b0;
        counter_50 <= 3'h6;
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
      16'hff49:
        fdcsec <= c_databus;
      16'hff4a:
        fdctrk <= c_databus;
      16'hff4b: begin // $ ff4b (datareg)
        fdcstatus[1] <= 1'b0;
        datareg <= c_databus;
      end
      default: begin
        actor <= 1'b0;
        counter_50 <= 3'h6;
      end
    endcase
end
endtask

SEG7_LUT_4 h0(HEX0, HEX1, HEX2, HEX3, KEY[1] ? spi_addr : c_addrbus );
SPI_slave spi0(.clk(clock_50), .SCK(sclk), .MISO(miso), .MOSI(mosi), .SSEL(ss), .byte_received(spi_rx_flag), .byte_received_data(spi_rx),
	.byte_send_data(spi_tx), .byte_send(spi_tx_flag));
	
endmodule
