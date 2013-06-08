EESchema Schematic File Version 2  date 5/4/2013 9:22:42 PM
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
Sheet 3 4
Title "Color Computer Bus Interface"
Date "5 may 2013"
Rev "1.3"
Comp "Bexkat Systems LLC 2013"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Wire Wire Line
	2950 3250 2950 3200
Wire Wire Line
	2950 3200 2900 3200
Wire Wire Line
	10050 6350 5550 6350
Wire Wire Line
	7450 4450 7450 4350
Connection ~ 8050 4350
Wire Wire Line
	8050 4350 8050 4500
Wire Wire Line
	8100 4350 8100 4300
Wire Wire Line
	8350 4350 7850 4350
Connection ~ 8100 4350
Wire Wire Line
	8150 4500 8150 4350
Connection ~ 8150 4350
Wire Wire Line
	8750 4350 8750 4450
Wire Wire Line
	7350 1450 7350 1350
Connection ~ 7950 1350
Wire Wire Line
	7950 1350 7950 1500
Wire Wire Line
	8000 1350 8000 1300
Wire Wire Line
	8250 1350 7750 1350
Connection ~ 8000 1350
Wire Wire Line
	8050 1500 8050 1350
Connection ~ 8050 1350
Wire Wire Line
	8650 1350 8650 1450
Wire Wire Line
	3650 3600 3650 3500
Connection ~ 4250 3500
Wire Wire Line
	4250 3500 4250 3650
Wire Wire Line
	4300 3500 4300 3450
Wire Wire Line
	4550 3500 4050 3500
Connection ~ 4300 3500
Wire Wire Line
	4350 3650 4350 3500
Connection ~ 4350 3500
Wire Wire Line
	4950 3500 4950 3600
Wire Wire Line
	4900 1500 4900 1600
Connection ~ 4300 1500
Wire Wire Line
	4300 1650 4300 1500
Connection ~ 4250 1500
Wire Wire Line
	4500 1500 4000 1500
Connection ~ 2250 2500
Wire Wire Line
	9200 6350 9200 5650
Connection ~ 5550 4800
Wire Wire Line
	5550 6350 5550 2800
Wire Wire Line
	5550 4800 4900 4800
Wire Wire Line
	5550 2800 4850 2800
Wire Wire Line
	1600 2500 2250 2500
Wire Wire Line
	1950 5050 1950 4900
Wire Wire Line
	1950 4900 1600 4900
Wire Wire Line
	1950 5000 1600 5000
Connection ~ 1950 5000
Wire Wire Line
	2650 2500 2650 2450
Wire Wire Line
	7500 5650 7500 5700
Wire Wire Line
	3700 4800 3700 4850
Wire Wire Line
	3650 2850 3650 2800
Wire Wire Line
	2250 2500 2250 2700
Wire Wire Line
	9200 5650 8700 5650
Connection ~ 9200 6350
Wire Wire Line
	4250 1500 4250 1450
Wire Wire Line
	4200 1500 4200 1650
Connection ~ 4200 1500
Wire Wire Line
	3600 1600 3600 1500
Wire Wire Line
	8700 5250 9050 5250
Wire Wire Line
	2250 2700 2750 2700
Connection ~ 2500 2700
$Comp
L GND #PWR024
U 1 1 517C6082
P 2950 3250
F 0 "#PWR024" H 2950 3250 30  0001 C CNN
F 1 "GND" H 2950 3180 30  0001 C CNN
	1    2950 3250
	1    0    0    -1  
$EndComp
$Comp
L LED D3
U 1 1 517C6080
P 2700 3200
F 0 "D3" H 2700 3300 50  0000 C CNN
F 1 "C_PWR" H 2700 3100 50  0000 C CNN
	1    2700 3200
	1    0    0    -1  
