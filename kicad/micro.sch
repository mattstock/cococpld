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
Sheet 3 3
Title "Color Computer FDC Ethernet Controller"
Date "4 aug 2013"
Rev "2.0"
Comp "Bexkat Systems LLC 2013"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L ATMEGA2560-A IC1
U 1 1 51D5E753
P 6550 4200
F 0 "IC1" H 5400 7000 40  0000 L BNN
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
Text HLabel 5250 1600 0    60   Input ~ 0
~RESET
Text HLabel 8100 5600 2    60   Input ~ 0
A_FCFG_I
$Comp
L +5V #PWR043
U 1 1 51D60C51
P 6500 1200
F 0 "#PWR043" H 6500 1290 20  0001 C CNN
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
L GND #PWR044
U 1 1 51D60C7D
P 6550 7200
F 0 "#PWR044" H 6550 7200 30  0001 C CNN
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
L CRYSTAL X1
U 1 1 51D60CD1
P 1800 1400
F 0 "X1" H 1800 1550 60  0000 C CNN
F 1 "16MHz" H 1800 1250 60  0000 C CNN
F 2 "~" H 1800 1400 60  0000 C CNN
F 3 "~" H 1800 1400 60  0000 C CNN
	1    1800 1400
	1    0    0    -1  
$EndComp
$Comp
L R R1
U 1 1 51D60CE0
P 1800 1100
F 0 "R1" V 1880 1100 40  0000 C CNN
F 1 "1M" V 1807 1101 40  0000 C CNN
F 2 "~" V 1730 1100 30  0000 C CNN
F 3 "~" H 1800 1100 30  0000 C CNN
	1    1800 1100
	0    -1   -1   0   
$EndComp
$Comp
L C C11
U 1 1 51D60D15
P 1500 1700
F 0 "C11" H 1500 1800 40  0000 L CNN
F 1 "22pF" H 1506 1615 40  0000 L CNN
F 2 "~" H 1538 1550 30  0000 C CNN
F 3 "~" H 1500 1700 60  0000 C CNN
	1    1500 1700
	1    0    0    -1  
$EndComp
$Comp
L C C12
U 1 1 51D60D24
P 2100 1700
F 0 "C12" H 2100 1800 40  0000 L CNN
F 1 "22pF" H 2106 1615 40  0000 L CNN
F 2 "~" H 2138 1550 30  0000 C CNN
F 3 "~" H 2100 1700 60  0000 C CNN
	1    2100 1700
	1    0    0    -1  
$EndComp
Connection ~ 2100 1400
Connection ~ 1500 1400
Wire Wire Line
	1500 1900 2100 1900
$Comp
L GND #PWR045
U 1 1 51D60D76
P 1800 1950
F 0 "#PWR045" H 1800 1950 30  0001 C CNN
F 1 "GND" H 1800 1880 30  0001 C CNN
F 2 "" H 1800 1950 60  0000 C CNN
F 3 "" H 1800 1950 60  0000 C CNN
	1    1800 1950
	1    0    0    -1  
$EndComp
Wire Wire Line
	1800 1900 1800 1950
Connection ~ 1800 1900
Wire Wire Line
	2050 1100 2100 1100
Wire Wire Line
	2100 1100 2100 1500
Wire Wire Line
	1500 1500 1500 1100
Wire Wire Line
	1500 1100 1550 1100
Text Label 2100 1400 0    60   ~ 0
XTAL2
Text Label 1500 1400 2    60   ~ 0
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
$Comp
L CONN_3 P11
U 1 1 51FB918E
P 9350 5300
F 0 "P11" V 9300 5300 50  0000 C CNN
F 1 "SERIAL" V 9400 5300 40  0000 C CNN
F 2 "" H 9350 5300 60  0000 C CNN
F 3 "" H 9350 5300 60  0000 C CNN
	1    9350 5300
	1    0    0    -1  
$EndComp
Wire Wire Line
	7850 5200 9000 5200
Wire Wire Line
	7850 5300 9000 5300
$Comp
L GND #PWR046
U 1 1 51FB9229
P 8950 5500
F 0 "#PWR046" H 8950 5500 30  0001 C CNN
F 1 "GND" H 8950 5430 30  0001 C CNN
F 2 "" H 8950 5500 60  0000 C CNN
F 3 "" H 8950 5500 60  0000 C CNN
	1    8950 5500
	1    0    0    -1  
$EndComp
Wire Wire Line
	8950 5500 8950 5400
Wire Wire Line
	8950 5400 9000 5400
$Comp
L SWITCH_INV SW2
U 1 1 51FC2D05
P 10500 5800
F 0 "SW2" H 10300 5950 50  0000 C CNN
F 1 "MODE SW" H 10350 5650 50  0000 C CNN
F 2 "~" H 10500 5800 60  0000 C CNN
F 3 "~" H 10500 5800 60  0000 C CNN
	1    10500 5800
	1    0    0    -1  
$EndComp
Text HLabel 8100 5700 2    60   Input ~ 0
A_FCMD_I
Wire Wire Line
	7850 5700 8100 5700
$Comp
L +5V #PWR047
U 1 1 51FC56B4
P 9750 5200
F 0 "#PWR047" H 9750 5290 20  0001 C CNN
F 1 "+5V" H 9750 5290 30  0000 C CNN
F 2 "" H 9750 5200 60  0000 C CNN
F 3 "" H 9750 5200 60  0000 C CNN
	1    9750 5200
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 51FC56DA
P 9750 5550
F 0 "R3" V 9830 5550 40  0000 C CNN
F 1 "1k" V 9757 5551 40  0000 C CNN
F 2 "~" V 9680 5550 30  0000 C CNN
F 3 "~" H 9750 5550 30  0000 C CNN
	1    9750 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 5200 9750 5300
Wire Wire Line
	7850 5800 10000 5800
Connection ~ 9750 5800
$Comp
L GND #PWR048
U 1 1 51FC57B8
P 11100 6000
F 0 "#PWR048" H 11100 6000 30  0001 C CNN
F 1 "GND" H 11100 5930 30  0001 C CNN
F 2 "" H 11100 6000 60  0000 C CNN
F 3 "" H 11100 6000 60  0000 C CNN
	1    11100 6000
	1    0    0    -1  
$EndComp
Text Label 8850 5800 0    60   ~ 0
MODE
Text Label 7850 5200 0    60   ~ 0
RX
Text Label 7850 5300 0    60   ~ 0
TX
Wire Wire Line
	11000 5700 11100 5700
Wire Wire Line
	11100 5700 11100 6000
$EndSCHEMATC
