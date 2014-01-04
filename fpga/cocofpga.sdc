create_clock -name "c_eclk" -period 1117ns [get_ports {c_eclk}]
create_generated_clock -name "c_qclk" -phase -90 -source [get_ports {c_eclk}]
create_clock -name "clock_50" -period 20ns [get_ports {clock_50} ] -waveform {0 10}

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

set_clock_groups -asynchronous -group { c_eclk c_qclk } -group { clock_50 }

set_false_path -from [get_clocks c_eclk] -to [get_clocks {clock_50}]
set_false_path -from [get_clocks clock_50] -to [get_clocks {c_eclk}]

# tsu/th constraints

set_input_delay -clock "c_eclk" -min 110ns [get_ports {c_addrbus[*]}] -clock_fall
set_input_delay -clock "c_eclk" -max 20ns [get_ports {c_addrbus[*]}] -clock_fall
set_input_delay -clock "c_qclk" -min 0ns [get_ports {c_databus[*]}]
set_input_delay -clock "c_qclk" -max 20ns [get_ports {c_databus[*]}]
set_input_delay -clock "c_eclk" -min 0ns [get_ports {c_rw}] -clock_fall
set_input_delay -clock "c_eclk" -max 110ns [get_ports {c_rw}] -clock_fall
set_input_delay -clock "c_eclk" 5ns [get_ports {c_scs_n c_cts_n}] -clock_fall

# tco constraints

set_output_delay -clock "c_qclk" -min 0ns [get_ports {c_databus[*]}] 
set_output_delay -clock "c_qclk" -max 70ns [get_ports {c_databus[*]}]
set_output_delay -clock "c_eclk" 50ns [get_ports {c_nmi_n, c_halt_n}]
