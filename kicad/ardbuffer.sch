EESchema Schematic File Version 2  date 4/22/2013 8:21:37 PM
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
Sheet 2 3
Title "Color Computer Bus Interface"
Date "23 apr 2013"
Rev "1.2"
Comp "Bexkat Systems LLC"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L +5V #PWR022
U 1 1 5175D31E
P 2700 1700
F 0 "#PWR022" H 2700 1790 20  0001 C CNN
F 1 "+5V" H 2700 1790 30  0000 C CNN
	1    2700 1700
	-1   0    0    -1  
$EndComp
Connection ~ 2700 2200
$Comp
L R R12
U 1 1 5175D312
P 2700 1950
F 0 "R12" V 2780 1950 50  0000 C CNN
F 1 "1K" V 2700 1950 50  0000 C CNN
	1    2700 1950
	-1   0    0    -1  
$EndComp
Wire Wire Line
	2650 2200 2900 2200
Wire Wire Line
	6200 1700 5800 1700
Wire Wire Line
	5800 1700 5800 2600
Wire Wire Line
	5800 2600 5900 2600
Wire Wire Line
	5900 2900 5900 2800
Connection ~ 4000 3850
Wire Wire Line
	4000 3850 4000 3700
Wire Wire Line
	3850 3200 4000 3200
Wire Wire Line
	4000 3200 4000 3150
Wire Wire Line
	3700 4850 3450 4850
Connection ~ 2650 3200
Connection ~ 2650 5250
Wire Wire Line
	2500 5250 3450 5250
Connection ~ 3050 5250
Wire Wire Line
	3450 5250 3450 5050
Wire Wire Line
	3050 5250 3050 5300
Wire Wire Line
	2650 3200 2650 3350
Wire Wire Line
	2650 5250 2650 5050
Wire Wire Line
	3450 3200 2550 3200
Connection ~ 3450 3200
Wire Wire Line
	2650 4850 2150 4850
Wire Wire Line
	3450 4950 3700 4950
Connection ~ 4000 3200
Wire Wire Line
	3450 3850 4050 3850
Wire Wire Line
	3450 3350 3450 2700
Wire Wire Line
	3450 2700 5900 2700
Wire Wire Line
	5700 2500 5700 1600
Wire Wire Line
	5700 2500 5900 2500
Wire Wire Line
	5700 1600 6200 1600
Wire Wire Line
	5350 5200 5350 5300
Wire Wire Line
	5000 5100 5350 5100
Text Label 5350 4700 2    60   ~ 0
SCK
Text Label 5350 5000 2    60   ~ 0
MOSI
Text Label 5350 4900 2    60   ~ 0
MISO
Text Label 5350 4800 2    60   ~ 0
SPI_SEL
Text Label 2650 2200 2    60   ~ 0
SPI_SEL
$Comp
L +5V #PWR023
U 1 1 5175D2AF
P 5000 5100
F 0 "#PWR023" H 5000 5190 20  0001 C CNN
F 1 "+5V" H 5000 5190 30  0000 C CNN
	1    5000 5100
	-1   0    0    -1  
$EndComp
$Comp
L GND #PWR024
U 1 1 5175D2A4
P 5350 5300
F 0 "#PWR024" H 5350 5300 30  0001 C CNN
F 1 "GND" H 5350 5230 30  0001 C CNN
	1    5350 5300
	-1   0    0    -1  
$EndComp
$Comp
L CONN_6 P11
U 1 1 5175D27C
P 5700 4950
F 0 "P11" V 5650 4950 60  0000 C CNN
F 1 "SPI_EXP" V 5750 4950 60  0000 C CNN
	1    5700 4950
	1    0    0    -1  
$EndComp
Text Label 6200 2100 2    60   ~ 0
TXD2
Text Label 6200 2000 2    60   ~ 0
RXD2
Text Label 6200 1900 2    60   ~ 0
TXD1
Text Label 6200 1800 2    60   ~ 0
RXD1
Text HLabel 3450 4350 2    60   Input ~ 0
ARD_~BUSMASTER
$Comp
L GND #PWR025
U 1 1 5174ADB7
P 5900 2900
F 0 "#PWR025" H 5900 2900 30  0001 C CNN
F 1 "GND" H 5900 2830 30  0001 C CNN
	1    5900 2900
	-1   0    0    -1  
$EndComp
$Comp
L CONN_4 P10
U 1 1 5174AD98
P 6250 2650
F 0 "P10" V 6200 2650 50  0000 C CNN
F 1 "LCD" V 6300 2650 50  0000 C CNN
	1    6250 2650
	1    0    0    -1  
