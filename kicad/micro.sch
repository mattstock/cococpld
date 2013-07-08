EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:colorcomputer
LIBS:cococpld-cache
EELAYER 27 0
EELAYER END
$Descr USLegal 14000 8500
encoding utf-8
Sheet 3 4
Title "Color Computer FDC Ethernet Controller"
Date "4 jul 2013"
Rev "2.0"
Comp "Bexkat Systems LLC 2013"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ATMEGA2560-A IC?
U 1 1 51D5E753
P 6550 4200
F 0 "IC?" H 5400 7000 40  0000 L BNN
F 1 "ATMEGA2560-A" H 7250 1350 40  0000 L BNN
F 2 "TQFP100" H 6550 4200 30  0000 C CIN
F 3 "" H 6550 4200 60  0000 C CNN
	1    6550 4200
	1    0    0    -1  
$EndComp
Text HLabel 8050 1600 2    60   Output ~ 0
A_A0
Text HLabel 8050 1700 2    60   Output ~ 0
A_A1
Text HLabel 8050 1800 2    60   Output ~ 0
A_A2
Text HLabel 8050 1900 2    60   Output ~ 0
A_A3
Text HLabel 8050 2000 2    60   Output ~ 0
A_A4
Text HLabel 8050 2100 2    60   Output ~ 0
A_A5
Text HLabel 8050 2200 2    60   Output ~ 0
A_A6
Text HLabel 8050 2300 2    60   Output ~ 0
A_A7
Text HLabel 8050 3400 2    60   Output ~ 0
A_A8
Text HLabel 8050 3500 2    60   Output ~ 0
A_A9
Text HLabel 8050 3600 2    60   Output ~ 0
A_A10
Text HLabel 8050 3700 2    60   Output ~ 0
A_A11
Text HLabel 8050 3800 2    60   Output ~ 0
A_A12
Text HLabel 8050 3900 2    60   Output ~ 0
A_A13
Text HLabel 8050 4000 2    60   Output ~ 0
A_A14
Text HLabel 8050 4100 2    60   Output ~ 0
A_A15
Text HLabel 5000 2500 0    60   BiDi ~ 0
A_D0
Text HLabel 5000 2600 0    60   BiDi ~ 0
A_D1
Text HLabel 5000 2700 0    60   BiDi ~ 0
A_D2
Text HLabel 5000 2800 0    60   BiDi ~ 0
A_D3
Text HLabel 5000 2900 0    60   BiDi ~ 0
A_D4
Text HLabel 5000 3000 0    60   BiDi ~ 0
A_D5
Text HLabel 5000 3100 0    60   BiDi ~ 0
A_D6
Text HLabel 5000 3200 0    60   BiDi ~ 0
A_D7
Text HLabel 5050 6100 0    60   Output ~ 0
A_R/~W
Text HLabel 5050 6300 0    60   Output ~ 0
A_~SELECT
Text HLabel 5000 1600 0    60   Input ~ 0
C_~RESET
Text HLabel 8100 5500 2    60   Input ~ 0
A_ETHINT
Text HLabel 8100 5600 2    60   Input ~ 0
A_FDCINT
$Comp
L +5V #PWR?
U 1 1 51D60C51
P 6500 1200
F 0 "#PWR?" H 6500 1290 20  0001 C CNN
F 1 "+5V" H 6500 1290 30  0000 C CNN
F 2 "" H 6500 1200 60  0000 C CNN
F 3 "" H 6500 1200 60  0000 C CNN
	1    6500 1200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6200 1300 6700 1300
Connection ~ 6300 1300
Connection ~ 6400 1300
Wire Wire Line
	6500 1200 6500 1300
Connection ~ 6500 1300
$Comp
L GND #PWR?
U 1 1 51D60C7D
P 6550 7200
F 0 "#PWR?" H 6550 7200 30  0001 C CNN
F 1 "GND" H 6550 7130 30  0001 C CNN
F 2 "" H 6550 7200 60  0000 C CNN
F 3 "" H 6550 7200 60  0000 C CNN
	1    6550 7200
	1    0    0    -1  
$EndComp
Wire Wire Line
	6400 7100 6700 7100
Connection ~ 6500 7100
Connection ~ 6600 7100
Wire Wire Line
	6550 7100 6550 7200
Connection ~ 6550 7100
$Comp
L CRYSTAL X?
U 1 1 51D60CD1
P 3550 2000
F 0 "X?" H 3550 2150 60  0000 C CNN
F 1 "16MHz" H 3550 1850 60  0000 C CNN
F 2 "~" H 3550 2000 60  0000 C CNN
F 3 "~" H 3550 2000 60  0000 C CNN
	1    3550 2000
	1    0    0    -1  
