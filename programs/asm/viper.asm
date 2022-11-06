; __        __   __________    ______     ________    ______
; \ \      / /  |____  ____|  |  __  \   |  ______|  |  __  \
;  \ \    / /       |  |      | |__|  |  |  |___     | |__|  |
;   \ \  / /        |  |      |   ___/   |  ____|    |     _/
;    \ \/ /         |  |      |  |       |  |        |  |\ |
;     \  /       ___|  |____  |  |       |  |______  |  | \ \
;      \/       |___________| |__|       |________|  |__|  \_\
; 
; ==========================================================================================================================================================
; 
; Credits:
; 	"skilldrick", who wrote the tutorial that got me started
;	in 6502 Assembly programming, and also the original game
;	http://skilldrick.github.io/easy6502/
; 
;	"vkjagt", whose addition to skilldrick's work helped me
;	understand the code and port it to the Geek-Rig 4000
; 	https://gist.github.com/wkjagt/9043907
; 	
; 
; ==========================================================================================================================================================
; MEMORY MAP
;
; ADDRESS	WHAT I'M PUTTING THERE
; $00-01	screen location of apple, stored as two bytes, where the first byte is the least significant.
; $02		direction:
; 				1 => up    (bin 0001)
; 				2 => right (bin 0010)
; 				4 => down  (bin 0100)
;				8 => left  (bin 1000)
; $03		snake length, in number of bytes, not segments
; $04-05	screen location of snake head stored as two bytes
; $06-??	snake body (in byte pairs)
; ==========================================================================================================================================================
; OTHER NOTES:
; 	* Change direction with keys: W A S D
; 	* Unlike the system this game was originally designed for (a web-based system-in-a-browser), the Geek-Rig has 40x24 characters, from $0200-05BF.
; 	* After the code for the high score screen, the "BYTE" stuff at the bottom sotres the high scores.  This is what will get overwritten at the end,
; 		when the 4000's disk drive has a write function
; 
; ==========================================================================================================================================================
	ORG $05CC
	PROCESSOR 6502
	include "geekrig4000.asm"

MAIN_MENU:
	; Draw the title logo - not the most efficient way, I know, but it works.
	LDA #233
	STA SCREEN + 46
	LDA #214
	STA SCREEN + 47
	STA SCREEN + 48
	LDA #215
	STA SCREEN + 49
	LDA #223
	STA SCREEN + 50
	LDA #214
	STA SCREEN + 86
	STA SCREEN + 87
	STA SCREEN + 88
	LDA #98
	STA SCREEN + 89
	LDA #123
	STA SCREEN + 90
	LDA #214
	STA SCREEN + 126
	STA SCREEN + 166
	STA SCREEN + 170
	STA SCREEN + 206
	STA SCREEN + 210
	STA SCREEN + 246
	STA SCREEN + 250
	STA SCREEN + 286
	STA SCREEN + 290
	STA SCREEN + 326
	STA SCREEN + 327
	STA SCREEN + 329
	STA SCREEN + 330
	STA SCREEN + 367
	STA SCREEN + 368
	STA SCREEN + 369
	STA SCREEN + 172
	STA SCREEN + 173
	STA SCREEN + 174
	STA SCREEN + 175
	STA SCREEN + 176
	STA SCREEN + 214
	STA SCREEN + 254
	STA SCREEN + 294
	STA SCREEN + 334
	STA SCREEN + 372
	STA SCREEN + 373
	STA SCREEN + 374
	STA SCREEN + 375
	STA SCREEN + 376
	STA SCREEN + 178
	STA SCREEN + 179
	STA SCREEN + 180
	STA SCREEN + 181
	STA SCREEN + 218
	STA SCREEN + 221
	STA SCREEN + 258
	STA SCREEN + 259
	STA SCREEN + 260
	STA SCREEN + 261
	STA SCREEN + 298
	STA SCREEN + 338
	STA SCREEN + 378
	STA SCREEN + 183
	STA SCREEN + 184
	STA SCREEN + 185
	STA SCREEN + 186
	STA SCREEN + 187
	STA SCREEN + 223
	STA SCREEN + 263
	STA SCREEN + 264
	STA SCREEN + 265
	STA SCREEN + 303
	STA SCREEN + 343
	STA SCREEN + 383
	STA SCREEN + 384
	STA SCREEN + 385
	STA SCREEN + 386
	STA SCREEN + 387
	STA SCREEN + 189
	STA SCREEN + 190
	STA SCREEN + 191
	STA SCREEN + 192
	STA SCREEN + 193
	STA SCREEN + 229
	STA SCREEN + 233
	STA SCREEN + 269
	STA SCREEN + 270
	STA SCREEN + 271
	STA SCREEN + 272
	STA SCREEN + 309
	STA SCREEN + 312
	STA SCREEN + 313
	STA SCREEN + 349
	STA SCREEN + 353
	STA SCREEN + 389
	STA SCREEN + 393
	
	; Draw the text "press any key to start"
	LDA #16
	STA SCREEN + 449
	LDA #18
	STA SCREEN + 450
	LDA #5
	STA SCREEN + 451
	LDA #19
	STA SCREEN + 452
	STA SCREEN + 453
	
	LDA #1
	STA SCREEN + 455
	LDA #14
	STA SCREEN + 456
	LDA #25
	STA SCREEN + 457
	
	LDA #11
	STA SCREEN + 459
	LDA #5
	STA SCREEN + 460
	LDA #25
	STA SCREEN + 461
	
	LDA #20
	STA SCREEN + 463
	LDA #15
	STA SCREEN + 464
	
	LDA #19
	STA SCREEN + 466
	LDA #20
	STA SCREEN + 467
	STA SCREEN + 470
	LDA #1
	STA SCREEN + 468
	LDA #18
	STA SCREEN + 469

