onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cocofdc/sram_databus
add wave -noupdate /cocofdc/c_databus
add wave -noupdate /cocofdc/a_databus
add wave -noupdate /cocofdc/sram_ce_n
add wave -noupdate /cocofdc/sram_we_n
add wave -noupdate /cocofdc/sram_oe_n
add wave -noupdate /cocofdc/sram_addrbus
add wave -noupdate /cocofdc/intr
add wave -noupdate /cocofdc/led
add wave -noupdate /cocofdc/counter_50
add wave -noupdate /cocofdc/eclk_edge
add wave -noupdate /cocofdc/cts_edge
add wave -noupdate /cocofdc/scs_edge
add wave -noupdate /cocofdc/avr_edge
add wave -noupdate /cocofdc/c_readbuf
add wave -noupdate /cocofdc/writebuf
add wave -noupdate /cocofdc/actor
add wave -noupdate /cocofdc/c_regselect
add wave -noupdate /cocofdc/c_select

TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {464 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 206
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {342 ns} {1270 ns}
view wave 
wave clipboard store
radix hex

wave create -pattern none -portmode input -language vlog /cocofdc/c_eclk 
wave modify -driver freeze -pattern clock -initialvalue St0 -period 1117ns -dutycycle 50 -starttime 0ns -endtime 5000ns Edit:/cocofdc/c_eclk 

wave create -pattern none -portmode input -language vlog /cocofdc/c_cts_n 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 5000ns Edit:/cocofdc/c_cts_n 

wave create -pattern none -portmode input -language vlog /cocofdc/c_scs_n 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 5000ns Edit:/cocofdc/c_scs_n 
wave edit change_value -start 500ns -end 1100ns -value 0 Edit:/cocofdc/c_scs_n
wave edit change_value -start 1600ns -end 2200ns -value 0 Edit:/cocofdc/c_scs_n

wave create -pattern none -portmode input -language vlog /cocofdc/clock_50 
wave modify -driver freeze -pattern clock -initialvalue 0 -period 20ns -dutycycle 50 -starttime 0ns -endtime 5000ns Edit:/cocofdc/clock_50 

wave create -pattern none -portmode input -language vlog /cocofdc/c_power 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 5000ns Edit:/cocofdc/c_power 

wave create -pattern none -portmode input -language vlog /cocofdc/reset_n 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 5000ns Edit:/cocofdc/reset_n 
wave edit change_value -start 0ns -end 100ns -value 0 Edit:/cocofdc/reset_n 

wave create -pattern none -portmode inout -language vlog -range 7 0 /cocofdc/sram_databus 
wave modify -driver freeze -pattern constant -value 16#50 -range 7 0 -starttime 0ns -endtime 5000ns Edit:/cocofdc/sram_databus
wave edit change_value -start 670ns -end 5000ns -value 16#ae Edit:/cocofdc/sram_databus

wave create -pattern none -portmode inout -language vlog -range 7 0 /cocofdc/c_databus 
wave modify -driver freeze -pattern constant -value 16#zz -range 7 0 -starttime 0ns -endtime 5000ns Edit:/cocofdc/c_databus
wave edit change_value -start 1300ns -end 2200ns -value 16#60 Edit:/cocofdc/c_databus

wave create -pattern none -portmode input -language vlog -range 14 0 /cocofdc/c_addrbus 
wave modify -driver freeze -pattern constant -value 0 -range 14 0 -starttime 0ns -endtime 5000ns Edit:/cocofdc/c_addrbus 
wave edit change_value -start 350ns -end 1000ns -value 16#ff51 Edit:/cocofdc/c_addrbus 
wave edit change_value -start 1300ns -end 2200ns -value 16#ff52 Edit:/cocofdc/c_addrbus 

wave create -pattern none -portmode input -language vlog /cocofdc/c_rw 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 5000ns Edit:/cocofdc/c_rw
wave edit change_value -start 1300ns -end 2200ns -value 0 Edit:/cocofdc/c_rw

wave create -pattern none -portmode input -language vlog /cocofdc/a_rw 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 5000ns Edit:/cocofdc/a_rw 

wave create -pattern none -portmode input -language vlog /cocofdc/a_sel 
wave modify -driver freeze -pattern constant -value 1 -starttime 0ns -endtime 5000ns Edit:/cocofdc/a_sel

wave create -pattern none -portmode inout -language vlog -range 7 0 /cocofdc/a_databus 
wave modify -driver freeze -pattern constant -value 16#xx -range 7 0 -starttime 0ns -endtime 5000ns Edit:/cocofdc/a_databus

wave create -pattern none -portmode input -language vlog -range 15 0 /cocofdc/a_addrbus 
wave modify -driver freeze -pattern constant -value x -range 15 0 -starttime 0ns -endtime 5000ns Edit:/cocofdc/a_addrbus 
