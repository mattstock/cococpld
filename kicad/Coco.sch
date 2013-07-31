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
Sheet 2 4
Title "Color Computer FDC Ethernet Controller"
Date "31 jul 2013"
Rev "2.0"
Comp "Bexkat Systems LLC 2013"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Connection ~ 8750 3300
Wire Wire Line
	8750 3250 8750 3550
Wire Wire Line
	2300 3350 2300 3450
Connection ~ 2550 4500
Wire Wire Line
	2550 5200 3050 5200
Connection ~ 2550 3600
Wire Wire Line
	3050 3600 2550 3600
Wire Wire Line
	2550 3850 2300 3850
Wire Wire Line
	3050 2200 2550 2200
Wire Wire Line
	5150 1200 5150 1500
Wire Wire Line
	6650 1200 6650 1500
Connection ~ 5750 850 
Wire Wire Line
	6750 850  6750 1500
Connection ~ 4650 850 
Wire Wire Line
	5250 850  5250 1500
Wire Wire Line
	3750 850  3950 850 
Connection ~ 8350 5500
Wire Wire Line
	7800 5500 8350 5500
Connection ~ 8550 4300
Wire Wire Line
	8550 4300 8550 3400
Wire Wire Line
	8550 3400 7800 3400
Connection ~ 9100 5100
Wire Wire Line
	7800 5100 9100 5100
Wire Wire Line
	8750 3300 7800 3300
Wire Wire Line
	4950 6750 4950 6000
Wire Wire Line
	5750 6750 5750 6000
Connection ~ 6350 6450
Wire Wire Line
	8550 7050 8550 7000
Connection ~ 2250 7250
Wire Wire Line
	2150 7250 2250 7250
Wire Wire Line
	2150 6850 2250 6850
Wire Wire Line
	2250 6850 2250 7300
Wire Wire Line
	2300 6750 2300 6950
Wire Wire Line
	2300 6950 2150 6950
Wire Wire Line
	1800 4650 1800 4500
Wire Wire Line
	1800 4500 1450 4500
Wire Wire Line
	1800 4600 1450 4600
Connection ~ 1800 4600
Wire Wire Line
	7500 7200 7500 7300
Wire Wire Line
	5850 6000 5850 6450
Wire Wire Line
	5850 6450 6350 6450
Wire Wire Line
	6350 7150 6350 6000
Connection ~ 6350 6750
Wire Wire Line
	5050 6750 5050 6000
Connection ~ 5750 6750
Connection ~ 5050 6750
Wire Wire Line
	4850 6700 4850 6750
Wire Wire Line
	4850 6750 5950 6750
Connection ~ 4950 6750
Wire Wire Line
	7800 2300 9100 2300
Wire Wire Line
	9100 2300 9100 5800
Wire Wire Line
	7800 4300 9100 4300
Connection ~ 9100 4300
Wire Wire Line
	8750 3950 9100 3950
Connection ~ 9100 3950
Wire Wire Line
	7800 5200 8350 5200
Wire Wire Line
	8350 5200 8350 5800
Wire Wire Line
	8350 5800 8500 5800
Wire Wire Line
	8500 5800 8500 5700
Wire Wire Line
	4650 850  4650 1500
Wire Wire Line
	5750 850  5750 1500
Connection ~ 5250 850 
Wire Wire Line
	4350 850  6900 850 
Wire Wire Line
	6900 850  6900 950 
Connection ~ 6750 850 
Wire Wire Line
	5850 1200 5850 1500
Wire Wire Line
	3750 800  3750 1500
Connection ~ 3750 850 
Wire Wire Line
	3050 3200 2550 3200
Connection ~ 2550 3200
Wire Wire Line
	2550 4500 3050 4500
Connection ~ 2550 3850
Wire Wire Line
	2550 2200 2550 5300
Connection ~ 2550 5200
Wire Wire Line
	3050 4300 2700 4300
Wire Wire Line
	2700 4300 2700 4200