MAIN_MENU_PROMPT:
	LDA KEY
	BEQ MAIN_MENU_PROMPT
	JMP START_GAME
	
CLEAR_SCREEN:
	LDA #$20
	LDX #0
CLEAR_SCREEN_CONTINUE:
	STA SCREEN,X
	STA SCREEN + 40,X
	STA SCREEN + 80,X
	STA SCREEN + 120,X
	STA SCREEN + 160,X
	STA SCREEN + 200,X
	STA SCREEN + 240,X
	STA SCREEN + 280,X
	STA SCREEN + 320,X
	STA SCREEN + 360,X
	STA SCREEN + 400,X
	STA SCREEN + 440,X
	STA SCREEN + 480,X
	STA SCREEN + 520,X
	STA SCREEN + 560,X
	STA SCREEN + 600,X
	STA SCREEN + 640,X
	STA SCREEN + 680,X
	STA SCREEN + 720,X
	STA SCREEN + 760,X
	STA SCREEN + 800,X
	STA SCREEN + 840,X
	STA SCREEN + 880,X
	STA SCREEN + 920,X
	INX
	CPX #41
	BNE CLEAR_SCREEN_CONTINUE
	RTS
	
START_GAME:
	JSR CLEAR_SCREEN
	JSR CREATE_SNAKE
	JSR CREATE_APPLE
MAIN_LOOP:
	JSR READ_KEYS
	JSR CHECK_COLLISIONS
	JSR DRAW_APPLE
	JMP MAIN_LOOP

CREATE_SNAKE:
	LDA #214	; The reverse X, like a scaly snake
	STA $03F4	; Center of the screen
  	LDA #2		; direction = right
	STA $02
	LDA #4		; remember the head counts for 2 bytes
	STA $03		; Again, address $03 = snake length
	
	LDA #$F4	; We also need to store the head's location
	STA $04		; in memory addresses $04-05 for later
	LDA #$03	; Above was low byte (LSB)
	STA $05		; And here is the high byte (MSB)
	
	; Set up the pointers to the snake's body, two LSBs
	; "one and two places left of the head respectively"
	LDA #$F3	; Head is at $F4, so one to the left is $F3
	STA $06		; Snake body starts here
	LDA #$F2	; Next one to the left is at $F2
	STA $07		; And store that at the "end of the line"
	
	; There was also this bit in the origina; not sure if I need it, but it would go here...
;	;the most significant bytes of the head and body of the snake
;	;are all set to hex $04, which is the third 8x32 strip.
;	lda #$04
;	sta $11
;	sta $13
;	sta $15
	RTS

CREATE_APPLE:
	LDA RANDOM
	CMP #$C0
	BCS CREATE_APPLE
	STA $00
CREATE_APPLE_HIGH_BYTE:
	; Ironically, just like the Geek-Rig, the one on Easy 6502
	; also needs the high byte to be between 2 and 5, so...
	LDA RANDOM
	AND #$03 ;mask out lowest 2 bits
	CLC
	ADC #2
	STA $01
