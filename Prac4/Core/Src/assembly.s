/*
 * assembly.s
 *
 */
 
 @ DO NOT EDIT
	.syntax unified
    .text
    .global ASM_Main
    .thumb_func

@ DO NOT EDIT
vectors:
	.word 0x20002000
	.word ASM_Main + 1

@ DO NOT EDIT label ASM_Main
ASM_Main:

	@ Some code is given below for you to start with
	LDR R0, RCC_BASE  		@ Enable clock for GPIOA and B by setting bit 17 and 18 in RCC_AHBENR
	LDR R1, [R0, #0x14]
	LDR R2, AHBENR_GPIOAB	@ AHBENR_GPIOAB is defined under LITERALS at the end of the code
	ORRS R1, R1, R2
	STR R1, [R0, #0x14]

	LDR R0, GPIOA_BASE		@ Enable pull-up resistors for pushbuttons
	MOVS R1, #0b01010101
	STR R1, [R0, #0x0C]
	LDR R1, GPIOB_BASE  	@ Set pins connected to LEDs to outputs
	LDR R2, MODER_OUTPUT
	STR R2, [R1, #0]
	MOVS R2, #0         	@ NOTE: R2 will be dedicated to holding the value on the LEDs

@ TODO: Add code, labels and logic for button checks and LED patterns

main_loop:
    @ Check SW2 (PA2) - Set pattern to 0xAA if pressed
    LDR R3, [R0]
    LSLS R3, R3, #29
    BCS set_pattern_aa
    B check_sw3
set_pattern_aa:
    MOVS R2, #0xAA
    B write_leds

check_sw3:
    @ Check SW3 (PA3) - Freeze pattern if pressed
    LDR R3, [R0]
    LSLS R3, R3, #28
    BCS write_leds         @ If pressed, skip increment and delay

    @ Check SW0 (PA0) - Increment by 2 if pressed
    LDR R3, [R0]
    LSLS R3, R3, #31
    BCS increment_by_two
    ADDS R2, R2, #1        @ Default increment by 1
    B check_sw1
increment_by_two:
    ADDS R2, R2, #2

    @ Ensure the counter wraps around at 256
    UXTB R2, R2            @ Unsigned extend byte (keep only lower 8 bits)

check_sw1:
    @ Check SW1 (PA1) - Change delay if pressed
    LDR R3, [R0]
    LSLS R3, R3, #30
    BCS use_short_delay
    LDR R4, LONG_DELAY_CNT
    B delay_loop
use_short_delay:
    LDR R4, SHORT_DELAY_CNT

    @ Delay loop
delay_loop:
    SUBS R4, R4, #1
    BNE delay_loop

write_leds:
    STR R2, [R1, #0x14]
    B main_loop

@ LITERALS; DO NOT EDIT
	.align
RCC_BASE: 			.word 0x40021000
AHBENR_GPIOAB: 		.word 0b1100000000000000000
GPIOA_BASE:  		.word 0x48000000
GPIOB_BASE:  		.word 0x48000400
MODER_OUTPUT: 		.word 0x5555

@ TODO: Add your own values for these delays
LONG_DELAY_CNT: 	.word 300000    @ Approximately 0.7 seconds
SHORT_DELAY_CNT: 	.word 128571    @ Approximately 0.3 seconds
