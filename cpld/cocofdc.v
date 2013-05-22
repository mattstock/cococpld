`timescale 1ns/1ns

module cocofdc (c_eclk, c_cts_n, c_scs_n, c_databus, c_nmi_n, c_halt_n, c_reset_n, c_addrbus, c_rw, miso, mosi, sclk, ss,
					m_cs1_n, m_cs2_n, m_we_n, m_oe_n, m_addrbus, m_databus, c_slenb_n, c_dataen_n, clock_50, reset, c_cart_n);

input [14:0] c_addrbus; // Coco address bus
inout [7:0] c_databus; // Coco data bus
input c_scs_n; // 0 = Coco register read/write 
input c_cts_n; // 0 = Coco ROM read
input c_eclk; // 1 = memory half of Coco bus cycle
output c_slenb_n;
output c_nmi_n;
output c_cart_n;
input c_rw; // Coco read/write
input c_reset_n; // 0 = Coco reset
output[14:0] m_addrbus;
inout [7:0] m_databus;
output m_we_n;
output m_oe_n;
output m_cs1_n; // SRAM 0x0000-0x7fff chip select
output m_cs2_n; // SRAM 0x8000-0xffff chip select
output c_halt_n;
output c_dataen_n;
input sclk;
input clock_50;
input mosi;
input ss;
output miso;
input reset;

SPI_slave u0(.clk(clock_50), .SCK(sclk), .MISO(miso), .MOSI(mosi), .SSEL(ss), .byte_received(spi_input_flag), .byte_data_received(spi_rec), 
	.byte_send_ready(spi_output_flag), .byte_send(spi_databyte));

// State of the state machine
reg [2:0] state;
wire c_select;

// Data from the SPI bus
wire spi_input_flag;
reg spi_output_flag;
wire [7:0] spi_rec;
reg [7:0] spi_databyte;
reg [15:0] spi_address;

// Does the SPI bus have control?
reg spi_control;
reg spi_haltreq;
reg spi_rw;
reg [2:0] sram_write_cnt;

assign m_addrbus = (spi_control ? spi_address[14:0] : (c_reset_n ? c_addrbus : 15'b0));

assign c_select = ((~c_scs_n & c_eclk) | ~c_cts_n) & c_reset_n;
assign m_cs1_n = ~((spi_control & spi_address[15]) | (c_select & ~c_scs_n));
assign m_cs2_n = ~m_cs1_n;
assign m_oe_n = (spi_control ? ~spi_rw : ~(c_select & c_rw));
assign m_we_n = (spi_control ? spi_rw : 1'b1);

assign c_slenb_n = 1'bz;
assign c_cart_n = 1'bz;
assign c_nmi_n = 1'bz;
assign c_halt_n = 1'bz;


assign c_dataen_n =  ~c_select | spi_control;
assign c_databus = (c_rw ? m_databus[7:0] : 8'bz);
assign m_databus[7:0] = (m_we_n ? 8'bz : (spi_control ? spi_databyte : c_databus));
/*
assign c_databus = (c_select & ~spi_control & c_rw ? m_databus[7:0] : 8'bz);
assign m_databus = (m_we_n ? 8'bz : (spi_control ? spi_databyte : c_databus));
*/

task statelogic;
input [7:0] b;
begin
  case (state)
	 3'h0: // Waiting for command byte
		case (b)
		  8'h01: state <= 3'h1; // set addr
		  8'h02: state <= 3'h3; // write byte
		  8'h03: begin
		    spi_databyte <= m_databus;
		    spi_output_flag <= 1'b1;
          state <= 3'h4;
		  end
		  8'h04: begin
		    spi_control <= 1'b1; // assert bus control
			 state <= 3'h0;
		  end
		  8'h05: begin
		    spi_control <= 1'b0; // release bus control
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
		state <= 4'h0;
    end
	 3'h3: begin     // write byte xx
	   spi_databyte <= b;
		sram_write_cnt <= 3'h6;
		state <= 3'h0;
	 end
	 3'h4: begin // clock out read byte
	   spi_address <= spi_address + 1'b1;
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
	 sram_write_cnt <= 3'b0;
  end else begin
    if (sram_write_cnt == 0)
	   spi_rw <= 1'b1;
	 else if (sram_write_cnt == 1) begin
	   spi_rw <= 1'b0;
      spi_address <= spi_address + 1'b1;
		sram_write_cnt <= sram_write_cnt - 1'b1;
	 end else begin
	   spi_rw <= 1'b0;
		sram_write_cnt <= sram_write_cnt - 1'b1;
	 end
    if (spi_input_flag)
      statelogic(spi_rec);
  end
end

endmodule
