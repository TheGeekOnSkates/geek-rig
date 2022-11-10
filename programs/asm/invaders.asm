; ALIEN INVASION
; ==========================================================================================================================================================
; POINTERS
; 
; $00-$01		Position of the player's ship
; $02-$03		Player's first laser
; $04-$05		Player's second laser
; $06-$??		Ships and enemy lasers
; $FF			Player's score
; ==========================================================================================================================================================
	ORG $05CC
	PROCESSOR 6502
	include "geekrig4000/memory-map.asm"

GAME:
	LDA #232
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
	JSR UPDATE_LASERS
	JMP MAIN_LOOP

READ_KEYS:
	LDA KEY
	LDX #0
	STX KEY
	CMP #KEY_A
	BEQ MOVE_LEFT
	CMP #KEY_D
	BEQ MOVE_RIGHT
	CMP #KEY_SPACE
	BEQ SHOOT
	RTS

MOVE_LEFT:
	LDA $00		; LSB of player position
	CMP #112
	BEQ DONE_MOVING_LEFT
	JSR PLAYER_SPACE_LEFT
	DEC $00
DONE_MOVING_LEFT:
	RTS

MOVE_RIGHT:
	LDA $00
	CMP #150
	BEQ DONE_MOVING_RIGHT
	JSR PLAYER_SPACE_RIGHT
	INC $00
DONE_MOVING_RIGHT:
	RTS

DRAW_PLAYER:
	LDY #0
	LDA #PETSCII_TRIANGLE_UP_RIGHT
	STA ($00),Y
	INY
	LDA #PETSCII_TRIANGLE_UP_LEFT
	STA ($00),Y
	RTS

; The player is moving left, so we need to delete the bit of ship
; to the right (so LDA space char, STA ship position + 1)
PLAYER_SPACE_LEFT:
	LDY #1
	LDA #$20
	STA ($00),Y
	RTS

; Opposite behavior - player is moving right, so clear the char on the left
PLAYER_SPACE_RIGHT:
	LDY #0
	LDA #$20
	STA ($00),Y
	RTS

SHOOT:
	LDA $02
	BEQ SHOOT_LASER_1
	LDA $04
	BEQ SHOOT_LASER_2
	JMP DONE_SHOOTING
SHOOT_LASER_1:
	LDA $00		; LSB of player position
	SBC #40		; - 40 gives us where to put the laser
	STA $00		; Temporarily store it in $00
	LDA #$65 	; Laser graphic - draw just above the right char of the ship
	STA ($00),Y	; Draw the laser (I think drawing will eventually be separate)
	LDA $00		; Restore the pointer back to where the player is
	STA $02		; And copy the pointer for laser #1 to $02-03
	ADC #39
	STA $00
	LDA $01
	STA $03
	RTS
SHOOT_LASER_2:
	LDA $00		; LSB of player position
	SBC #40		; - 40 gives us where to put the laser
	STA $00		; Temporarily store it in $00
	LDA #$65 	; Laser graphic - draw just above the right char of the ship
	STA ($00),Y	; Draw the laser (I think drawing will eventually be separate)
	LDA $00		; Restore the pointer back to where the player is
	STA $04		; And copy the pointer for laser #1 to $04-$05
	ADC #39
	STA $00
	LDA $01
	STA $05
DONE_SHOOTING:
	RTS

UPDATE_LASERS:
	; Get the laser's position minus COLUMNS
	LDA $02
	STA MATH_N1_LO
	LDA $03
	STA MATH_N1_HI
	LDA COLUMNS
	STA MATH_N2_LO
	LDA #0
	STA MATH_N2_HI
	JSR SUBTRACT
	LDA MATH_RESULT_LO
	STA $02
	LDA MATH_RESULT_HI
	STA $03
DONE_UPDATING_LASERS:
	RTS


; =========================================================================
; ADDITIONAL DEPENDENCIES (included hear because putting at the top
; makes it the first thing to run, which of course breaks stuff :D)
; =========================================================================

	include "geekrig4000/math/subtract.asm"
