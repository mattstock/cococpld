EESchema Schematic File Version 2  date Tue 07 May 2013 02:44:39 PM EDT
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
EELAYER 25  0
EELAYER END
$Descr User 14000 8500
encoding utf-8
Sheet 3 3
Title "Color Computer Bus Interface"
Date "7 may 2013"
Rev "1.3"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text Label 3800 6850 0    60   ~ 0
C_POWER
Wire Wire Line
	2200 3050 1850 3050
Wire Wire Line
	3400 6750 3150 6750
Wire Wire Line
	3150 6750 3150 6850
Wire Wire Line
	3150 6850 3050 6850
Wire Wire Line
	3400 6550 3250 6550
Wire Wire Line
	3250 6550 3250 6150
Wire Wire Line
	3250 6150 3050 6150
Connection ~ 2650 6850
Connection ~ 2650 6500
Wire Wire Line
	4650 1750 4650 1300
Wire Wire Line
	1800 2150 1800 2650
Wire Wire Line
	1800 2650 1200 2650
Connection ~ 5950 6650
Wire Wire Line
	5650 5850 5650 6350
Wire Wire Line
	5950 6350 5950 6700
Wire Wire Line
	5400 6650 5550 6650
Wire Wire Line
	5400 6650 5400 6550
Connection ~ 6850 6650
Wire Wire Line
	6850 5850 6850 6700
Wire Wire Line
	6100 6650 6250 6650
Wire Wire Line
	6100 6650 6100 6550
Connection ~ 9200 3550
Wire Wire Line
	8200 3550 9200 3550
Connection ~ 9200 5150
Wire Wire Line
	8200 5150 9200 5150
Connection ~ 3050 3350
Wire Wire Line
	3050 5350 3050 2450
Wire Wire Line
	3050 2450 4100 2450
Connection ~ 3050 4750
Wire Wire Line
	3050 3750 4100 3750
Connection ~ 3250 4750
Wire Wire Line
	3050 4750 3550 4750
Connection ~ 7150 1250
Wire Wire Line
	7150 1250 6550 1250
Wire Wire Line
	6550 1250 6550 1750
Connection ~ 5450 1050
Wire Wire Line
	5450 1050 5450 1750
Connection ~ 5950 1050
Wire Wire Line
	5950 1750 5950 850 
Wire Wire Line
	5550 1050 5350 1050
Wire Wire Line
	5350 1050 5350 1150
Connection ~ 3250 4350
Wire Wire Line
	7250 1150 7250 1050
Wire Wire Line
	7250 1050 7050 1050
Wire Wire Line
	6650 1750 6650 850 
Connection ~ 6650 1050
Wire Wire Line
	7150 1050 7150 1750
Connection ~ 7150 1050
Connection ~ 2200 7350
Wire Wire Line
	2100 7350 2200 7350
Wire Wire Line
	2100 6950 2200 6950
Wire Wire Line
	2200 6950 2200 7400
Wire Wire Line
	2250 6850 2250 7050
Wire Wire Line
	2250 7050 2100 7050
Wire Wire Line
	4100 4350 3150 4350
Wire Wire Line
	6050 1750 6050 1250
Wire Wire Line
	6050 1250 5450 1250
Connection ~ 5450 1250
Wire Wire Line
	4100 4550 3550 4550
Wire Wire Line
	3550 4550 3550 4750
Wire Wire Line
	4100 5250 3050 5250
Connection ~ 3050 5250
Wire Wire Line
	3050 3350 4100 3350
Connection ~ 3050 3750
Wire Wire Line
	8200 2650 9200 2650
Wire Wire Line
	9200 2650 9200 5500
Wire Wire Line
	8200 4350 9200 4350
Connection ~ 9200 4350
Wire Wire Line
	6250 6650 6250 5850
Wire Wire Line
	6850 6650 6650 6650
Wire Wire Line
	6350 5850 6350 6350
Wire Wire Line
	6350 6350 6850 6350
