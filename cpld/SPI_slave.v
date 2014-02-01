module SPI_slave(clk, SCK, MOSI, MISO, SSEL, byte_received, byte_received_data, byte_send, byte_send_data);

input clk;
input SCK;
input SSEL;
input MOSI;
input byte_send;
input [7:0] byte_send_data;
output byte_received;
output [7:0] byte_received_data;
output tri MISO;

// sync SCK to the FPGA clock using a 3-bits shift register
reg [2:0] SCKr;
always @(posedge clk) SCKr <= {SCKr[1:0], SCK};
wire SCK_risingedge = (SCKr[2:1]==2'b01);  // now we can detect SCK rising edges
wire SCK_fallingedge = (SCKr[2:1]==2'b10);  // and falling edges

// same thing for SSEL
reg [2:0] SSELr;
always @(posedge clk) SSELr <= {SSELr[1:0], SSEL};
wire SSEL_active = ~SSELr[1];  // SSEL is active low
wire SSEL_startmessage = (SSELr[2:1]==2'b10);  // message starts at falling edge
wire SSEL_endmessage = (SSELr[2:1]==2'b01);  // message stops at rising edge

// and for MOSI
reg [1:0] MOSIr;
always @(posedge clk) MOSIr <= {MOSIr[0], MOSI};
wire MOSI_data = MOSIr[1];

// we handle SPI in 8-bits format, so we need a 3 bits counter to count the bits as they come in
reg [2:0] bitcnt;

reg byte_received;  // high when a byte has been received
reg [7:0] byte_received_data;

always @(posedge clk)
begin
  if(~SSEL_active)
    bitcnt <= 3'b000;
  else
  if(SCK_risingedge)
  begin
    bitcnt <= bitcnt + 3'b001;

    // implement a shift-left register (since we receive the data MSB first)
    byte_received_data <= {byte_received_data[6:0], MOSI_data};
  end
end

always @(posedge clk) byte_received <= SSEL_active && SCK_risingedge && (bitcnt==3'b111);

reg [7:0] send_buffer;

always @(posedge clk)
if(SSEL_active)
begin
  if(SSEL_startmessage)
    send_buffer <= 8'h00; // During the first byte read, send what?
  else
  if (bitcnt == 3'b0) begin
    if (byte_send)
      send_buffer <= byte_send_data;  // latch this when ready
  end else begin
	 if (SCK_fallingedge)
      send_buffer <= {send_buffer[6:0], 1'b0}; 
  end
end

assign MISO = (SSEL_active ? send_buffer[7] : 1'bz);  // send MSB first
// we assume that there is only one slave on the SPI bus
// so we don't bother with a tri-state buffer for MISO
// otherwise we would need to tri-state MISO when SSEL is inactive

endmodule