$EndComp
NoConn ~ 2900 1600
NoConn ~ 2900 1700
NoConn ~ 2900 1800
NoConn ~ 2900 1900
NoConn ~ 2900 2000
NoConn ~ 2900 2100
NoConn ~ 2650 4950
Text Label 3700 4950 0    60   ~ 0
SCK
Text Label 2150 4850 2    60   ~ 0
MOSI
Text Label 3700 4850 0    60   ~ 0
MISO
Text Label 5900 1700 2    60   ~ 0
SCA
Text Label 5900 1600 2    60   ~ 0
SCL
$Comp
L CONN_6 P9
U 1 1 5171F854
P 6550 1850
F 0 "P9" V 6500 1850 60  0000 C CNN
F 1 "ARDUINO_COMM" V 6600 1850 60  0000 C CNN
	1    6550 1850
	1    0    0    -1  
$EndComp
$Comp
L CONN_8 P8
U 1 1 5171F816
P 3250 1950
F 0 "P8" V 3200 1950 60  0000 C CNN
F 1 "ARDUINO_ADCH" V 3300 1950 60  0000 C CNN
	1    3250 1950
	1    0    0    -1  
$EndComp
Text HLabel 2900 2300 0    60   Input ~ 0
ARD_SEL
Text HLabel 2650 4750 0    60   Output ~ 0
ARD_EEN
$Comp
L +5V #PWR026
U 1 1 516FEC4E
P 4000 3150
F 0 "#PWR026" H 4000 3240 20  0001 C CNN
F 1 "+5V" H 4000 3240 30  0000 C CNN
	1    4000 3150
	-1   0    0    -1  
$EndComp
$Comp
L DIODESCH D9
U 1 1 516FEC3D
P 3650 3200
F 0 "D9" H 3650 3300 40  0000 C CNN
F 1 "DIODESCH" H 3650 3100 40  0000 C CNN
	1    3650 3200
	1    0    0    -1  
$EndComp
$Comp
L R R10
U 1 1 516970CB
P 4000 3450
F 0 "R10" V 4080 3450 50  0000 C CNN
F 1 "1K" V 4000 3450 50  0000 C CNN
	1    4000 3450
	-1   0    0    -1  
$EndComp
$Comp
L PWR_FLAG #FLG027
U 1 1 5158EE04
P 2500 5250
F 0 "#FLG027" H 2500 5345 30  0001 C CNN
F 1 "PWR_FLAG" H 2500 5430 30  0000 C CNN
	1    2500 5250
	1    0    0    -1  
$EndComp
Text HLabel 2550 3200 0    60   Output ~ 0
A_POWER
Text HLabel 4050 3850 2    60   BiDi ~ 0
ARD_RW
Text HLabel 3450 4250 2    60   Output ~ 0
BUSREQ
Text HLabel 3450 3950 2    60   BiDi ~ 0
A13
Text HLabel 2650 3850 0    60   BiDi ~ 0
A14
Text HLabel 2650 3950 0    60   BiDi ~ 0
A12
Text HLabel 3450 4050 2    60   BiDi ~ 0
A11
Text HLabel 2650 4050 0    60   BiDi ~ 0
A10
Text HLabel 3450 4150 2    60   BiDi ~ 0
A9
Text HLabel 2650 4150 0    60   BiDi ~ 0
A8
Text HLabel 2650 3750 0    60   BiDi ~ 0
A7
Text HLabel 3450 3750 2    60   BiDi ~ 0
A6
Text HLabel 2650 3650 0    60   BiDi ~ 0
A5
Text HLabel 3450 3650 2    60   BiDi ~ 0
A4
Text HLabel 2650 3550 0    60   BiDi ~ 0
A3
Text HLabel 3450 3550 2    60   BiDi ~ 0
A2
Text HLabel 2650 3450 0    60   BiDi ~ 0
A1
Text HLabel 3450 3450 2    60   BiDi ~ 0
A0
Text HLabel 2650 4350 0    60   BiDi ~ 0
D7
Text HLabel 3450 4450 2    60   BiDi ~ 0
D6
Text HLabel 2650 4450 0    60   BiDi ~ 0
D5
Text HLabel 3450 4550 2    60   BiDi ~ 0
D4
Text HLabel 2650 4550 0    60   BiDi ~ 0
D3
Text HLabel 3450 4650 2    60   BiDi ~ 0
D2
Text HLabel 2650 4650 0    60   BiDi ~ 0
D1
Text HLabel 3450 4750 2    60   BiDi ~ 0
D0
Text HLabel 2650 4250 0    60   Input ~ 0
A_~BUSEN
$Comp
L CONN_18X2 P3
U 1 1 5156E4FF
P 3050 4200
F 0 "P3" H 3050 5250 60  0000 C CNN
F 1 "ARDUINO_MEGA_D" V 3050 4150 50  0000 C CNN
	1    3050 4200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR028
U 1 1 5156E4FE
P 3050 5300
F 0 "#PWR028" H 3050 5300 30  0001 C CNN
F 1 "GND" H 3050 5230 30  0001 C CNN
	1    3050 5300
	-1   0    0    -1  
$EndComp
$EndSCHEMATC
