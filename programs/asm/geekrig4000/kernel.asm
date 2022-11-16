CursorBack:
	; First, check if we're already at the beginning ($0200)
	LDA KERNEL_CURSOR_MSB	; MSB of pointer
	CMP #$02		; MSB of $0200
	BCC CursorBack_Done	; cursor < $0200 - should never happen
	BNE CursorBack_GoodToGo	; cursor > $0200
	LDA KERNEL_CURSOR_LSB	; LSB of pointer
	CMP #$00		; LSB of $0200
	BCC CursorBack_Done	; cursor < $0200 - should never happen
	BEQ CursorBack_Done	; cursor = $0200 - can't go any further back
CursorBack_GoodToGo:
	; And from here, I'm reusing the 16-bit subtraction trick I learned the other day :)
	SEC			; Set the carry flag
	LDA KERNEL_CURSOR_LSB
	SBC #1
	STA KERNEL_CURSOR_LSB
	LDA KERNEL_CURSOR_MSB	; MSB of pointer	
	SBC #$00		; Weird that it works, but it works
	STA KERNEL_CURSOR_MSB	
CursorBack_Done:
	RTS

CursorForward:
	; First, check if we're already at the end ($05C0)
	LDA KERNEL_CURSOR_MSB	; MSB of pointer
	CMP #$05		; MSB of $05C0
	BCC CursorForward_GoodToGo
	BNE CursorForward_Done	; Should never happen
	LDA KERNEL_CURSOR_LSB	; LSB of pointer
	CMP #$C0		; LSB of $05C0
	BCS CursorForward_Done
CursorForward_GoodToGo:
	INC KERNEL_CURSOR_LSB
	BEQ CursorForward_Bit2
	JMP CursorForward_Done
CursorForward_Bit2:
	INC KERNEL_CURSOR_MSB
CursorForward_Done:
	RTS

InitCursor:
	LDA #<SCREEN
	STA $00
	LDA #>SCREEN
	STA $01
	RTS



; ------------------------------------------------------------------------------------------------
; Fills screen RAM with the value of the A-register
; Expects the X and Y registers to not be needed for anything
; Expects memory addresses $00-$02 to be available to use
; ------------------------------------------------------------------------------------------------
ClearScreen:
	LDY #$00	; #<SCREEN (doesn't work right in Easy 6502)
	STY $00
	LDY #$02	; #>SCREEN
	STY $01		; So now $00 points to $0200, a.k.a. SCREEN
	LDY #$00	; Set address $02 to zero; $02 is a "row counter"
	STY $02		; We'll need it cuz we're doing a nested loop.
ClearScreen_MainLoop:
	JSR ClearRow	; Clear the row pointed to by $00
	JSR ClearScreen_MovePointerDownOneRow	; Update the pointer, adding the total columns
	INC $02		; Our row-counter ++
	LDX $02		; Now X = value at $02
	CPX ROWS	; If $02 != ROWS
	BNE ClearScreen_MainLoop	; continue clearing the screen
ClearScreen_Done:
	RTS		; When it gets here, $02 should be the value at COLUMNS

ClearRow:
	LDY #0			; Y = 0; this starts a loop, as usual :)
ClearRow_Continue:
	STA ($00),Y		; Value at SCREEN + Y = value in A-register
	INY			; Y++
	CPY COLUMNS		; if Y < COLUMNS
	BNE ClearRow_Continue	; continue the loop
	RTS			; When it gets here, Y should be == COLUMNS

ClearScreen_MovePointerDownOneRow:
	TAX			; Save A in X.  We'll need it later
	CLC			; Starting on some 16-bit mathing
	LDA $00			; Now A = low byte of the pointer at $00
	ADC COLUMNS		; A += value at COLUMNS
	STA $00			; Now $00 = A
	BCS ClearScreen_MovePointerDownOneRow_Bit2	; If carry flag set, increase the high byte by 1
	JMP ClearScreen_MovePointerDownOneRow_Done	; If not, we're done
ClearScreen_MovePointerDownOneRow_Bit2:
	INC $01			; Add 1 to the high-byte of our row pointer
ClearScreen_MovePointerDownOneRow_Done:
	TXA			; Restore A to the value the user wanted
	RTS			; And we're done updating the pointer
