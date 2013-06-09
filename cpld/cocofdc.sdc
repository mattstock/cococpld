create_clock -name "c_eclk" -period 1117ns [get_ports {c_eclk}] -waveform { 629 1117}
create_clock -name "clock_50" -period 20ns [get_ports {clock_50} ] -waveform {0 10}

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

set_clock_groups -asynchronous -group { c_eclk } -group { clock_50 }

# tsu/th constraints

set_input_delay -clock "c_eclk" -min 110ns [get_ports {c_addrbus[*]}] -clock_fall
set_input_delay -clock "c_eclk" -max 20ns [get_ports {c_addrbus[*]}] -clock_fall
set_input_delay -clock "c_eclk" -min 389ns [get_ports {c_databus[*]}] -clock_fall
set_input_delay -clock "c_eclk" -max 30ns [get_ports {c_databus[*]}] -clock_fall

# tco constraints

set_output_delay -clock "c_eclk" -min -40ns [get_ports {c_databus[*]}] -clock_fall
set_output_delay -clock "c_eclk" -max 20ns [get_ports {c_databus[*]}] -clock_fall
