	ORG $05CC
	PROCESSOR 6502
	include "geekrig4000.asm"

MAIN:
	LDA COLUMNS
	JSR PRINT_COLUMNS
	LDA ROWS
	JSR PRINT_ROWS
	JMP MAIN

PRINT_COLUMNS:
	LDX #0				; A = columns, X = 0
	STX $00				; Now memory address 0 = 0
	JSR DIVIDE_BY_10	; Divide A by 10; store the 10s place in $00 and the ones in $01
	LDA $00				; Load the 10s place
	ADC #48				; So we have characters starting at 48 ('0') not 0 ('@')
	STA SCREEN			; First char on screen = 10s place
	LDA $01				; Load 1s place
	ADC #48				; Again, add 48 to get the right PETSCII character
	STA SCREEN + 1		; Now the top left corner shows how many columns our terminal has
	LDA #<SCREEN + 3	; A = least significant byte (LSB) of SCREEN + 3
	STA $02				; Memory address #2 = A
	LDA #>SCREEN + 4	; A = most significant byte (MSB) of SCREEN + 3
	STA $03				; Memory address #3 = A, so now memory address #2 = pointer to SCREEN + 3
	LDA #<WORD_COLUMNS	; Same idea - make a pointer to WORD_COLUMNS at memory address #4
	STA $04				; Address $04 = LSB of WORD_COLUMNS
	LDA #>WORD_COLUMNS	; Same deal
	STA $05				; Address $05 = MSB of WORD_COLUMNS
	LDX $00				; Start X at 0, cuz PRINT uses it on a loop
	JSR PRINT			; Print the word "COLUMNS" at SCREEN + 3
	RTS					; At least... that was the idea. :)

; Exactly the same as PRINT_COLUMNS except:
;	1. A contains the number for rows, not columns
; 	2. I'm printing it on the second row
; 	3. And since PRINT isn't working yet, I'm not trying to print the word "rows"
PRINT_ROWS:
	LDX #0
	STX $00
	JSR DIVIDE_BY_10
	LDA $00
	ADC #48
	STA SCREEN + 40
	LDA $01
	ADC #48
	STA SCREEN + 41
	LDA #<SCREEN + 3
	STA $02
	LDA #>SCREEN + 4
	RTS

; Divides the A-register by 10, storing the 10s place at $00 and the 1s place at $01
DIVIDE_BY_10:
	CLC					; Clear the carry flag
	CMP #10				; This line and the next basically mean,
	BCC DONE_DIVIDING	; "if (A < 10) goto DONE_DIVIDING;"
	SBC #10				; if it gets here, now A -= 10;
	INC $00				; Memory address 0 ++
	JMP DIVIDE_BY_10	; And call DIVIDE_BY_10 again
DONE_DIVIDING:
	STA $01				; Now A is a number < 10
	RTS					; So store it in memory address 1 and return

PRINT:
	LDA ($04,X)
	BEQ DONE_PRINTING
	STA ($02,X)
	INX
	JMP PRINT
DONE_PRINTING:
	RTS

WORD_COLUMNS:
	BYTE $03, $0F, $0C, $15, $0D, $0E, $13, $00

WORD_ROWS:
	BYTE $12, $0f, $17, $13, $00