Connection ~ 6850 6350
Wire Wire Line
	5550 6650 5550 5850
Wire Wire Line
	6150 5850 6150 6350
Wire Wire Line
	6150 6350 5650 6350
Connection ~ 5950 6350
Connection ~ 1850 2850
Wire Wire Line
	1200 2850 1850 2850
Wire Wire Line
	1550 5400 1550 5250
Wire Wire Line
	1550 5250 1200 5250
Wire Wire Line
	1550 5350 1200 5350
Connection ~ 1550 5350
Wire Wire Line
	2250 2850 2250 2800
Wire Wire Line
	1850 2850 1850 3050
Wire Wire Line
	1200 2750 1950 2750
Wire Wire Line
	1950 2750 1950 2400
Wire Wire Line
	1950 2400 2400 2400
Wire Wire Line
	2400 2400 2400 2150
Wire Wire Line
	2650 6150 2650 7300
Connection ~ 2650 7150
Wire Wire Line
	3050 7150 3250 7150
Wire Wire Line
	3250 7150 3250 6850
Wire Wire Line
	3250 6850 3400 6850
Wire Wire Line
	3400 6650 3150 6650
Wire Wire Line
	3150 6650 3150 6500
Wire Wire Line
	3150 6500 3050 6500
$Comp
L R_PACK4 RP1
U 1 1 51894A44
P 3600 6900
F 0 "RP1" H 3600 7350 40  0000 C CNN
F 1 "150" H 3600 6850 40  0000 C CNN
	1    3600 6900
	1    0    0    -1  
$EndComp
Text Label 3800 6550 0    60   ~ 0
LED0
Text Label 3800 6750 0    60   ~ 0
LED2
Text Label 3800 6650 0    60   ~ 0
LED1
$Comp
L LED D6
U 1 1 518945A4
P 2850 6850
F 0 "D6" H 2850 6950 50  0000 C CNN
F 1 "S2" H 2850 6750 50  0000 C CNN
	1    2850 6850
	-1   0    0    1   
$EndComp
$Comp
L LED D3
U 1 1 5189459E
P 2850 6150
F 0 "D3" H 2850 6250 50  0000 C CNN
F 1 "S0" H 2850 6050 50  0000 C CNN
	1    2850 6150
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR022
U 1 1 5189454F
P 2650 7300
F 0 "#PWR022" H 2650 7300 30  0001 C CNN
F 1 "GND" H 2650 7230 30  0001 C CNN
	1    2650 7300
	1    0    0    -1  
$EndComp
$Comp
L LED D5
U 1 1 5189453D
P 2850 6500
F 0 "D5" H 2850 6600 50  0000 C CNN
F 1 "S1" H 2850 6400 50  0000 C CNN
	1    2850 6500
	-1   0    0    1   
$EndComp
Text Label 5050 5850 3    60   ~ 0
LED2
Text Label 5350 5850 3    60   ~ 0
LED1
Text Label 4100 2650 2    60   ~ 0
LED0
Text HLabel 8200 3350 2    60   Output ~ 0
A_BUSMASTER
$Comp
L JUMPER JP1
U 1 1 518933D0
P 2100 2150
F 0 "JP1" H 2100 2300 60  0000 C CNN
F 1 "CART_BOOT" H 2100 2070 40  0000 C CNN
	1    2100 2150
	1    0    0    -1  
