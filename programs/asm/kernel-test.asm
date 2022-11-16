	ORG $05CC
	PROCESSOR 6502
	include "geekrig4000/memory-map.asm"

	; OTHER KERNEL SUBROUTINES I'D LIKE TO ADD:
	; CursorUp
	; CursorDown
	; ShowCursor (make it blink)
	; MoveCursor (using X and Y registers as coordinates)
	; SetCharAtCursor (I kinda have that already - see tests below)
	; GetChar (not sur ewhat to call this function really - not like C, more like "CHROUT" on the C64).  It should:
	;	- handle Backspace, Delete etc.
	;	- type printable characters
	; Print (till it finds a NULL terminator)
	; GetLine; this should:
	;	- Save the starting cursor postion
	;	- Get user input up to COLUMNS * 2 characters or until the user presses Enter
	; And I'm thinking about including some of the 16-bit math functions here too.
	;
	; AFTER THAT, LORD WILLING:
	;
	; When the kernel is done, I'm kinda
	; thinking of doing what real 8-bit
	; computers did: put that kernel in
	; ROM.  That way, games and software
	; can use the kernel without losing
	; that memory.  idk how big all the
	; functions above will be (<1K?) but
	; when they're done, it would be nice
	; to just add a couple addresses to
	; the memory map.
	; 
	; After that, time to get creative:
	;	- A text editor?
	;	- A Forth?
	;	- A bASIC?  Yeah right :D
	;	- Most likely, an assembler (well,
	;		a program that will let you
	;		type LDA #7 and STA $0200,
	;		kind of like an interactive
	; 		assembly interpreter) :D


; -------------------------------------------------------------------------------
; Test #1: Fill the screen with G's (worked)
;
;	LDA #7
;	JSR ClearScreen
;	BRK

; -------------------------------------------------------------------------------
; Test #2: Fill the screen with G's using CursorForward
; this one had interesting results... in some ways, it
; seems faster than #1 above... but it was also kind of\
; "jumpy" (for lack of a fancy technical term, lol)
;
;
;	JSR InitCursor
;Test:
;	LDA #7
;	STA ($00),Y
;	JSR CursorForward
;	JMP Test


; -------------------------------------------------------------------------------
; Test #3: Fill the screen with G's using CursorBack
; This one was fun!  It filled the screen in a way
; that was (obviously) backwards - but what a cool
; effect!  I could ABSOLUTELY see using that in a game. :)

;	LDA #$C0
;	STA $00
;	LDA #$05
;	STA $01
;Test:
;	LDA #7
;	STA ($00),Y
;	JSR CursorBack
;	JMP Test

; -------------------------------------------------------------------------------
; Test #4: Typing! :D
; Unlike the others, I did NOT test this in "Easy 6502" first.
; But obviously, this is something many programs would benefit from...
;
; This test might actually be the basis for Getchar or CharOut or whatever I end
; up calling it, lol... 


	; Idea: Change character set (worked)
	; Let's get uppercase done right first :)
	JSR UseLowercase




	JSR InitCursor
WaitForKeyPress:
	LDA KEY
	BEQ WaitForKeyPress
	JSR PrintChar
	JMP WaitForKeyPress

PrintChar:

	; For now, let's leave every character as-is.
	; That test was intersting... So capital letters are working fine.
	; So are numbers and a lot of punctuaion (but not all).
	; So first, let's check for lowercase letters...
	CMP #97
	BCS PrintChar_CouldBeLetter

PrintChar_NotLetter:

	; If it gets here, just run it as-is
	JMP PrintChar_Ready

PrintChar_CouldBeLetter:
	CMP #123
	BCC PrintChar_IsLetter
	JMP PrintChar_NotLetter

PrintChar_IsLetter:
	SEC
	SBC #$60


	
	; If it's between 32 and 
;	CMP #$20
;	BCS PrintChar_CouldBePunctuation

;PrintChar_NotPunctuation:

	; Okay, we've eliminated that, so... how about letters
;	CMP #97
;	BCS PrintChar_CouldBeLetter

;PrintChar_NotALetter:

;	JMP PrintChar_Ready

;PrintChar_CouldBePunctuation:
;	CMP #$26
;	BCC PrintChar_Ready
;	JMP PrintChar_NotPunctuation
;	
;
;
;
;PrintChar_CouldBeLetter:
;	CMP #123
;	BCC PrintChar_Ready
;	JMP PrintChar_NotALetter
;
;PrintChar_IsLetter:
;	SBC #32
	
PrintChar_Ready:
	LDY #0
	STA (KERNEL_CURSOR_LSB),Y
	LDA #0
	STA KEY
	JSR CursorForward
	RTS




; Defines ClearScreen and other stuff
; I haven't written yet :)
	include "geekrig4000/kernel.asm"
	
