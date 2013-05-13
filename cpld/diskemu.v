module diskemu (c_power, a_power, led_rw, led_cbus, led_cts, led_scs, led_s, banksw, busreq, a_busen, c_dataen, c_busen, ard_rw, ard_sel, ard_busmaster, 
                wee, een, eclk, cts, scs, coco_rw, coco_addr, bank, ard_een, slenb, special);

input c_power;
input a_power;
input scs;
input cts;
input eclk;
inout [1:0] banksw;
input busreq;
input coco_rw;
input [14:13] coco_addr;
output ard_busmaster;
output a_busen;
output c_busen;
output c_dataen;
output led_rw, led_cbus, led_cts, led_scs, led_s;
output een;
output wee;
output slenb;
output [1:0] bank;
input special;
input ard_rw;
input ard_een;
output ard_sel;

// Bus flow controls
assign c_busen = (c_power ? a_power & busreq : 1'b1); // If coco is on, let it control the address bus (neg)
assign a_busen = ~a_power; // always enabled when arduino is connected (neg)
assign c_dataen = (cts & scs) | c_busen;
assign ard_busmaster = ~c_busen; // Arduino controls address lines on bus if it asks (neg)
assign ard_sel = (a_power & c_power & ~scs & eclk);

// Bank controls
assign banksw[1:0] = ard_sel ? coco_addr[14:13] : 2'bz;
assign bank[1] = ~c_busen ? coco_addr[14] : banksw[1];
assign bank[0] = ~c_busen ? coco_addr[13] : banksw[0];

// Write controls
assign wee = a_power ? ard_rw : 1'b1;

// EEPROM output enable
assign een = ~c_busen ? cts : ard_een;

// Keep this out of the way for now
assign slenb = special;

// Blinkenlights
assign led_rw = ~wee; 
assign led_cbus = ~c_busen;
assign led_cts = ~cts;
assign led_scs = ~scs;
assign led_s = special;

endmodule