$EndComp
Text Label 4750 1750 1    60   ~ 0
C_~RESET
Text Label 4850 1750 1    60   ~ 0
C_~NMI
Text Label 4950 1750 1    60   ~ 0
C_~HALT
Text Label 1200 2450 0    60   ~ 0
C_~RESET
Text Label 1200 2350 0    60   ~ 0
C_~NMI
Text Label 1200 2250 0    60   ~ 0
C_~HALT
Text Label 1200 5750 0    60   ~ 0
C_A14
Text Label 2200 3050 0    60   ~ 0
C_POWER
Text Label 5450 5850 3    60   ~ 0
C_~SLENB
Text Label 5250 5850 3    60   ~ 0
C_A14
Text Label 5150 5850 3    60   ~ 0
C_A13
Text Label 6150 1750 1    60   ~ 0
C_~SCS
Text Label 4950 5850 3    60   ~ 0
C_~CTS
Text Label 4850 5850 3    60   ~ 0
C_A12
Text Label 4750 5850 3    60   ~ 0
C_A11
Text Label 4100 5150 2    60   ~ 0
C_A10
Text Label 4100 5050 2    60   ~ 0
C_A9
Text Label 4100 4950 2    60   ~ 0
C_A8
Text Label 4100 4850 2    60   ~ 0
C_A7
Text Label 4100 4750 2    60   ~ 0
C_A6
Text Label 4100 4650 2    60   ~ 0
C_A5
Text Label 4100 4450 2    60   ~ 0
C_A4
Text Label 4100 4250 2    60   ~ 0
C_A3
Text Label 4100 4150 2    60   ~ 0
C_A2
Text Label 4100 4050 2    60   ~ 0
C_A1
Text Label 4100 3850 2    60   ~ 0
C_A0
Text Label 4100 3650 2    60   ~ 0
C_R/~W
Text Label 4100 3550 2    60   ~ 0
C_D7
Text Label 4100 3450 2    60   ~ 0
C_D6
Text Label 4100 3250 2    60   ~ 0
C_D5
Text Label 4100 3150 2    60   ~ 0
C_D4
Text Label 4100 3050 2    60   ~ 0
C_D3
Text Label 4100 2950 2    60   ~ 0
C_D2
Text Label 4100 2850 2    60   ~ 0
C_D1
Text Label 4100 2750 2    60   ~ 0
C_D0
Text Label 8200 3650 0    60   ~ 0
C_POWER
Text Label 6450 1750 1    60   ~ 0
C_ECLK
Text HLabel 8200 3850 2    60   Output ~ 0
E_~CS
Text HLabel 8200 4050 2    60   Output ~ 0
S_~CS
Text Label 1200 2650 0    60   ~ 0
C_QCLK
NoConn ~ 1200 5450
$Comp
L DIODESCH D1
U 1 1 5185B499
P 2050 2850
F 0 "D1" H 2050 2950 40  0000 C CNN
F 1 "DIODE" H 2050 2750 40  0000 C CNN
	1    2050 2850
	1    0    0    -1  
$EndComp
Text Label 1200 5650 0    60   ~ 0
C_A13
Text Label 1200 5550 0    60   ~ 0
C_~SCS
Text Label 1200 5150 0    60   ~ 0
C_~CTS
Text Label 1200 3750 0    60   ~ 0
C_R/~W
Text Label 1200 2750 0    60   ~ 0
C_~CART
Text Label 1200 2550 0    60   ~ 0
C_ECLK
Text Label 1200 5050 0    60   ~ 0
C_A12
Text Label 1200 4950 0    60   ~ 0
C_A11
Text Label 1200 4850 0    60   ~ 0
C_A10
Text Label 1200 4750 0    60   ~ 0
C_A9
Text Label 1200 4650 0    60   ~ 0
C_A8
Text Label 1200 4550 0    60   ~ 0
C_A7
Text Label 1200 4450 0    60   ~ 0
C_A6
Text Label 1200 4350 0    60   ~ 0
C_A5
Text Label 1200 4250 0    60   ~ 0
C_A4
Text Label 1200 4150 0    60   ~ 0
C_A3
Text Label 1200 4050 0    60   ~ 0
C_A2
Text Label 1200 3950 0    60   ~ 0
C_A1
Text Label 1200 3850 0    60   ~ 0
C_A0
Text Label 1200 3650 0    60   ~ 0
C_D7
Text Label 1200 3550 0    60   ~ 0
C_D6
Text Label 1200 3450 0    60   ~ 0
C_D5
Text Label 1200 3350 0    60   ~ 0
C_D4
Text Label 1200 3250 0    60   ~ 0
C_D3
Text Label 1200 3150 0    60   ~ 0
C_D2
Text Label 1200 3050 0    60   ~ 0
C_D1
Text Label 1200 2950 0    60   ~ 0
C_D0
$Comp
L GND #PWR023
U 1 1 5185B498
P 1550 5400
F 0 "#PWR023" H 1550 5400 30  0001 C CNN
F 1 "GND" H 1550 5330 30  0001 C CNN
	1    1550 5400
	1    0    0    -1  
