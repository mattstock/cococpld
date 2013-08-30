create_clock -name "c_eclk" -period 1117ns [get_ports {c_eclk}]
create_generated_clock -name "c_qclk" -phase -90 -source [get_ports {c_eclk}]
create_clock -name "clock_50" -period 20ns [get_ports {clock_50} ] -waveform {0 10}
create_clock -name "avr_16" -period 62.5ns

# Automatically constrain PLL and other generated clocks
derive_pll_clocks -create_base_clocks

set_clock_groups -asynchronous -group { c_eclk c_qclk } -group { clock_50 } -group {avr_16}

set_false_path -from [get_clocks c_eclk] -to [get_clocks {clock_50 avr_16}]
set_false_path -from [get_clocks clock_50] -to [get_clocks {c_eclk avr_16}]
set_false_path -from [get_clocks avr_16] -to [get_clocks {c_eclk clock_50}]

# tsu/th constraints

set_input_delay -clock "c_eclk" -min 110ns [get_ports {c_addrbus[*]}] -clock_fall
set_input_delay -clock "c_eclk" -max 20ns [get_ports {c_addrbus[*]}] -clock_fall
set_input_delay -clock "c_qclk" -min 0ns [get_ports {c_databus[*]}]
set_input_delay -clock "c_qclk" -max 20ns [get_ports {c_databus[*]}]
set_input_delay -clock "avr_16" 20ns [get_ports {a_addrbus[*] a_databus[*] a_rw a_sel}]
set_input_delay -clock "c_eclk" -min 0ns [get_ports {c_rw}] -clock_fall
set_input_delay -clock "c_eclk" -max 110ns [get_ports {c_rw}] -clock_fall
set_input_delay -clock "c_eclk" 5ns [get_ports {c_scs_n c_cts_n}] -clock_fall

# tco constraints

set_output_delay -clock "c_qclk" -min 0ns [get_ports {c_databus[*]}] 
set_output_delay -clock "c_qclk" -max 70ns [get_ports {c_databus[*]}]
set_output_delay -clock "avr_16" 20ns [get_ports {a_databus[*] intr[*]}]
set_output_delay -clock "c_eclk" 50ns [get_ports {c_nmi_n, c_halt_n}]