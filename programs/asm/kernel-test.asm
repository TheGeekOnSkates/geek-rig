	ORG $05CC
	PROCESSOR 6502
	include "geekrig4000/memory-map.asm"

	; OTHER KERNEL SUBROUTINES I'D LIKE TO ADD:
	; DrawCursor
	; CursorForward
	; CursorBack
	; CursorUp
	; CursorDown
	; MoveCursor (using X and Y registers as coordinates)
	; SetCharAtCursor
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
; Test #1: Fill the screen with G's

	LDA #7
	JSR ClearScreen
	BRK


; Defines ClearScreen and other stuff
; I haven't written yet :)
	include "geekrig4000/kernel.asm"