$Comp
L +3.3V #PWR?
U 1 1 51D5A9F2
P 8750 3250
F 0 "#PWR?" H 8750 3210 30  0001 C CNN
F 1 "+3.3V" H 8750 3360 30  0000 C CNN
F 2 "" H 8750 3250 60  0001 C CNN
F 3 "" H 8750 3250 60  0001 C CNN
	1    8750 3250
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5A9F8
P 2700 4200
F 0 "#PWR?" H 2700 4160 30  0001 C CNN
F 1 "+3.3V" H 2700 4310 30  0000 C CNN
F 2 "" H 2700 4200 60  0001 C CNN
F 3 "" H 2700 4200 60  0001 C CNN
	1    2700 4200
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5A9FE
P 6650 1200
F 0 "#PWR?" H 6650 1160 30  0001 C CNN
F 1 "+3.3V" H 6650 1310 30  0000 C CNN
F 2 "" H 6650 1200 60  0001 C CNN
F 3 "" H 6650 1200 60  0001 C CNN
	1    6650 1200
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AA04
P 5850 1200
F 0 "#PWR?" H 5850 1160 30  0001 C CNN
F 1 "+3.3V" H 5850 1310 30  0000 C CNN
F 2 "" H 5850 1200 60  0001 C CNN
F 3 "" H 5850 1200 60  0001 C CNN
	1    5850 1200
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AA0A
P 5150 1200
F 0 "#PWR?" H 5150 1160 30  0001 C CNN
F 1 "+3.3V" H 5150 1310 30  0000 C CNN
F 2 "" H 5150 1200 60  0001 C CNN
F 3 "" H 5150 1200 60  0001 C CNN
	1    5150 1200
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AA10
P 3750 800
F 0 "#PWR?" H 3750 760 30  0001 C CNN
F 1 "+3.3V" H 3750 910 30  0000 C CNN
F 2 "" H 3750 800 60  0001 C CNN
F 3 "" H 3750 800 60  0001 C CNN
	1    3750 800 
	-1   0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 51D5AA16
P 4150 850
F 0 "C?" H 4200 950 50  0000 L CNN
F 1 "0.1uF" H 4200 750 50  0000 L CNN
F 2 "" H 4150 850 60  0001 C CNN
F 3 "" H 4150 850 60  0001 C CNN
	1    4150 850 
	0    -1   1    0   
$EndComp
$Comp
L GND #PWR?
U 1 1 51D5AA1C
P 9100 5800
F 0 "#PWR?" H 9100 5800 30  0001 C CNN
F 1 "GND" H 9100 5730 30  0001 C CNN
F 2 "" H 9100 5800 60  0001 C CNN
F 3 "" H 9100 5800 60  0001 C CNN
	1    9100 5800
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AA22
P 8500 5700
F 0 "#PWR?" H 8500 5660 30  0001 C CNN
F 1 "+3.3V" H 8500 5810 30  0000 C CNN
F 2 "" H 8500 5700 60  0001 C CNN
F 3 "" H 8500 5700 60  0001 C CNN
	1    8500 5700
	1    0    0    -1  
