create_clock -name "c_eclk" -period 1117ns [get_ports {c_eclk}] -waveform { 629 1117}
create_clock -name "clock_50" -period 20ns [get_ports {clock_50} ] -waveform {0 10}
create_clock -name "sclk" -period 250ns [get_ports {sclk} ]

derive_pll_clocks
derive_clock_uncertainty

set_clock_groups -asynchronous -group { c_eclk } -group { clock_50 } -group { sclk }

set_false_path -from [get_ports reset] -to *
set_false_path -from * -to [get_ports {led[*]}]
set_false_path -from [get_ports c_reset_n] -to *

#set_input_delay -clock "c_eclk" -min 110ns [get_ports {c_addrbus[*]}] -clock_fall
#set_input_delay -clock "c_eclk" -max 20ns [get_ports {c_addrbus[*]}] -clock_fall
#set_input_delay -clock "c_eclk" -min 389ns [get_ports {c_databus[*]}] -clock_fall
#set_input_delay -clock "c_eclk" -max 30ns [get_ports {c_databus[*]}] -clock_fall

set_input_delay -clock c_eclk -min 0ns [get_ports {c_addrbus[*]}]
set_input_delay -clock c_eclk -max 0ns [get_ports {c_addrbus[*]}]
set_input_delay -clock c_eclk -min 0ns [get_ports {c_databus[*]}]
set_input_delay -clock c_eclk -max 0ns [get_ports {c_databus[*]}]
set_input_delay -clock c_eclk -min 0ns [get_ports { c_scs_n c_cts_n }]
set_input_delay -clock c_eclk -max 0ns [get_ports { c_scs_n c_cts_n }]
set_input_delay -clock c_eclk -min 0ns [get_ports c_rw]
set_input_delay -clock c_eclk -max 0ns [get_ports c_rw]

set_input_delay -clock clock_50 -min 0ns [get_ports {sram_databus[*]}]
set_input_delay -clock clock_50 -max 0ns [get_ports {sram_databus[*]}]

set_input_delay -clock sclk -min 0ns [get_ports mosi]
set_input_delay -clock sclk -max 0ns [get_ports mosi]
set_input_delay -clock sclk -min 0ns [get_ports ss]
set_input_delay -clock sclk -max 0ns [get_ports ss]
set_input_delay -clock sclk -min 0ns [get_ports sclk]
set_input_delay -clock sclk -max 0ns [get_ports sclk]

set_output_delay -clock c_eclk -min 0ns [get_ports {c_databus[*]}]
set_output_delay -clock c_eclk -max 0ns [get_ports {c_databus[*]}]
set_output_delay -clock clock_50 -min 0ns [get_ports {c_reset_n c_slenb_n c_nmi_n c_halt_n}]
set_output_delay -clock clock_50 -max 0ns [get_ports {c_reset_n c_slenb_n c_nmi_n c_halt_n}]

set_output_delay -clock clock_50 -min 0ns [get_ports {sram_databus[*]}]
set_output_delay -clock clock_50 -max 0ns [get_ports {sram_databus[*]}]
set_output_delay -clock clock_50 -min 0ns [get_ports {sram_addrbus[*]}]
set_output_delay -clock clock_50 -max 0ns [get_ports {sram_addrbus[*]}]
set_output_delay -clock clock_50 -min 0ns [get_ports {sram_oe_n sram_we_n}]
set_output_delay -clock clock_50 -max 0ns [get_ports {sram_oe_n sram_we_n}]

set_output_delay -clock sclk -min 0ns [get_ports miso]
set_output_delay -clock sclk -max 0ns [get_ports miso]

set_output_delay -clock clock_50 -min 0ns [get_ports {dirty}]
set_output_delay -clock clock_50 -max 0ns [get_ports {dirty}]

#set_output_delay -clock "c_eclk" -min -40ns [get_ports {c_databus[*]}] -clock_fall
#set_output_delay -clock "c_eclk" -max 20ns [get_ports {c_databus[*]}] -clock_fall
