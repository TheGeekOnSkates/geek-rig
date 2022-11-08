	ORG $05CC
	PROCESSOR 6502
	include "geekrig4000.asm"

MAIN:
	JSR TITLE_SCREEN
	JSR GAME_SCREEN
	JMP MAIN

TITLE_POINTERS:
	LDY #14
	JSR GET_CENTER
	LDA #$02			; Now $00 = $0C (13) and $01 = 2 ($02).
	STA $01				; Together they point to $020C).
						; If I've done this right, then we can use this
						; crazy formula to print the title centered

	STA $03				; Now we're doing the same for $02-03, except
	LDA $00				; that we're adding a row; so now address $03
	ADC COLUMNS			; is the value at $00 + COLUMNS (max of ~53), and $04 is 2,
	STA $02				; building another pointer I can use to print line 2
	
	LDY #0				; Needed for the loop below :)
	RTS					; And return to TITLE_SCREEN or CLEAR_TITLE

TITLE_SCREEN:
	JSR TITLE_POINTERS
TITLE_SCREEN_LOOP:
	LDA TITLE_SCREEN_LINE_1,Y
	STA ($00),Y
	LDA TITLE_SCREEN_LINE_2,Y
	STA ($02),Y
	INY
	CPY #14
	BNE TITLE_SCREEN_LOOP
PRESS_X_OR_O:
	LDA KEY
	CMP #KEY_X
	BEQ READY_TO_START
	CMP #KEY_O
	BEQ READY_TO_START
	JMP PRESS_X_OR_O
READY_TO_START:
	STA $FF
	RTS

GAME_SCREEN:
	JSR CLEAR_TITLE
	JSR DRAW_BOARD
	JSR START_GAME
	RTS

CLEAR_TITLE:
	JSR TITLE_POINTERS
	DEC $00
	DEC $02
	LDY #0
	LDA #$20
CLEAR_TITLE_LOOP:
	STA ($00),Y
	STA ($02),Y
	INY
	CPY #15
	BNE CLEAR_TITLE_LOOP
	RTS

BOARD_POINTERS:
	LDY #6				; Here we're creating a BUNCH of pointers.
	JSR GET_CENTER		; $00, $02, $04, $06 and $08 all point to
	LDA $00				; rows of text that need to be drawn to
	ADC COLUMNS			; create (or clear) the board.  So now
	STA $02				; $00 ==> " | | "
	ADC COLUMNS			; $02 ==> "-+-+-"
	STA $04				; $04 ==> " | | "
	ADC COLUMNS			; $06 ==> "-+-+-"
	STA $06				; $08 ==> " | | "
	ADC COLUMNS
	STA $08
	LDA #2				; All the lines above set the low bytes of each pointer.
	STA $03				; 40 (max of COLUMNS) * 5 = max of 200, so there is no
	STA $05				; need to do any 16-bit mathing.  Setting the high byte
	STA $07				; is even easier - just plug a bunch of 2's in the right places
	STA $09
	LDY #0				; Cuz we almost always need to do this afterward :)
	RTS

DRAW_BOARD:
	JSR BOARD_POINTERS
DRAW_BOARD_LOOP:
	LDA BOARD_LINE_1,Y
	STA ($00),Y
	STA ($04),Y
	STA ($08),Y
	LDA BOARD_LINE_2,Y
	STA ($02),Y
	STA ($06),Y
	INY
	CPY #5
	BNE DRAW_BOARD_LOOP
	RTS

CLEAR_GAME:
	JSR BOARD_POINTERS
CLEAR_GAME_LOOP
	LDA #$20
	STA ($00),Y
	STA ($02),Y
	STA ($04),Y
	STA ($06),Y
	STA ($08),Y
	INY
	CPY #6
	BNE CLEAR_GAME_LOOP
	RTS


; Gets the low-byte of a string you want to print centered at the top
; Expects A is free to use, and Y = the length of the string we want to center
; Stores the resulting number at address $00
GET_CENTER:
	STY $00				; For these comments, we'll say Y = 14
	LDA COLUMNS			; COLUMNS has a max of 40, so I'll go with that.
	SBC $00				; 40 - 14 = 26
	STA $00				; Store it in $00
	LSR $00				; Divide the value at $00 by 2 (26 / 2 = 13)
	RTS					; And return

TITLE_SCREEN_LINE_1:	; "TIC-TAC-TIE :)"
	BYTE $14,$09,$03,$2D,$14,$01,$03,$2D,$14,$09,$05,$20,$3A,$29
TITLE_SCREEN_LINE_2:	; " PRESS X OR O"
	BYTE $10,$12,$05,$13,$13,$20,$18,$20,$0F,$12,$20,$0F,$20
BOARD_LINE_1:			; Like " | | "
	BYTE $20,$5D,$20,$5D,$20,$20
BOARD_LINE_2:			; Like "-+-+-"
	BYTE $40,$5B,$40,$5B,$40,$20

START_GAME:
	; Clear the board
	LDA #$20
	STA BOARD_STATE
	STA BOARD_STATE + 1
	STA BOARD_STATE + 2
	STA BOARD_STATE + 3
	STA BOARD_STATE + 4
	STA BOARD_STATE + 5
	STA BOARD_STATE + 6
	STA BOARD_STATE + 7
	STA BOARD_STATE + 8

	; Figure out if the player or the "AI" goes first
	LDA RANDOM
	CMP #$80
	BCS AI_MOVE
	JMP PLAYER_MOVE
GAME_LOOP:
	JSR PLAYER_MOVE		; jumps to AI_MOVE, so no need to do that here
	JMP GAME_LOOP

PLAYER_MOVE:
	LDA KEY
	CMP #KEY_Q
	BEQ TRY_1
	JMP AI_MOVE

TRY_1:
	LDA BOARD_STATE
	CMP #$20
	BNE PLAYER_MOVE
	LDA #$FF
	STA BOARD_STATE
	JMP AI_MOVE

AI_MOVE:
	JSR UPDATE_BOARD
	JMP PLAYER_MOVE		; For now

UPDATE_BOARD:
	JSR DRAW_BOARD
	LDX #0
	LDY #0
	LDA BOARD_STATE
	STA ($00),Y
	INX
	LDA BOARD_STATE,X
	STA ($04),Y
	INX
	LDA BOARD_STATE,X
	STA ($08),Y
	LDY #2
	INX
	LDA BOARD_STATE,X
	STA ($00),Y
	INX
	LDA BOARD_STATE,X
	STA ($04),Y
	INX
	LDA BOARD_STATE,X
	STA ($08),Y
	LDY #4
	INX
	LDA BOARD_STATE,X
	STA ($00),Y
	INX
	LDA BOARD_STATE,X
	STA ($04),Y
	INX
	LDA BOARD_STATE,X
	STA ($08),Y
	RTS

BOARD_STATE:
	BYTE $20,$20,$20,$20,$20,$20,$20,$20,$20