$EndComp
Text Label 7800 3200 0    60   ~ 0
M_D7
Text Label 7800 3600 0    60   ~ 0
M_D6
Text Label 6550 1500 1    60   ~ 0
M_D5
Text Label 6350 1500 1    60   ~ 0
M_D4
Text Label 6150 1500 1    60   ~ 0
M_D3
Text Label 3050 4600 2    60   ~ 0
M_D2
Text Label 3050 4400 2    60   ~ 0
M_D1
Text Label 4550 6000 3    60   ~ 0
M_D0
Text Label 3050 5400 2    60   ~ 0
M_A15
Text Label 3050 5300 2    60   ~ 0
M_A14
Text Label 4450 1500 1    60   ~ 0
M_A13
Text Label 4350 1500 1    60   ~ 0
M_A12
Text Label 3050 3700 2    60   ~ 0
M_A11
Text Label 3050 3500 2    60   ~ 0
M_A10
Text Label 3050 4700 2    60   ~ 0
M_A9
Text Label 4750 1500 1    60   ~ 0
M_A8
Text Label 6150 6000 3    60   ~ 0
M_A7
Text Label 7800 4100 0    60   ~ 0
M_A6
Text Label 7800 4000 0    60   ~ 0
M_A5
Text Label 6250 6000 3    60   ~ 0
M_A4
Text Label 5550 6000 3    60   ~ 0
M_A3
Text Label 7800 2900 0    60   ~ 0
M_A2
Text Label 4850 6000 3    60   ~ 0
M_A1
Text Label 5250 6000 3    60   ~ 0
M_A0
Text Label 3050 5500 2    60   ~ 0
C_D7
Text Label 3050 5000 2    60   ~ 0
C_D6
Text Label 6450 1500 1    60   ~ 0
C_D5
Text Label 6050 1500 1    60   ~ 0
C_D4
Text Label 5950 1500 1    60   ~ 0
C_D3
Text Label 3050 4000 2    60   ~ 0
C_D2
Text Label 3050 4200 2    60   ~ 0
C_D1
Text Label 3050 4100 2    60   ~ 0
C_D0
Text Label 4750 6000 3    60   ~ 0
M_~OE
Text Label 3650 6000 3    60   ~ 0
C_A14
Text Label 3050 3000 2    60   ~ 0
C_A13
Text Label 7800 4400 0    60   ~ 0
C_A12
Text Label 4950 1500 1    60   ~ 0
C_A11
Text Label 7150 6000 3    60   ~ 0
C_A10
Text Label 7800 3700 0    60   ~ 0
C_A9
Text Label 3050 4800 2    60   ~ 0
C_A8
Text Label 5050 1500 1    60   ~ 0
C_A7
Text Label 6950 1500 1    60   ~ 0
C_A6
Text Label 6850 1500 1    60   ~ 0
C_A5
Text Label 4450 6000 3    60   ~ 0
C_A4
Text Label 3950 6000 3    60   ~ 0
C_A3
Text Label 7800 3100 0    60   ~ 0
C_A2
Text Label 7800 4700 0    60   ~ 0
C_A1
Text Label 6450 6000 3    60   ~ 0
C_A0
Text Label 1450 5000 0    60   ~ 0
C_A14
Text Label 1450 4900 0    60   ~ 0
C_A13
Text Label 1450 4300 0    60   ~ 0
C_A12
Text Label 1450 4200 0    60   ~ 0
C_A11
Text Label 1450 4100 0    60   ~ 0
C_A10
Text Label 1450 4000 0    60   ~ 0
C_A9
Text Label 1450 3900 0    60   ~ 0
C_A8
Text Label 1450 3800 0    60   ~ 0
C_A7
Text Label 1450 3700 0    60   ~ 0
C_A6
Text Label 1450 3600 0    60   ~ 0
C_A5
Text Label 1450 3500 0    60   ~ 0
C_A4
Text Label 1450 3400 0    60   ~ 0
C_A3
Text Label 1450 3300 0    60   ~ 0
C_A2
Text Label 1450 3200 0    60   ~ 0
C_A1
Text Label 1450 3100 0    60   ~ 0
C_A0
NoConn ~ 7500 7050
$Comp
L +3.3V #PWR?
U 1 1 51D5AA68
P 8550 7000
F 0 "#PWR?" H 8550 6960 30  0001 C CNN
F 1 "+3.3V" H 8550 7110 30  0000 C CNN
F 2 "" H 8550 7000 60  0001 C CNN
F 3 "" H 8550 7000 60  0001 C CNN
	1    8550 7000
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 51D5AA6E
P 7500 7300
F 0 "#PWR?" H 7500 7300 30  0001 C CNN
F 1 "GND" H 7500 7230 30  0001 C CNN
F 2 "" H 7500 7300 60  0001 C CNN
F 3 "" H 7500 7300 60  0001 C CNN
	1    7500 7300
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 51D5AA74
P 7050 7400
F 0 "#PWR?" H 7050 7400 30  0001 C CNN
F 1 "GND" H 7050 7330 30  0001 C CNN
F 2 "" H 7050 7400 60  0001 C CNN
F 3 "" H 7050 7400 60  0001 C CNN
	1    7050 7400
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AA7A
P 7050 7000
F 0 "#PWR?" H 7050 6960 30  0001 C CNN
F 1 "+3.3V" H 7050 7110 30  0000 C CNN
F 2 "" H 7050 7000 60  0001 C CNN
F 3 "" H 7050 7000 60  0001 C CNN
	1    7050 7000
	-1   0    0    -1  