$EndComp
$Comp
L R R?
U 1 1 51D60CE0
P 3550 1700
F 0 "R?" V 3630 1700 40  0000 C CNN
F 1 "1M" V 3557 1701 40  0000 C CNN
F 2 "~" V 3480 1700 30  0000 C CNN
F 3 "~" H 3550 1700 30  0000 C CNN
	1    3550 1700
	0    -1   -1   0   
$EndComp
$Comp
L C C?
U 1 1 51D60D15
P 3250 2300
F 0 "C?" H 3250 2400 40  0000 L CNN
F 1 "22pF" H 3256 2215 40  0000 L CNN
F 2 "~" H 3288 2150 30  0000 C CNN
F 3 "~" H 3250 2300 60  0000 C CNN
	1    3250 2300
	1    0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 51D60D24
P 3850 2300
F 0 "C?" H 3850 2400 40  0000 L CNN
F 1 "22pF" H 3856 2215 40  0000 L CNN
F 2 "~" H 3888 2150 30  0000 C CNN
F 3 "~" H 3850 2300 60  0000 C CNN
	1    3850 2300
	1    0    0    -1  
$EndComp
Connection ~ 3850 2000
Connection ~ 3250 2000
Wire Wire Line
	3250 2500 3850 2500
$Comp
L GND #PWR?
U 1 1 51D60D76
P 3550 2550
F 0 "#PWR?" H 3550 2550 30  0001 C CNN
F 1 "GND" H 3550 2480 30  0001 C CNN
F 2 "" H 3550 2550 60  0000 C CNN
F 3 "" H 3550 2550 60  0000 C CNN
	1    3550 2550
	1    0    0    -1  
$EndComp
Wire Wire Line
	3550 2500 3550 2550
Connection ~ 3550 2500
Wire Wire Line
	3800 1700 3850 1700
Wire Wire Line
	3850 1700 3850 2100
Wire Wire Line
	3250 2100 3250 1700
Wire Wire Line
	3250 1700 3300 1700
Text Label 3850 2000 0    60   ~ 0
XTAL2
Text Label 3250 2000 2    60   ~ 0
XTAL1
Text Label 5250 2200 2    60   ~ 0
XTAL1
Text Label 5250 1900 2    60   ~ 0
XTAL2
Text HLabel 8050 6500 2    60   Input ~ 0
TCK
Text HLabel 8050 6800 2    60   Input ~ 0
TDI
Text HLabel 8050 6700 2    60   Output ~ 0
TDO
Text HLabel 8050 6600 2    60   Input ~ 0
TMS
Text HLabel 8050 2900 2    60   Output ~ 0
ETH_SS
Text HLabel 5050 6600 0    60   Output ~ 0
SD_SS
Text HLabel 8050 2600 2    60   Output ~ 0
SCK
Text HLabel 8050 2800 2    60   Input ~ 0
MISO
Text HLabel 8050 2700 2    60   Output ~ 0
MOSI
Wire Wire Line
	7850 6500 8050 6500
Wire Wire Line
	7850 6600 8050 6600
Wire Wire Line
	7850 6700 8050 6700
Wire Wire Line
	7850 6800 8050 6800
Wire Wire Line
	7850 2600 8050 2600
Wire Wire Line
	7850 2700 8050 2700
Wire Wire Line
	7850 2800 8050 2800
Wire Wire Line
	5050 6600 5250 6600
Wire Wire Line
	7850 2900 8050 2900
Wire Wire Line
	5050 6300 5250 6300
Wire Wire Line
	5250 6100 5050 6100
Wire Wire Line
	7850 3400 8050 3400
Wire Wire Line
	7850 3500 8050 3500
Wire Wire Line
	7850 3600 8050 3600
Wire Wire Line
	7850 3700 8050 3700
Wire Wire Line
	7850 3800 8050 3800
Wire Wire Line
	7850 3900 8050 3900
Wire Wire Line
	7850 4000 8050 4000
Wire Wire Line
	7850 4100 8050 4100
Wire Wire Line
	7850 1600 8050 1600
Wire Wire Line
	7850 1700 8050 1700
Wire Wire Line
	7850 1800 8050 1800
Wire Wire Line
	7850 1900 8050 1900
Wire Wire Line
	7850 2000 8050 2000
Wire Wire Line
	7850 2100 8050 2100
Wire Wire Line
	7850 2200 8050 2200
Wire Wire Line
	7850 2300 8050 2300
Wire Wire Line
	7850 5500 8100 5500
Wire Wire Line
	7850 5600 8100 5600
Wire Wire Line
	5000 2500 5250 2500
Wire Wire Line
	5000 2600 5250 2600
Wire Wire Line
	5000 2700 5250 2700
Wire Wire Line
	5000 2800 5250 2800
Wire Wire Line
	5000 2900 5250 2900
Wire Wire Line
	5000 3000 5250 3000
Wire Wire Line
	5000 3100 5250 3100
Wire Wire Line
	5000 3200 5250 3200
Wire Wire Line
	5000 1600 5250 1600
$EndSCHEMATC
