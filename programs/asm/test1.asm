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
	
GAME:
	LDA #214
	STA SCREEN
	JMP GAME

appleL = $80		; screen location of apple, low byte
appleH = $02		; screen location of apple, high byte
snakeHeadL = $2C	; screen location of snake head, low byte
snakeHeadH = $02	; screen location of snake head, high byte
snakeBodyStart = $12	; start of snake body byte pairs
snakeDirection = $02	; direction (possible values are below)
snakeLength = $03	; snake length, in bytes

; Directions (each using a separate bit)
movingUp = 1
movingRight = 2
movingDown = 4
movingLeft = 8

	JSR init
	JSR loop
init:
	JSR initSnake
	JSR generateApplePosition
	RTS


initSnake:
	LDA #movingRight	;start direction
	STA snakeDirection

	LDA #4	;start length (2 segments)
	STA snakeLength
	
	LDA #$11
	STA snakeHeadL
	
	LDA #$10
	STA snakeBodyStart
	
	LDA #$0f
	STA $14 ; body segment 1
	
	LDA #$04
	STA snakeHeadH
	STA $13 ; body segment 1
	STA $15 ; body segment 2
	RTS


generateApplePosition:
	;load a new random byte into $00
	LDA RANDOM
	STA appleL

	;load a new random number from 2 to 5 into $01
	LDA RANDOM
	and #$03 ;mask out lowest 2 bits
	CLC
	ADC #2
	STA appleH

	RTS


loop:
	JSR readKeys
	JSR checkCollision
	JSR updateSnake
	JSR drawApple
	JSR drawSnake
	JSR spinWheels
	JMP loop


readKeys:
	LDA KEY
	CMP #ASCII_w
	BEQ upKey
	CMP #ASCII_d
	BEQ rightKey
	CMP #ASCII_s
	BEQ downKey
	CMP #ASCII_a
	BEQ leftKey
	RTS
upKey:
	LDA #movingDown
	BIT snakeDirection
	BNE illegalMove

	LDA #movingUp
	STA snakeDirection
	RTS
rightKey:
	LDA #movingLeft
	BIT snakeDirection
	BNE illegalMove

	LDA #movingRight
	STA snakeDirection
	RTS
downKey:
	LDA #movingUp
	BIT snakeDirection
	BNE illegalMove

	LDA #movingDown
	STA snakeDirection
	RTS
leftKey:
	LDA #movingRight
	BIT snakeDirection
	BNE illegalMove

	LDA #movingLeft
	STA snakeDirection
	RTS
illegalMove:
	RTS


checkCollision:
	JSR checkAppleCollision
	JSR checkSnakeCollision
	RTS


checkAppleCollision:
	LDA appleL
	CMP snakeHeadL
	BNE doneCheckingAppleCollision
	LDA appleH
	CMP snakeHeadH
	BNE doneCheckingAppleCollision

	;eat apple
	INC snakeLength
	INC snakeLength ;increase length
	JSR generateApplePosition
doneCheckingAppleCollision:
	RTS


checkSnakeCollision:
	LDX #2 ;start with second segment
snakeCollisionLoop:
	LDA snakeHeadL,x
	CMP snakeHeadL
	BNE continueCollisionLoop

maybeCollided:
	LDA snakeHeadH,x
	CMP snakeHeadH
	BEQ didCollide

continueCollisionLoop:
	INX
	INX
	CPX snakeLength					;got to last section with no collision
	BEQ didntCollide
	JMP snakeCollisionLoop

didCollide:
	JMP gameOver
didntCollide:
	RTS


updateSnake:
	LDX snakeLength
	DEX
	TXA
updateloop:
	LDA snakeHeadL,x
	STA snakeBodyStart,x
	DEX
	bpl updateloop

	LDA snakeDirection
	LSR
	BCS up
	LSR
	BCS right
	LSR
	BCS down
	LSR
	BCS left
up:
	LDA snakeHeadL
	SEC
	SBC #$20
	STA snakeHeadL
	bcc upup
	RTS
upup:
	dec snakeHeadH
	LDA #$1
	CMP snakeHeadH
	BEQ collision
	RTS
right:
	INC snakeHeadL
	LDA #$1f
	BIT snakeHeadL
	BEQ collision
	RTS
down:
	LDA snakeHeadL
	CLC
	ADC #$20
	STA snakeHeadL
	BCS downdown
	RTS
downdown:
	INC snakeHeadH
	LDA #$6
	CMP snakeHeadH
	BEQ collision
	RTS
left:
	DEC snakeHeadL
	LDA snakeHeadL
	AND #$1f
	CMP #$1f
	BEQ collision
	RTS
collision:
	JMP gameOver


drawApple:
	LDY #0
	LDA RANDOM
	STA (appleL),y
	RTS


drawSnake:
	LDX snakeLength
	LDA #0
	STA (snakeHeadL,x) ; erase end of tail

	LDX #0
	LDA #1
	STA (snakeHeadL,x) ; paint head
	RTS


spinWheels:
	LDX #0
spinloop:
	NOP
	NOP
	DEX
	BNE spinloop
	RTS

gameOver:
