create_clock -name "eclk" -period 1117.000ns [get_ports {eclk}] -waveform {279.000 767.000}

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

# tsu/th constraints

set_input_delay -clock "eclk" -max 802ns [get_ports {c_addrbus[*]}] -clock_fall
set_input_delay -clock "eclk" -min 110.000ns [get_ports {c_addrbus[*]}] -clock_fall


# tco constraints

set_output_delay -clock "eclk" -max 802ns [get_ports {c_addrbus[*]}] -clock_fall
set_output_delay -clock "eclk" -min -295.000ns [get_ports {c_addrbus[*]}] -clock_fall


# tpd constraints

