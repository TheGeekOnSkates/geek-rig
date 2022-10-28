; This is the fully-commented version; as I get stuff working, I'm deleting it from here.
; Once the game is done, I'll delete this whole thing and replace it with the finished source code.

MAIN_LOOP:
	; JSR READ_KEYS	-- done
	; JSR CHECK_COLLISIONS -- in progress
	jsr updateSnake
	jsr drawApple
	jsr drawSnake
	jsr spinWheels
	JMP MAIN_LOOP	; This one was easy :)

checkSnakeCollision:
	ldx #2 ;Load the value 2 into the X register, so we start with the first segment
snakeCollisionLoop:
	lda $10,x ;load the value stored at address $10 (the least significant byte of
	;the location of the snake's head) plus the value of the x register
	;(2 in the first iteration) to get the least significant byte of the
	;position of the next snake segment
	cmp $10	 ;compare to the value at address $10 (the least significant
	;byte of the position of the snake's head
	bne continueCollisionLoop ;if not equals, we haven't found a collision yet,
			;branch to continueCollisionLoop to continue the loop
maybeCollided:
	;ending up here means we found a segment of the snake's body that
	;has a least significant byte that's equal to that of the snake's head.
	lda $11,x	;load the value stored at address $11 (most significant byte of
		 ;the location of the snake's head) plus the value of the x register
		 ;(2 in the first iteration) to get the most significant byte
		 ;of the position of the next snake segment
	cmp $11	;compare to the value at address $11 (the most significant
		 ;byte of the position of the snake head)
	beq didCollide ;both position bytes of the compared segment of the snake body
		 ;are equal to those of the head, so we have a collision of the
		 ;snake's head with its own body.
continueCollisionLoop:
	;increment the value in the x register twice because we use two bytes to store
	;the coordinates for snake head and body segments
	inx		;increment the value of the x register
	inx		;increment the value of the x register
	cpx $03		;compare the value in the x register to the value stored at
		 ;address $03 (snake length).
	beq didntCollide ;if equals, we got to last section with no collision: branch
		 ;to didntCollide
	
	;ending up here means we haven't checked all snake body segments yet
	jmp snakeCollisionLoop;jump to snakeCollisionLoop to continue the loop
didCollide:
	;there was a collision
	jmp gameOver ;jump to gameOver
didntCollide:
	;there was no collision, continue the game
	rts ;return


updateSnake:
	;collision checks have been done, update the snake. Load the length of the snake
	;minus one into the A register
	ldx $03 ;load the value stored at address $03 (snake length) into register X
	dex	 ;decrement the value in the X register
	txa	 ;transfer the value stored in the X register into the A register. WHY?

updateloop:
	;Example: the length of the snake is 4 bytes (two segments). In the lines above
	;the X register has been set to 3. The snake coordinates are now stored as follows:
	;$10,$11 : the snake head
	;$12,$13,$14,$15: the snake body segments (two bytes for each of the 2 segments)
	;
	;The loop shifts all coordinates of the snake two places further in memory,
	;calculating the offset of the origin from $10 and place it in memory offset to
	;$12, effectively shifting each of the snake's segments one place further:
	;
	;from:	x===
	;to:	===
	lda $10,x ;load the value stored at address $10 + x into register A
	sta $12,x ;store the value of register A into address $12 
	;plus the value of register X
	dex	 ;decrement X, and set negative flag if value becomes negative
	bpl updateloop ;branch to updateLoop if positive (negative flag not set)

	;now determine where to move the head, based on the direction of the snake
	;lsr: Logical Shift Right. Shift all bits in register A one bit to the right
	;the bit that "falls off" is stored in the carry flag
	lda $02	 ;load the value from address $02 (direction) into register A
	lsr	 ;shift to right
	bcs up	;if a 1 "fell off", we started with bin 0001, so the snakes needs to go up
	lsr	 ;shift to right
	bcs right ;if a 1 "fell off", we started with bin 0010, so the snakes needs to go right
	lsr	 ;shift to right
	bcs down	;if a 1 "fell off", we started with bin 0100, so the snakes needs to go down
	lsr	 ;shift to right
	bcs left	;if a 1 "fell off", we started with bin 1000, so the snakes needs to go left
up:
	lda $10	 ;put value stored at address $10 (the least significant byte, meaning the
	;position in a 8x32 strip) in register A
	sec	 ;set carry flag
	sbc #$20	;Subtract with Carry: subtract hex $20 (dec 32) together with the NOT of the
	;carry bit from value in register A. If overflow occurs the carry bit is clear.
	;This moves the snake up one row in its strip and checks for overflow
	sta $10	 ;store value of register A at address $10 (the least significant byte
	;of the head's position)
	bcc upup	;If the carry flag is clear, we had an overflow because of the subtraction,
	;so we need to move to the strip above the current one
	rts	 ;return
upup:
	;An overflow occurred when subtracting 20 from the least significant byte
	dec $11	 ;decrement the most significant byte of the snake's head's position to
	;move the snake's head to the next up 8x32 strip
	lda #$1	 ;load hex value $1 (dec 1) into register A
	cmp $11	 ;compare the value at address $11 (snake head's most significant
	;byte, determining which strip it's in). If it's 1, we're one strip too
	;(the first one has a most significant byte of $02), which means the snake
	;hit the top of the screen

	beq collision ;branch if equal to collision
	rts	 ;return
right:
	inc $10	 ;increment the value at address $10 (snake head's least
	;significant byte, determining where in the 8x32 strip the head is
	;located) to move the head to the right
	lda #$1f	;load value hex $1f (dec 31) into register A
	bit $10	 ;the value stored at address $10 (the snake head coordinate) is ANDed
	;with hex $1f (bin 11111), meaning all multiples of hex $20 (dec 32)
	;will be zero (because they all end with bit patterns ending in 5 zeros)
	;if it's zero, it means we hit the right of the screen
	beq collision ;branch to collision if zero flag is set
	rts	 ;return
down: 
	lda $10	 ;put value from address $10 (the least significant byte, meaning the
	;position in a 8x32 strip) in register A
	clc	 ;clear carry flag
	adc #$20	;add hex $20 (dec 32) to the value in register A and set the carry flag
	;if overflow occurs
	sta $10	 ;store the result at address $10 
	bcs downdown ;if the carry flag is set, an overflow occurred when adding hex $20 to the
	;least significant byte of the location of the snake's head, so we need to move
	;the next 8x3 strip
	rts	 ;return
downdown:
	inc $11	 ;increment the value in location hex $11, holding the most significatnt byte
	;of the location of the snake's head.
	lda #$6	 ;load the value hex $6 into the A register
	cmp $11	 ;if the most significant byte of the head's location is equals to 6, we're
	;one strip to far down (the last one was hex $05)
	beq collision ;if equals to 6, the snake collided with the bottom of the screen
	rts	 ;return

left:
	;A collision with the left side of the screen happens if the head wraps around to
	;the previous row, on the right most side of the screen, where, because the screen
	;is 32 wide, the right most positions always have a least significant byte that ends
	;in 11111 in binary form (hex $1f). ANDing with hex $1f in this column will always
	;return hex $1f, so comparing the result of the AND with hex $1f will determine if
	;the snake collided with the left side of the screen.

	dec $10	 ;subtract one from the value held in memory position $10 (least significant
	;byte of the snake head position) to make it move left.
	lda $10	 ;load value held in memory position $10 (least significant byte of the
	;snake head position) into register A
	and #$1f	;AND the value hex $1f (bin 11111) with the value in register A
	cmp #$1f	;compare the ANDed value above with bin 11111.
	beq collision ;branch to collision if equals
	rts	 ;return
collision:
	jmp gameOver ;jump to gameOver


drawApple:
	ldy #0	 ;load the value 0 into the Y register
	lda $fe	;load the value stored at address $fe (the random number generator)
		 ;into register A
	sta ($00),y	;dereference to the address stored at address $00 and $01
		 ;(the address of the apple on the screen) and set the value to
		 ;the value of register A and add the value of Y (0) to it. This results
		 ;in the apple getting a random color
	rts		;return

drawSnake:
	ldx #0	;set the value of the X register to 0
	lda #1	;set the value of the A register to 1
	sta ($10,x) ;dereference to the memory address that's stored at address
		;$10 (the two bytes for the location of the head of the snake) and
		;set its value to the one stored in register A
	ldx $03	 ;set the value of the x register to the value stored in memory at
		;location $03 (the length of the snake)
	lda #0	;set the value of the a register to 0
	sta ($10,x) ;dereference to the memory address that's stored at address
		;$10, add the length of the snake to it, and store the value of
		;register A (0) in the resulting address. This draws a black pixel on the
		;tail. Because the snake is moving, the head "draws" on the screen in
		;white as it moves, and the tail works as an eraser, erasing the white trail
		;using black pixels
	rts	 ;return

spinWheels:
	;slow the game down by wasting cycles
	ldx #0	 ;load zero in the X register
spinloop:
	nop		;no operation, just skip a cycle
	nop		;no operation, just skip a cycle
	dex		;subtract one from the value stored in register x
	bne spinloop ;if the zero flag is clear, loop. The first dex above wrapped the
		 ;value of x to hex $ff, so the next zero value is 255 (hex $ff)
		 ;loops later.
	RTS