$EndComp
Text Label 5650 1500 1    60   ~ 0
CLOCK_50
Text Label 8550 7200 0    60   ~ 0
CLOCK_50
$Comp
L C C?
U 1 1 51D5AA82
P 7050 7200
F 0 "C?" H 7100 7300 50  0000 L CNN
F 1 "0.1uF" H 7100 7100 50  0000 L CNN
F 2 "" H 7050 7200 60  0001 C CNN
F 3 "" H 7050 7200 60  0001 C CNN
	1    7050 7200
	1    0    0    -1  
$EndComp
$Comp
L OSC U?
U 1 1 51D5AA88
P 8000 7150
F 0 "U?" H 8200 7400 60  0000 C CNN
F 1 "50.00MHz" H 8050 6950 60  0000 C CNN
F 2 "" H 8000 7150 60  0001 C CNN
F 3 "" H 8000 7150 60  0001 C CNN
	1    8000 7150
	1    0    0    -1  
$EndComp
Text Label 3750 6000 3    60   ~ 0
~SS
Text Label 3050 2400 2    60   ~ 0
C_QCLK
Text Label 3050 2700 2    60   ~ 0
C_~CART
Text Label 4050 1500 1    60   ~ 0
LED3
Text Label 7800 2800 0    60   ~ 0
M_~CE
Text Label 3050 5100 2    60   ~ 0
M_~WE
NoConn ~ 1450 5100
$Comp
L C C?
U 1 1 51D5AA97
P 8750 3750
F 0 "C?" H 8800 3850 50  0000 L CNN
F 1 "0.1uF" H 8800 3650 50  0000 L CNN
F 2 "" H 8750 3750 60  0001 C CNN
F 3 "" H 8750 3750 60  0001 C CNN
	1    8750 3750
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 51D5AAA1
P 6900 950
F 0 "#PWR?" H 6900 950 30  0001 C CNN
F 1 "GND" H 6900 880 30  0001 C CNN
F 2 "" H 6900 950 60  0001 C CNN
F 3 "" H 6900 950 60  0001 C CNN
	1    6900 950 
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AAA7
P 2300 6750
F 0 "#PWR?" H 2300 6710 30  0001 C CNN
F 1 "+3.3V" H 2300 6860 30  0000 C CNN
F 2 "" H 2300 6750 60  0001 C CNN
F 3 "" H 2300 6750 60  0001 C CNN
	1    2300 6750
	1    0    0    -1  
$EndComp
NoConn ~ 2150 7050
NoConn ~ 2150 7150
NoConn ~ 1350 7150
Text Label 1350 6850 2    60   ~ 0
TCK
Text Label 1350 7050 2    60   ~ 0
TMS
Text Label 1350 6950 2    60   ~ 0
TDO
Text Label 1350 7250 2    60   ~ 0
TDI
$Comp
L GND #PWR?
U 1 1 51D5AAB4
P 2250 7300
F 0 "#PWR?" H 2250 7300 30  0001 C CNN
F 1 "GND" H 2250 7230 30  0001 C CNN
F 2 "" H 2250 7300 60  0001 C CNN
F 3 "" H 2250 7300 60  0001 C CNN
	1    2250 7300
	1    0    0    -1  
$EndComp
$Comp
L CONN_5X2 P?
U 1 1 51D5AABA
P 1750 7050
F 0 "P?" H 1750 7350 60  0000 C CNN
F 1 "JTAG" V 1750 7050 50  0000 C CNN
F 2 "" H 1750 7050 60  0001 C CNN
F 3 "" H 1750 7050 60  0001 C CNN
	1    1750 7050
	1    0    0    -1  
