; =====================================================================
; PRINT.s - prints a string of bytes until it hits a NULL (0) byte
; =====================================================================

; This is the only variable that it uses, and currently the only
; zero-page byte used by anything on the Geek-Rig... but it may
; change as I continue to play with this stuff...
PRINT_pointer = $00

PRINT:
	; Get the address of the string to be printed
	; x = the low byte, y = the high byte
	stx PRINT_pointer
	sty PRINT_pointer + 1
	ldy #0
PRINT_continue:
	; Read the next character; if it's zero, we're done
	lda (PRINT_pointer),Y
	beq PRINT_done
	
	; Print it and move to the next character.
	; If that next character is zero, we're done
	sta STDOUT
	iny
	bne PRINT_continue
PRINT_done:
	rts