$EndComp
$Comp
L COCOBUS P1
U 1 1 5185B497
P 900 4000
F 0 "P1" H 800 6100 60  0000 C CNN
F 1 "COCOBUS" H 850 1900 60  0000 C CNN
	1    900  4000
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR024
U 1 1 5185B496
P 2250 2800
F 0 "#PWR024" H 2250 2890 20  0001 C CNN
F 1 "+5V" H 2250 2890 30  0000 C CNN
	1    2250 2800
	1    0    0    -1  
$EndComp
Text Label 1200 5950 0    60   ~ 0
C_~SLENB
$Comp
L R R1
U 1 1 5185B495
P 1850 3300
F 0 "R1" V 1930 3300 50  0000 C CNN
F 1 "47K" V 1850 3300 50  0000 C CNN
	1    1850 3300
	-1   0    0    1   
$EndComp
$Comp
L GND #PWR025
U 1 1 5185B494
P 1850 3550
F 0 "#PWR025" H 1850 3550 30  0001 C CNN
F 1 "GND" H 1850 3480 30  0001 C CNN
	1    1850 3550
	1    0    0    -1  
$EndComp
$Comp
L LED D2
U 1 1 5185B492
P 2850 7150
F 0 "D2" H 2850 7250 50  0000 C CNN
F 1 "C_PWR" H 2850 7050 50  0000 C CNN
	1    2850 7150
	-1   0    0    1   
$EndComp
Text HLabel 8200 4150 2    60   Output ~ 0
M_A14
Text HLabel 8200 4250 2    60   Output ~ 0
M_A13
Text HLabel 8200 4450 2    60   Output ~ 0
M_A12
Text HLabel 8200 4550 2    60   Output ~ 0
M_A11
Text HLabel 8200 4650 2    60   Output ~ 0
M_A10
Text HLabel 8200 4750 2    60   Output ~ 0
M_A9
Text HLabel 8200 4850 2    60   Output ~ 0
M_A8
Text HLabel 8200 4950 2    60   Output ~ 0
M_A7
Text HLabel 8200 5050 2    60   Output ~ 0
M_A6
Text HLabel 8200 5250 2    60   Output ~ 0
M_A5
Text HLabel 7550 5850 3    60   Output ~ 0
M_A4
Text HLabel 7450 5850 3    60   Output ~ 0
M_A3
Text HLabel 7350 5850 3    60   Output ~ 0
M_A2
Text HLabel 7250 5850 3    60   Output ~ 0
M_A1
Text HLabel 7150 5850 3    60   Output ~ 0
M_A0
Text HLabel 5050 1750 1    60   Input ~ 0
A_A15
Text HLabel 5150 1750 1    60   Input ~ 0
A_A14
Text HLabel 5250 1750 1    60   Input ~ 0
A_A13
Text HLabel 5350 1750 1    60   Input ~ 0
A_A12
Text HLabel 5550 1750 1    60   Input ~ 0
A_A11
Text HLabel 5650 1750 1    60   Input ~ 0
A_A10
Text HLabel 5750 1750 1    60   Input ~ 0
A_A9
Text HLabel 5850 1750 1    60   Input ~ 0
A_A8
Text HLabel 6250 1750 1    60   Input ~ 0
A_A7
Text HLabel 6350 1750 1    60   Input ~ 0
A_A6
Text HLabel 6750 1750 1    60   Input ~ 0
A_A5
Text HLabel 6850 1750 1    60   Input ~ 0
A_A4
Text HLabel 6950 1750 1    60   Input ~ 0
A_A3
Text HLabel 7050 1750 1    60   Input ~ 0
A_A2
Text HLabel 7250 1750 1    60   Input ~ 0
A_A1
Text HLabel 7350 1750 1    60   Input ~ 0
A_A0
Text HLabel 7650 1750 1    60   BiDi ~ 0
A_D7
Text HLabel 8200 2450 2    60   BiDi ~ 0
A_D6
Text HLabel 8200 2550 2    60   BiDi ~ 0
A_D5
Text HLabel 8200 2850 2    60   BiDi ~ 0
A_D4
Text HLabel 8200 2950 2    60   BiDi ~ 0
A_D3
Text HLabel 8200 3050 2    60   BiDi ~ 0
A_D2
Text HLabel 8200 3150 2    60   BiDi ~ 0
A_D1
Text HLabel 8200 3250 2    60   BiDi ~ 0
A_D0
Text HLabel 6750 5850 3    60   BiDi ~ 0
M_D7
Text HLabel 6650 5850 3    60   BiDi ~ 0
M_D6
Text HLabel 6550 5850 3    60   BiDi ~ 0
M_D5
Text HLabel 6450 5850 3    60   BiDi ~ 0
M_D4
Text HLabel 6050 5850 3    60   BiDi ~ 0
M_D3
Text HLabel 5950 5850 3    60   BiDi ~ 0
M_D2
Text HLabel 5850 5850 3    60   BiDi ~ 0
M_D1
Text HLabel 5750 5850 3    60   BiDi ~ 0
M_D0
$Comp
L C C6
U 1 1 51850418
P 5750 6650
F 0 "C6" H 5800 6750 50  0000 L CNN
F 1 "0.1uF" H 5800 6550 50  0000 L CNN
	1    5750 6650
	0    1    -1   0   