$EndComp
$Comp
L EPM3256A-TQFP144 U?
U 1 1 51D5AAC0
P 5350 3700
F 0 "U?" H 7550 5800 60  0000 C CNN
F 1 "EPM3256A-TQFP144" H 5350 3700 60  0000 C CNN
F 2 "" H 5350 3700 60  0001 C CNN
F 3 "" H 5350 3700 60  0001 C CNN
	1    5350 3700
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 51D5AAC6
P 2550 5300
F 0 "#PWR?" H 2550 5300 30  0001 C CNN
F 1 "GND" H 2550 5230 30  0001 C CNN
F 2 "" H 2550 5300 60  0001 C CNN
F 3 "" H 2550 5300 60  0001 C CNN
	1    2550 5300
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AACC
P 2300 3350
F 0 "#PWR?" H 2300 3310 30  0001 C CNN
F 1 "+3.3V" H 2300 3460 30  0000 C CNN
F 2 "" H 2300 3350 60  0001 C CNN
F 3 "" H 2300 3350 60  0001 C CNN
	1    2300 3350
	-1   0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 51D5AAD2
P 2300 3650
F 0 "C?" H 2350 3750 50  0000 L CNN
F 1 "0.1uF" H 2350 3550 50  0000 L CNN
F 2 "" H 2300 3650 60  0001 C CNN
F 3 "" H 2300 3650 60  0001 C CNN
	1    2300 3650
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 51D5AAD8
P 6350 7150
F 0 "#PWR?" H 6350 7150 30  0001 C CNN
F 1 "GND" H 6350 7080 30  0001 C CNN
F 2 "" H 6350 7150 60  0001 C CNN
F 3 "" H 6350 7150 60  0001 C CNN
	1    6350 7150
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AADE
P 4850 6700
F 0 "#PWR?" H 4850 6660 30  0001 C CNN
F 1 "+3.3V" H 4850 6810 30  0000 C CNN
F 2 "" H 4850 6700 60  0001 C CNN
F 3 "" H 4850 6700 60  0001 C CNN
	1    4850 6700
	-1   0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 51D5AAE4
P 6150 6750
F 0 "C?" H 6200 6850 50  0000 L CNN
F 1 "0.1uF" H 6200 6650 50  0000 L CNN
F 2 "" H 6150 6750 60  0001 C CNN
F 3 "" H 6150 6750 60  0001 C CNN
	1    6150 6750
	0    1    -1   0   
$EndComp
Text Label 1450 5200 0    60   ~ 0
C_~SLENB
$Comp
L COCOBUS P?
U 1 1 51D5AAEB
P 1150 3250
F 0 "P?" H 1050 5350 60  0000 C CNN
F 1 "COCOBUS" H 1100 1150 60  0000 C CNN
F 2 "" H 1150 3250 60  0001 C CNN
F 3 "" H 1150 3250 60  0001 C CNN
	1    1150 3250
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR?
U 1 1 51D5AAF1
P 1800 4650
F 0 "#PWR?" H 1800 4650 30  0001 C CNN
F 1 "GND" H 1800 4580 30  0001 C CNN
F 2 "" H 1800 4650 60  0001 C CNN
F 3 "" H 1800 4650 60  0001 C CNN
	1    1800 4650
	1    0    0    -1  
$EndComp
Text Label 1450 2200 0    60   ~ 0
C_D0
Text Label 1450 2300 0    60   ~ 0
C_D1
Text Label 1450 2400 0    60   ~ 0
C_D2
Text Label 1450 2500 0    60   ~ 0
C_D3
Text Label 1450 2600 0    60   ~ 0
C_D4
Text Label 1450 2700 0    60   ~ 0
C_D5
Text Label 1450 2800 0    60   ~ 0
C_D6
Text Label 1450 2900 0    60   ~ 0
C_D7
Text Label 1450 1800 0    60   ~ 0
C_ECLK
Text Label 1450 2000 0    60   ~ 0
C_~CART
Text Label 1450 3000 0    60   ~ 0
C_R/~W
Text Label 1450 4400 0    60   ~ 0
C_~CTS
Text Label 1450 4800 0    60   ~ 0
C_~SCS
NoConn ~ 1450 4700
Text Label 1450 1900 0    60   ~ 0
C_QCLK
Text Label 3050 3100 2    60   ~ 0
C_ECLK
Text Label 7800 4900 0    60   ~ 0
C_R/~W
Text Label 7800 2500 0    60   ~ 0
C_~CTS
Text Label 7800 5300 0    60   ~ 0
C_~SCS
Text Label 3050 3800 2    60   ~ 0
C_~SLENB
Text Label 1450 1500 0    60   ~ 0
C_~HALT
Text Label 1450 1600 0    60   ~ 0
C_~NMI
Text Label 1450 1700 0    60   ~ 0
C_~RESET
Text Label 4550 1500 1    60   ~ 0
C_~HALT
Text Label 3050 2600 2    60   ~ 0
C_~NMI
Text Label 5350 6000 3    60   ~ 0
LED0
Text Label 4250 1500 1    60   ~ 0
LED1
Text Label 4150 1500 1    60   ~ 0
LED2
Connection ~ 10300 2100
Wire Wire Line
	10300 1800 10300 2300
