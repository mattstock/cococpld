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
assign m_cs2_n = 1'b1;
assign m_oe_n = (spi_control ? ~spi_rw : ~(c_select & c_rw));
assign m_we_n = (spi_control ? spi_rw : c_rw);

// Safe defaults
assign c_slenb_n = 1'bz;
assign c_nmi_n = 1'bz;
assign c_halt_n = 1'bz;

assign led = { spi_control, state};

task statelogic;
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

endmodule
