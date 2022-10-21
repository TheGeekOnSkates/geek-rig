z	include "geekrig4000.asm"
	ORG $05CA
	PROCESSOR 6502

MAIN:
	; Prints the word "GEEK" on the screen
	LDA #7
	STA MM_SCREEN
	LDA #5
	STA MM_SCREEN + 1
	STA MM_SCREEN + 2
	LDA #11
	STA MM_SCREEN + 3

	; Check if the lowercase charset is turned on
	LDA MM_DISK_STATUS
	AND #128
	BEQ ON

	; If it gets here, it's on, so turn it off
	LDA #0
	STA MM_DISK_STATUS
	JMP MAIN

ON:
	LDA #128
	STA MM_DISK_STATUS
	JMP MAIN