$EndComp
$Comp
L R R4
U 1 1 517C607E
P 2500 2950
F 0 "R4" V 2580 2950 50  0000 C CNN
F 1 "330" V 2500 2950 50  0000 C CNN
	1    2500 2950
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR025
U 1 1 517C5438
P 2250 3200
F 0 "#PWR025" H 2250 3200 30  0001 C CNN
F 1 "GND" H 2250 3130 30  0001 C CNN
	1    2250 3200
	1    0    0    -1  
$EndComp
$Comp
L R R3
U 1 1 517C5423
P 2250 2950
F 0 "R3" V 2330 2950 50  0000 C CNN
F 1 "47K" V 2250 2950 50  0000 C CNN
	1    2250 2950
	-1   0    0    1   
$EndComp
NoConn ~ 4900 4700
NoConn ~ 3700 4700
NoConn ~ 1600 5400
Text Label 9050 5250 0    60   ~ 0
C_~SLENB
Text Label 1600 5600 0    60   ~ 0
C_~SLENB
$Comp
L +3.3V #PWR026
U 1 1 5172867B
P 8100 4300
F 0 "#PWR026" H 8100 4260 30  0001 C CNN
F 1 "+3.3V" H 8100 4410 30  0000 C CNN
	1    8100 4300
	1    0    0    -1  
$EndComp
$Comp
L C C14
U 1 1 5172867A
P 7650 4350
F 0 "C14" H 7700 4450 50  0000 L CNN
F 1 ".1uF" H 7700 4250 50  0000 L CNN
	1    7650 4350
	0    -1   -1   0   
$EndComp
$Comp
L C C16
U 1 1 51728679
P 8550 4350
F 0 "C16" H 8600 4450 50  0000 L CNN
F 1 ".1uF" H 8600 4250 50  0000 L CNN
	1    8550 4350
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR027
U 1 1 51728678
P 7450 4450
F 0 "#PWR027" H 7450 4450 30  0001 C CNN
F 1 "GND" H 7450 4380 30  0001 C CNN
	1    7450 4450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR028
U 1 1 51728677
P 8750 4450
F 0 "#PWR028" H 8750 4450 30  0001 C CNN
F 1 "GND" H 8750 4380 30  0001 C CNN
	1    8750 4450
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR029
U 1 1 51728668
P 8000 1300
F 0 "#PWR029" H 8000 1260 30  0001 C CNN
F 1 "+3.3V" H 8000 1410 30  0000 C CNN
	1    8000 1300
	1    0    0    -1  
$EndComp
$Comp
L C C13
U 1 1 51728667
P 7550 1350
F 0 "C13" H 7600 1450 50  0000 L CNN
F 1 ".1uF" H 7600 1250 50  0000 L CNN
	1    7550 1350
	0    -1   -1   0   
$EndComp
$Comp
L C C15
U 1 1 51728666
P 8450 1350
F 0 "C15" H 8500 1450 50  0000 L CNN
F 1 ".1uF" H 8500 1250 50  0000 L CNN
	1    8450 1350
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR030
U 1 1 51728665
P 7350 1450
F 0 "#PWR030" H 7350 1450 30  0001 C CNN
F 1 "GND" H 7350 1380 30  0001 C CNN
	1    7350 1450
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR031
U 1 1 51728664
P 8650 1450
F 0 "#PWR031" H 8650 1450 30  0001 C CNN
F 1 "GND" H 8650 1380 30  0001 C CNN
	1    8650 1450
	1    0    0    -1  
$EndComp
$Comp
L 74LVC164245 U2
U 1 1 5156E80A
P 8000 2200
F 0 "U2" H 8350 2750 60  0000 C CNN
F 1 "74LVC164245" H 7950 1600 60  0000 C CNN
	1    8000 2200
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR032
U 1 1 51728643
P 4300 3450
F 0 "#PWR032" H 4300 3410 30  0001 C CNN
F 1 "+3.3V" H 4300 3560 30  0000 C CNN
	1    4300 3450
	1    0    0    -1  
$EndComp
$Comp
L C C10
U 1 1 51728642
P 3850 3500
F 0 "C10" H 3900 3600 50  0000 L CNN
F 1 ".1uF" H 3900 3400 50  0000 L CNN
	1    3850 3500
	0    -1   -1   0   
