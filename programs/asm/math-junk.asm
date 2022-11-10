; Trying to crack 16-bit mathing.
;		Adding
;		Subtracting
;		Multiplying
;		Dividing
;		Check if greater than
;		Check if less than
;		Check if equal
;		Check if not equal
; If I can somehow achieve all of the above, things get a whole lot easier.

; Like in Invaders - moving a laser up by 40, checking if a ship is there,
; etc... that becomes a lot easier, though probably not highly optimized.
; Same deal with Viper - the positions of the snake body are all 16-bit, and
; so are the apples, etc... even Tic-Tac-Tie gets a lot easier for things
; like calculating where to draw stuff.

; Anyway, I'm doing these experiments in Easy 6502, cuz it has a debugger.
; The Geek-Rig's file-based one is... tolerable... but I like the ability to
; tesp through my code - not sure how to make the Geek-Rig do that. :D



; -------------------------------------------------------------------------
; SUBTRACTION
; -------------------------------------------------------------------------

; $0303 - $FF = $0204 - worked
; $0303 - $02 = $0301 - worked
; Wow, okay, how about...
; $0303 - $0201 = $0102 - holy guac that works!

MAIN:
 JSR TEST
 LDA #$99
 LDA $00
 LDA $01
 BRK

TEST:
 SEC	; set the carry (opposite of what
		; I was doing, lol... carry != borrow :D
		; #mathSucksPucks :D
 LDA #$03	; num1_low
 SBC #$01	; num2_low
 STA $00	; result_low
 LDA #$03	; num1_high
 SBC #$02	; num2_high
 STA $01	; result_high
 RTS

; Now, how to make that a subroutine?

define MATH_N1_LO $A000
define MATH_N1_HI $A001
define MATH_N2_LO $A002
define MATH_N2_HI $A003
define MATH_RESULT_LO $A004
define MATH_RESULT_HI $A005

; $0303 - $00FF = $0204 - WORKED!
; $0303 - $0002 = $0301 - WORKED!
; $0303 - $0201 = $0102 - WOOOOOOOOOOOOOOO!

MAIN:
 ; Set the first number to $0303
 LDA #$03
 STA MATH_N1_LO
 STA MATH_N1_HI

 ; Set the second number to $0201
 LDA #$01
 STA MATH_N2_LO
 LDA #$02
 STA MATH_N2_HI

 ; Do the math
 JSR SUB

 ; A should be 4, X should be 2
 LDA MATH_RESULT_LO
 LDX MATH_RESULT_HI
 BRK

SUB:
 SEC
 LDA MATH_N1_LO
 SBC MATH_N2_LO
 STA MATH_RESULT_LO
 LDA MATH_N1_HI
 SBC MATH_N2_HI
 STA MATH_RESULT_HI
 RTS




; -------------------------------------------------------------------------
