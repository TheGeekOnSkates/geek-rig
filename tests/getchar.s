; =====================================================================
; TRADITIONAL "BLOCKING" GETCHAR (might be useful for a kernal later)
; =====================================================================

getchar:
	lda STDIN			; Read a character
	beq loop			; If zero, Keep reading
	rts					; And now we're 