$EndComp
$Comp
L C C12
U 1 1 51728641
P 4750 3500
F 0 "C12" H 4800 3600 50  0000 L CNN
F 1 ".1uF" H 4800 3400 50  0000 L CNN
	1    4750 3500
	0    -1   -1   0   
$EndComp
$Comp
L GND #PWR033
U 1 1 51728640
P 3650 3600
F 0 "#PWR033" H 3650 3600 30  0001 C CNN
F 1 "GND" H 3650 3530 30  0001 C CNN
	1    3650 3600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR034
U 1 1 5172863F
P 4950 3600
F 0 "#PWR034" H 4950 3600 30  0001 C CNN
F 1 "GND" H 4950 3530 30  0001 C CNN
	1    4950 3600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR035
U 1 1 5172861F
P 4900 1600
F 0 "#PWR035" H 4900 1600 30  0001 C CNN
F 1 "GND" H 4900 1530 30  0001 C CNN
	1    4900 1600
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR036
U 1 1 5172861C
P 3600 1600
F 0 "#PWR036" H 3600 1600 30  0001 C CNN
F 1 "GND" H 3600 1530 30  0001 C CNN
	1    3600 1600
	1    0    0    -1  
$EndComp
$Comp
L 74LVC164245 U2
U 2 1 5156E809
P 4250 2350
F 0 "U2" H 4600 2900 60  0000 C CNN
F 1 "74LVC164245" H 4250 1750 60  0000 C CNN
	2    4250 2350
	1    0    0    -1  
$EndComp
$Comp
L C C11
U 1 1 517285EA
P 4700 1500
F 0 "C11" H 4750 1600 50  0000 L CNN
F 1 ".1uF" H 4750 1400 50  0000 L CNN
	1    4700 1500
	0    -1   -1   0   
$EndComp
$Comp
L C C6
U 1 1 517285E7
P 3800 1500
F 0 "C6" H 3850 1600 50  0000 L CNN
F 1 ".1uF" H 3850 1400 50  0000 L CNN
	1    3800 1500
	0    -1   -1   0   
$EndComp
Text HLabel 7500 5250 0    60   Input ~ 0
~SLENB
Text HLabel 8600 2650 2    60   Input ~ 0
C_~DATAEN
$Comp
L +3.3V #PWR037
U 1 1 5158F1C7
P 4250 1450
F 0 "#PWR037" H 4250 1410 30  0001 C CNN
F 1 "+3.3V" H 4250 1560 30  0000 C CNN
	1    4250 1450
	1    0    0    -1  
$EndComp
$Comp
L +5V #PWR038
U 1 1 5158F1A5
P 2650 2450
F 0 "#PWR038" H 2650 2540 20  0001 C CNN
F 1 "+5V" H 2650 2540 30  0000 C CNN
	1    2650 2450
	1    0    0    -1  