DRAW_APPLE:
	LDA #$51		; Circle, closest I got to an apple
	LDY #0			; Cuz I can't just STA (appleL)
	STA ($00),Y
	RTS

READ_KEYS:
	LDA KEY
	CMP #KEY_W
	BEQ GOING_UP
	CMP #KEY_D
	BEQ GOING_DOWN
	CMP #KEY_D
	BEQ GOING_RIGHT
	CMP #KEY_S
	BEQ GOING_LEFT
	RTS
	
; NOTE (from the original):
; setting the zero flag if the result of ANDing the two values
; is 0. So comparing to 4 (bin 0100) only sets zero flag if
; current direction is 4 (DOWN). So for an illegal move (current
; direction is DOWN), the result of an AND would be a non zero value
; so the zero flag would not be set. For a legal move the bit in the
; new direction should not be the same as the one set for DOWN,
; so the zero flag needs to be set
GOING_UP:
	LDA #4		; Direction = up
	BIT $02		; AND with value at address $02 (the current direction)
	BNE ILLEGAL_MOVE
	LDA #1		; Ending up here means the move is legal
	STA $02		; ;Store the new direction at address $02
	RTS

; The other directions work in exactly the same way
GOING_DOWN:
	LDA #1
	BIT $02
	BNE ILLEGAL_MOVE
	LDA #4
	STA $02
	RTS
GOING_RIGHT:
	LDA #8
	BIT $02
	BNE ILLEGAL_MOVE
	LDA #2
	STA $02
	RTS
GOING_LEFT:
	LDA #2
	BIT $02
	BNE ILLEGAL_MOVE
	LDA #8
	STA $02
	; RTS	; Actually I can cut this out, saving a byte for something else
ILLEGAL_MOVE:
	RTS	; just return, so the keypress is ignored
	
CHECK_COLLISIONS:
	JSR CHECK_APPLE_COLLISION
	JSR CHECK_SNAKE_COLLISION
	RTS

CHECK_APPLE_COLLISION:
	;check if the snake collided with the apple by comparing the position of the snake's head and the apple.
	LDA $00		;load value at address $00 (the least significant
				;byte of the apple's position) into register A
	CMP $04		;compare to the value stored at address $04
				;(the least significant byte of the position of the snake's head)
	BNE DONE_CHECKING_APPLE_COLLISION
	LDA $01		;load value of address $01 (the most significant byte
				;of the apple's position) into register A
	CMP $11		;compare the value stored at address $11 (the most
				;significant byte of the position of the snake's head)
	BNE DONE_CHECKING_APPLE_COLLISION

	;Ending up here means the coordinates of the snake head are equal to that of
	;the apple: eat apple
	inc $03		 ;increase the snake length
	inc $03		 ;twice because we're adding two bytes for one segment

	; Create a new apple
	JSR CREATE_APPLE

	; Update the player's score
	INC HIGH_SCORE_PLAYER
DONE_CHECKING_APPLE_COLLISION:
	RTS
	
CHECK_SNAKE_COLLISION:
	; LEFT OFF HERE
	RTS




GAME_OVER:
	; In the original, this was the end of the program.
	; For Viper, I'd like this to load a high score screen
	; But for now...
	JMP MAIN_MENU

; The first byte is the score, and the 3 after it are the player's initials
HIGH_SCORE_1:
	BYTE $00, $00, $00, $00
HIGH_SCORE_2:
	BYTE $00, $00, $00, $00
HIGH_SCORE_3:
	BYTE $00, $00, $00, $00
HIGH_SCORE_PLAYER:
	BYTE $00, $00, $00, $00






; ---------------------------------------------------------------------------------------------------------------------


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

CHECK_SNAKE_COLLISION:
	LDX #2		; start with the first segment
SNAKE_COLLISION_LOOP:
	LDA $04,x	; load the least significant byte of the snake's head + x
				;(2 in the first iteration) to get the least significant byte of the
				;position of the next snake segment
	cmp $10		;compare to the value at address $10 (the least significant
				;byte of the position of the snake's head
	BNE CONTINUE_COLLISION_LOOP
MAYBE_COLLIDED:
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
CONTINUE_COLLISION_LOOP:
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
DID_COLLIDE:
	JMP GAME_OVER
DIDNT_COLLIDE:
	RTS


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