Wire Wire Line
	10300 2300 10650 2300
Connection ~ 10300 1900
Wire Wire Line
	10650 1900 10300 1900
Wire Wire Line
	10300 2100 10650 2100
Wire Wire Line
	12650 1850 12650 1900
Text Label 12000 1700 0    60   ~ 0
M_D7
Text Label 12000 1800 0    60   ~ 0
M_D6
Text Label 12000 1900 0    60   ~ 0
M_D5
Text Label 12000 2000 0    60   ~ 0
M_D4
Text Label 12000 2100 0    60   ~ 0
M_D3
Text Label 12000 2300 0    60   ~ 0
M_D2
Text Label 12000 2400 0    60   ~ 0
M_D1
Text Label 12000 2500 0    60   ~ 0
M_D0
Text Label 10650 2000 2    60   ~ 0
M_A15
Text Label 10650 2400 2    60   ~ 0
M_A14
Text Label 10650 1700 2    60   ~ 0
M_A13
Text Label 10650 2500 2    60   ~ 0
M_A12
Text Label 10650 1400 2    60   ~ 0
M_A11
Text Label 12000 1500 0    60   ~ 0
M_A10
Text Label 10650 1500 2    60   ~ 0
M_A9
Text Label 10650 1600 2    60   ~ 0
M_A8
Text Label 10650 2600 2    60   ~ 0
M_A7
Text Label 10650 2700 2    60   ~ 0
M_A6
Text Label 10650 2800 2    60   ~ 0
M_A5
Text Label 10650 2900 2    60   ~ 0
M_A4
Text Label 12000 2900 0    60   ~ 0
M_A3
Text Label 12000 2800 0    60   ~ 0
M_A2
Text Label 12000 2700 0    60   ~ 0
M_A1
Text Label 12000 2600 0    60   ~ 0
M_A0
$Comp
L +3.3V #PWR?
U 1 1 51D5AD87
P 12650 1850
F 0 "#PWR?" H 12650 1810 30  0001 C CNN
F 1 "+3.3V" H 12650 1960 30  0000 C CNN
F 2 "" H 12650 1850 60  0001 C CNN
F 3 "" H 12650 1850 60  0001 C CNN
	1    12650 1850
	-1   0    0    -1  
$EndComp
$Comp
L +3.3V #PWR?
U 1 1 51D5AD8D
P 10300 1800
F 0 "#PWR?" H 10300 1760 30  0001 C CNN
F 1 "+3.3V" H 10300 1910 30  0000 C CNN
F 2 "" H 10300 1800 60  0001 C CNN
F 3 "" H 10300 1800 60  0001 C CNN
	1    10300 1800
	-1   0    0    -1  
$EndComp
Text Label 12000 1600 0    60   ~ 0
M_~CE
$Comp
L R1LP0108ESF-5SI U?
U 1 1 51D5AD94
P 11350 2150
F 0 "U?" H 11650 3050 60  0000 C CNN
F 1 "R1LP0108ESF-5SI" H 11350 1250 60  0000 C CNN
F 2 "" H 11350 2150 60  0001 C CNN
F 3 "" H 11350 2150 60  0001 C CNN
	1    11350 2150
	1    0    0    -1  
$EndComp
Text Label 10650 1800 2    60   ~ 0
M_~WE
Text Label 12000 1400 0    60   ~ 0
M_~OE
$Comp
L GND #PWR?
U 1 1 51D5AD9C
P 12650 2300
F 0 "#PWR?" H 12650 2300 30  0001 C CNN
F 1 "GND" H 12650 2230 30  0001 C CNN
F 2 "" H 12650 2300 60  0001 C CNN
F 3 "" H 12650 2300 60  0001 C CNN
	1    12650 2300
	1    0    0    -1  