$EndComp
$Comp
L +3.3V #PWR026
U 1 1 51850417
P 5400 6550
F 0 "#PWR026" H 5400 6510 30  0001 C CNN
F 1 "+3.3V" H 5400 6660 30  0000 C CNN
	1    5400 6550
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR027
U 1 1 51850416
P 5950 6700
F 0 "#PWR027" H 5950 6700 30  0001 C CNN
F 1 "GND" H 5950 6630 30  0001 C CNN
	1    5950 6700
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR028
U 1 1 518503FA
P 6850 6700
F 0 "#PWR028" H 6850 6700 30  0001 C CNN
F 1 "GND" H 6850 6630 30  0001 C CNN
	1    6850 6700
	1    0    0    -1  
$EndComp
$Comp
L C C5
U 1 1 518502F3
P 5750 1050
F 0 "C5" H 5800 1150 50  0000 L CNN
F 1 "0.1uF" H 5800 950 50  0000 L CNN
	1    5750 1050
	0    1    -1   0   
$EndComp
$Comp
L +3.3V #PWR029
U 1 1 518502F2
P 5950 850
F 0 "#PWR029" H 5950 810 30  0001 C CNN
F 1 "+3.3V" H 5950 960 30  0000 C CNN
	1    5950 850 
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR030
U 1 1 518502F1
P 5350 1150
F 0 "#PWR030" H 5350 1150 30  0001 C CNN
F 1 "GND" H 5350 1080 30  0001 C CNN
	1    5350 1150
	-1   0    0    -1  
$EndComp
$Comp
L EPM3128A-TQFP144 U3
U 1 1 5185028D
P 6150 3800
F 0 "U3" H 7800 5650 60  0000 C CNN
F 1 "EPM3128A-TQFP144" H 6150 3800 60  0000 C CNN
	1    6150 3800
	1    0    0    -1  