$EndComp
Text HLabel 8600 2550 2    60   BiDi ~ 0
D7
Text HLabel 8600 2450 2    60   BiDi ~ 0
D6
Text HLabel 8600 2350 2    60   BiDi ~ 0
D5
Text HLabel 8600 2250 2    60   BiDi ~ 0
D4
Text HLabel 8600 2150 2    60   BiDi ~ 0
D3
Text HLabel 8600 2050 2    60   BiDi ~ 0
D2
Text HLabel 8600 1950 2    60   BiDi ~ 0
D1
Text HLabel 8600 1850 2    60   BiDi ~ 0
D0
Text HLabel 8700 5150 2    60   Output ~ 0
~SCS
Text HLabel 8700 5050 2    60   Output ~ 0
~CTS
Text HLabel 8700 4950 2    60   Output ~ 0
COCO_RW
Text HLabel 8700 4850 2    60   Output ~ 0
E
Text HLabel 10050 6350 2    60   Input ~ 0
~C_BUSEN
Text HLabel 4900 4600 2    60   Output ~ 0
A14
Text HLabel 4900 4500 2    60   Output ~ 0
A13
Text HLabel 4900 4400 2    60   Output ~ 0
A12
Text HLabel 4900 4300 2    60   Output ~ 0
A11
Text HLabel 4900 4200 2    60   Output ~ 0
A10
Text HLabel 4900 4100 2    60   Output ~ 0
A9
Text HLabel 4900 4000 2    60   Output ~ 0
A8
Text HLabel 4850 2700 2    60   Output ~ 0
A7
Text HLabel 4850 2600 2    60   Output ~ 0
A6
Text HLabel 4850 2500 2    60   Output ~ 0
A5
Text HLabel 4850 2400 2    60   Output ~ 0
A4
Text HLabel 4850 2300 2    60   Output ~ 0
A3
Text HLabel 4850 2200 2    60   Output ~ 0
A2
Text HLabel 4850 2100 2    60   Output ~ 0
A1
Text HLabel 4850 2000 2    60   Output ~ 0
A0
Text HLabel 2750 2700 2    60   Output ~ 0
C_POWER
Text Label 7400 1850 2    60   ~ 0
C_D0
Text Label 7400 1950 2    60   ~ 0
C_D1
Text Label 7400 2050 2    60   ~ 0
C_D2
Text Label 7400 2150 2    60   ~ 0
C_D3
Text Label 7400 2250 2    60   ~ 0
C_D4
Text Label 7400 2350 2    60   ~ 0
C_D5
Text Label 7400 2450 2    60   ~ 0
C_D6
Text Label 7400 2550 2    60   ~ 0
C_D7
$Comp
L GND #PWR039
U 1 1 5156E804
P 3650 2850
F 0 "#PWR039" H 3650 2850 30  0001 C CNN
F 1 "GND" H 3650 2780 30  0001 C CNN
	1    3650 2850
	1    0    0    -1  
$EndComp
Text Label 3650 2000 2    60   ~ 0
C_A0
Text Label 3650 2100 2    60   ~ 0
C_A1
Text Label 3650 2200 2    60   ~ 0
C_A2
Text Label 3650 2300 2    60   ~ 0
C_A3
Text Label 3650 2400 2    60   ~ 0
C_A4
Text Label 3650 2500 2    60   ~ 0
C_A5
Text Label 3650 2600 2    60   ~ 0
C_A6
Text Label 3650 2700 2    60   ~ 0
C_A7
Text Label 7400 2650 2    60   ~ 0
C_R/~W
$Comp
L 74LVC164245 U3
U 1 1 5156E7F0
P 4300 4350
F 0 "U3" H 4650 4900 60  0000 C CNN
F 1 "74LVC164245" H 4200 3750 60  0000 C CNN
	1    4300 4350
	1    0    0    -1  
$EndComp
$Comp
L 74LVC164245 U3
U 2 1 5156E7EF
P 8100 5200
F 0 "U3" H 8250 5750 60  0000 C CNN
F 1 "74LVC164245" H 8000 4600 60  0000 C CNN
	2    8100 5200
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR040
U 1 1 5156E7EC
P 3700 4850
F 0 "#PWR040" H 3700 4850 30  0001 C CNN
F 1 "GND" H 3700 4780 30  0001 C CNN
	1    3700 4850
	1    0    0    -1  
$EndComp
Text Label 3700 4000 2    60   ~ 0
C_A8
Text Label 3700 4100 2    60   ~ 0
C_A9
Text Label 3700 4200 2    60   ~ 0
C_A10
Text Label 3700 4300 2    60   ~ 0
C_A11
Text Label 3700 4400 2    60   ~ 0
C_A12
Text Label 3700 4500 2    60   ~ 0
C_A13
Text Label 3700 4600 2    60   ~ 0
C_A14
$Comp
L GND #PWR041
U 1 1 5156E7E9
P 7500 5700
F 0 "#PWR041" H 7500 5700 30  0001 C CNN
F 1 "GND" H 7500 5630 30  0001 C CNN
	1    7500 5700
	1    0    0    -1  