$EndComp
$Comp
L C C?
U 1 1 51D5ADA2
P 12650 2100
F 0 "C?" H 12700 2200 50  0000 L CNN
F 1 "0.1uF" H 12700 2000 50  0000 L CNN
F 2 "" H 12650 2100 60  0001 C CNN
F 3 "" H 12650 2100 60  0001 C CNN
	1    12650 2100
	1    0    0    -1  
$EndComp
Text HLabel 9900 3600 2    60   Input ~ 0
A_A0
Text HLabel 9900 3700 2    60   Input ~ 0
A_A1
Text HLabel 9900 3800 2    60   Input ~ 0
A_A2
Text HLabel 9900 3900 2    60   Input ~ 0
A_A3
Text HLabel 9900 4000 2    60   Input ~ 0
A_A4
Text HLabel 9900 4100 2    60   Input ~ 0
A_A5
Text HLabel 9900 4200 2    60   Input ~ 0
A_A6
Text HLabel 9900 4300 2    60   Input ~ 0
A_A7
Text HLabel 9900 4400 2    60   Input ~ 0
A_A8
Text HLabel 9900 4500 2    60   Input ~ 0
A_A9
Text HLabel 9900 4600 2    60   Input ~ 0
A_A10
Text HLabel 9900 4700 2    60   Input ~ 0
A_A11
Text HLabel 9900 4800 2    60   Input ~ 0
A_A12
Text HLabel 9900 4900 2    60   Input ~ 0
A_A13
Text HLabel 9900 5000 2    60   Input ~ 0
A_A14
Text HLabel 9900 5100 2    60   Input ~ 0
A_A15
Text HLabel 10800 3600 2    60   BiDi ~ 0
A_D0
Text HLabel 10800 3700 2    60   BiDi ~ 0
A_D1
Text HLabel 10800 3800 2    60   BiDi ~ 0
A_D2
Text HLabel 10800 3900 2    60   BiDi ~ 0
A_D3
Text HLabel 10800 4000 2    60   BiDi ~ 0
A_D4
Text HLabel 10800 4100 2    60   BiDi ~ 0
A_D5
Text HLabel 10800 4200 2    60   BiDi ~ 0
A_D6
Text HLabel 10800 4300 2    60   BiDi ~ 0
A_D7
Text HLabel 10800 4400 2    60   Input ~ 0
A_R/~W
Text HLabel 10800 4500 2    60   Input ~ 0
A_~SELECT
Text HLabel 10800 4600 2    60   Output ~ 0
A_FDCINT
Text HLabel 10800 4700 2    60   Output ~ 0
A_ETHINT
Text HLabel 5600 600  2    60   Output ~ 0
C_~RESET
Wire Wire Line
	5450 600  5450 1500
Text HLabel 8150 2400 2    60   Output ~ 0
TDO
Text HLabel 2850 2250 0    60   Input ~ 0
TDI
Text HLabel 8100 3900 2    60   Input ~ 0
TCK
Text HLabel 2850 3850 0    60   Input ~ 0
TMS
Wire Wire Line
	2850 2250 2900 2250
Wire Wire Line
	2900 2250 2900 2300
Wire Wire Line
	2900 2300 3050 2300
Wire Wire Line
	7800 3900 8100 3900
Wire Wire Line
	7800 2400 8150 2400
Wire Wire Line
	2850 3850 2950 3850
Wire Wire Line
	2950 3850 2950 3900
Wire Wire Line
	2950 3900 3050 3900
Connection ~ 5450 600 
Wire Wire Line
	1900 600  5600 600 
Wire Wire Line
	1900 600  1900 1700
Wire Wire Line
	1900 1700 1450 1700
Text HLabel 2200 1800 2    60   Output ~ 0
C_POWER
Wire Wire Line
	1450 2100 2000 2100
Wire Wire Line
	2000 2100 2000 1800
Wire Wire Line
	2000 1800 2200 1800
Text Label 1450 2100 0    60   ~ 0
C_POWER
Text Label 3050 2100 2    60   ~ 0
C_POWER
$EndSCHEMATC
