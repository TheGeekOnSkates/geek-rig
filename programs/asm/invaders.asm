; ALIEN INVASION
; ==========================================================================================================================================================
; MEMORY MAP
; 
; $00-$01		Position of the player's ship
; 
; ==========================================================================================================================================================
	ORG $05CC
	PROCESSOR 6502
	include "geekrig4000.asm"

GAME:
	LDA #160
	LDX #0
DRAW_GROUND:
	STA $0598,X
	INX
	CPX #41
	BNE DRAW_GROUND
; Set up the pointer to the player's position
	LDA #131
	STA $00
	LDA #05
	STA $01
MAIN_LOOP:
	JSR READ_KEYS
	JSR DRAW_PLAYER
	JMP MAIN_LOOP

READ_KEYS:
	LDA KEY
	STA SCREEN 		; testing - doesn't seem to be working
					; Same bug as I ran into in my C program
	CMP #KEY_A
	BEQ MOVE_LEFT
	CMP #KEY_D
	BEQ MOVE_RIGHT
	RTS

MOVE_LEFT:
	LDA $00		; LSB of player position
	CMP #112
	BEQ DONE_MOVING_LEFT
	DEC $00
DONE_MOVING_LEFT:
	RTS

MOVE_RIGHT:
	LDA $00
	CMP #140
	BEQ DONE_MOVING_LEFT
	INC $00
DONE_MOVING_RIGHT:
	RTS

DRAW_PLAYER:
	LDY #0
	LDA #$E9
	STA ($00),Y
	INY
	LDA #$DF
	STA ($00),Y
	RTS
