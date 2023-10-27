; =====================================================================
; 16-BIT MATHING IMPLEMENTATIONS
; Thank You my awesome Lord Jesus for the amazing tutorials here:
; https://retro64.altervista.org/blog/an-introduction-to-6502-math-addiction-subtraction-and-more/
; Note that code that uses this should set math16_1/2_low/hidh before
; calling add16, subtract16, multiply16 or divide16.
; Oh!  Also, see http://www.6502.org/source/
; =====================================================================

math16_1_low =			$02
math16_1_high =			$03
math16_2_low =			$04
math16_2_high =			$05
math16_result_low =		$06
math16_result_high =	$07

; Sets the result back to zero; all math16 functions
; should do this first.
math16_init:
	lda #0
	sta math16_result_low
	sta math16_result_high
	rts

add16:
	jsr math16_init
	clc						; Clear the carry flag
	lda math16_1_low		; Then add the low numbers
	adc math16_2_low
	sta math16_result_low
	lda math16_1_high		; DON'T clear the carry flag
	adc math16_2_high		; Then add the high numbers
	sta math16_result_high
	rts						; math16_result_low now contains our result

subtract16:
	jsr math16_init
	sec						; "Clear the borrow" = set the carry
	lda math16_1_low		; Add the low numbers
	sbc math16_2_low
	sta math16_result_low
	lda math16_1_high		; Do NOT set the carry flag this time
	sbc math16_2_high		; And subtract the high numbers
	sta math16_result_high
	rts						; Again, math16_result_low has the answer

