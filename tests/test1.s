 .ORG $0200
 processor 6502

; Define some constants
STDIN	= 0xF000
STDOUT	= 0xF001
KEY_ESCAPE = $1B		; The ASCII char code (and also key code) 27, Esc


	LDX #52				; '4', meaning "background color"
	LDY #52				; '4', meaning "blue"
	JSR SetColors
	DEX					; Now X = '3', meaning "text color"
	DEY					; Now Y = '3', meaning "yellow"
	JSR SetColors
	JSR ClearToColor	; Clear the screen and see what happens! :-)
loop:
	LDA STDIN			; Read a character
;	CMP #$00			; If it's zero
	BEQ loop			; Keep reading
	STA STDOUT			; Print it
	JMP loop			; And do it again :-)

; Sends the ANSI escape character (0x1B) followd by the character "c"
; Doesn't expect any registers as input
; Assumes the A-register is availablea.
ClearScreen:
	LDA #KEY_ESCAPE
	STA STDOUT
	LDA #99
	STA STDOUT
	RTS

; Sets the text color and background color
; Expects A to be available to work with (it will change A)
; Expects X to be 51 (for text color) or 52 (for background color)
; Expects Y to be a number between 48 and 57
; Note that this doesn't clear to a color; it clears the scroll buffer,
; and I think resets everything back to default too.  Use ClearToColor
; if what you want is to change the background color too
SetColors:
	LDA #KEY_ESCAPE	; Escape
	STA STDOUT
	LDA #91		; '['
	STA STDOUT
	STX STDOUT	; X
	STY STDOUT	; Y
	LDA #109	; 'm'
	STA STDOUT
	RTS

; Clears the screen, filling it in with whatever text color is currently set
; Doesn't expect any registers as input
; Assumes the A-register is availablea.
ClearToColor:
	LDA #KEY_ESCAPE	; Escape
	STA STDOUT
	LDA #91		; '['
	STA STDOUT
	LDA #50		; '2'
	STA STDOUT
	LDA #72		; 'J'
	STA STDOUT
	JSR Home
	RTS
	
; Moves the cursor to the top left of the screen
; Doesn't expect any registers as input
; Assumes the A-register is availablea.
Home:
	LDA #KEY_ESCAPE
	STA STDOUT
	LDA #91		; '['
	STA STDOUT
	LDA #74		; 'H'
	STA STDOUT
	RTS