$EndComp
Text HLabel 7550 1750 1    60   Input ~ 0
A_RW
Text HLabel 8200 3450 2    60   Input ~ 0
A_BUSREQ
Text HLabel 7450 1750 1    60   Output ~ 0
A_EEN
$Comp
L CONN_5X2 P2
U 1 1 517C55E0
P 1700 7150
F 0 "P2" H 1700 7450 60  0000 C CNN
F 1 "JTAG" V 1700 7150 50  0000 C CNN
	1    1700 7150
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR031
U 1 1 517C55DF
P 2200 7400
F 0 "#PWR031" H 2200 7400 30  0001 C CNN
F 1 "GND" H 2200 7330 30  0001 C CNN
	1    2200 7400
	1    0    0    -1  
$EndComp
Text Label 1300 7350 2    60   ~ 0
TDI
Text Label 1300 7050 2    60   ~ 0
TDO
Text Label 1300 7150 2    60   ~ 0
TMS
Text Label 1300 6950 2    60   ~ 0
TCK
NoConn ~ 1300 7250
NoConn ~ 2100 7250
NoConn ~ 2100 7150
$Comp
L +3.3V #PWR032
U 1 1 517C55DE
P 2250 6850
F 0 "#PWR032" H 2250 6810 30  0001 C CNN
F 1 "+3.3V" H 2250 6960 30  0000 C CNN
	1    2250 6850
	1    0    0    -1  
$EndComp
Text HLabel 4650 1300 1    60   Output ~ 0
A_REGINT
Text HLabel 6950 5850 3    60   Output ~ 0
M_RW
Text HLabel 7050 5850 3    60   Output ~ 0
M_~OE
Text HLabel 8200 3750 2    60   Input ~ 0
A_POWER
$Comp
L GND #PWR033
U 1 1 517C5336
P 3050 5350
F 0 "#PWR033" H 3050 5350 30  0001 C CNN
F 1 "GND" H 3050 5280 30  0001 C CNN
	1    3050 5350
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR034
U 1 1 517C5335
P 9200 5500
F 0 "#PWR034" H 9200 5500 30  0001 C CNN
F 1 "GND" H 9200 5430 30  0001 C CNN
	1    9200 5500
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR035
U 1 1 517C5334
P 7250 1150
F 0 "#PWR035" H 7250 1150 30  0001 C CNN
F 1 "GND" H 7250 1080 30  0001 C CNN
	1    7250 1150
	1    0    0    -1  
$EndComp
Text Label 4100 2550 2    60   ~ 0
TDI
Text Label 4100 3950 2    60   ~ 0
TMS
Text Label 8200 3950 0    60   ~ 0
TCK
Text Label 8200 2750 0    60   ~ 0
TDO
$Comp
L +3.3V #PWR036
U 1 1 517C5333
P 6650 850
F 0 "#PWR036" H 6650 810 30  0001 C CNN
F 1 "+3.3V" H 6650 960 30  0000 C CNN
	1    6650 850 
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR037
U 1 1 517C5332
P 6100 6550
F 0 "#PWR037" H 6100 6510 30  0001 C CNN
F 1 "+3.3V" H 6100 6660 30  0000 C CNN
	1    6100 6550
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR038
U 1 1 517C5331
P 3150 4350
F 0 "#PWR038" H 3150 4310 30  0001 C CNN
F 1 "+3.3V" H 3150 4460 30  0000 C CNN
	1    3150 4350
	1    0    0    -1  
$EndComp
$Comp
L C C1
U 1 1 517C532E
P 3250 4550
F 0 "C1" H 3300 4650 50  0000 L CNN
F 1 "0.1uF" H 3300 4450 50  0000 L CNN
	1    3250 4550
	1    0    0    -1  
$EndComp
$Comp
L C C4
U 1 1 517C532C
P 6450 6650
F 0 "C4" H 6500 6750 50  0000 L CNN
F 1 "0.1uF" H 6500 6550 50  0000 L CNN
	1    6450 6650
	0    -1   -1   0   
$EndComp
$Comp
L C C3
U 1 1 517C532B
P 6850 1050
F 0 "C3" H 6900 1150 50  0000 L CNN
F 1 "0.1uF" H 6900 950 50  0000 L CNN
	1    6850 1050
	0    -1   -1   0   
$EndComp
$EndSCHEMATC