$EndComp
Text Label 7500 4850 2    60   ~ 0
C_ECLK
Text Label 7500 4950 2    60   ~ 0
C_R/~W
Text Label 7500 5050 2    60   ~ 0
C_~CTS
Text Label 7500 5150 2    60   ~ 0
C_~SCS
NoConn ~ 7500 5350
NoConn ~ 7500 5450
NoConn ~ 7500 5550
NoConn ~ 8700 5350
NoConn ~ 8700 5450
NoConn ~ 8700 5550
Text Label 4850 7300 2    60   ~ 0
C_QCLK
Text Label 5450 7300 0    60   ~ 0
C_~CART
$Comp
L JUMPER JP1
U 1 1 5156E7BD
P 5150 7300
F 0 "JP1" H 5150 7450 60  0000 C CNN
F 1 "CART_BOOT" H 5150 7220 40  0000 C CNN
	1    5150 7300
	1    0    0    -1  
$EndComp
$Comp
L COCOBUS P1
U 1 1 5156E75F
P 1300 3650
F 0 "P1" H 1200 5750 60  0000 C CNN
F 1 "COCOBUS" H 1250 1550 60  0000 C CNN
	1    1300 3650
	1    0    0    -1  
$EndComp
$Comp
L GND #PWR042
U 1 1 5156E75E
P 1950 5050
F 0 "#PWR042" H 1950 5050 30  0001 C CNN
F 1 "GND" H 1950 4980 30  0001 C CNN
	1    1950 5050
	1    0    0    -1  
$EndComp
Text Label 1600 2600 0    60   ~ 0
C_D0
Text Label 1600 2700 0    60   ~ 0
C_D1
Text Label 1600 2800 0    60   ~ 0
C_D2
Text Label 1600 2900 0    60   ~ 0
C_D3
Text Label 1600 3000 0    60   ~ 0
C_D4
Text Label 1600 3100 0    60   ~ 0
C_D5
Text Label 1600 3200 0    60   ~ 0
C_D6
Text Label 1600 3300 0    60   ~ 0
C_D7
Text Label 1600 3500 0    60   ~ 0
C_A0
Text Label 1600 3600 0    60   ~ 0
C_A1
Text Label 1600 3700 0    60   ~ 0
C_A2
Text Label 1600 3800 0    60   ~ 0
C_A3
Text Label 1600 3900 0    60   ~ 0
C_A4
Text Label 1600 4000 0    60   ~ 0
C_A5
Text Label 1600 4100 0    60   ~ 0
C_A6
Text Label 1600 4200 0    60   ~ 0
C_A7
Text Label 1600 4300 0    60   ~ 0
C_A8
Text Label 1600 4400 0    60   ~ 0
C_A9
Text Label 1600 4500 0    60   ~ 0
C_A10
Text Label 1600 4600 0    60   ~ 0
C_A11
Text Label 1600 4700 0    60   ~ 0
C_A12
Text Label 1600 2200 0    60   ~ 0
C_ECLK
Text Label 1600 2400 0    60   ~ 0
C_~CART
Text Label 1600 3400 0    60   ~ 0
C_R/~W
Text Label 1600 4800 0    60   ~ 0
C_~CTS
Text Label 1600 5200 0    60   ~ 0
C_~SCS
Text Label 1600 5300 0    60   ~ 0
C_A13
Text Label 1600 5400 0    60   ~ 0
C_A14
$Comp
L DIODESCH D1
U 1 1 5156E75D
P 2450 2500
F 0 "D1" H 2450 2600 40  0000 C CNN
F 1 "DIODE" H 2450 2400 40  0000 C CNN
	1    2450 2500
	1    0    0    -1  
$EndComp
NoConn ~ 1600 5100
Text Label 1600 2300 0    60   ~ 0
C_QCLK
NoConn ~ 1600 1900
NoConn ~ 1600 2000
NoConn ~ 1600 2100
$EndSCHEMATC
