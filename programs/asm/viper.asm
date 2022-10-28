This is the fully-commented version; as I get stuff working, I'm deleting it from here.
Once the game is done, I'll delete this whole thing and replace it with the finished source code.

MAIN_LOOP:
  ;the main game loop
  JSR READ_KEYS		; Done
  jsr checkCollision   ;jump to subroutine checkCollision
  jsr updateSnake
  jsr drawApple
  jsr drawSnake
  jsr spinWheels
  JMP MAIN_LOOP		; This one was easy :)

checkCollision:
  jsr checkAppleCollision ;jump to subroutine checkAppleCollision
  jsr checkSnakeCollision ;jump to subroutine checkSnakeCollision
  rts                     ;return


checkAppleCollision:
  ;check if the snake collided with the apple by comparing the least significant
  ;and most significant byte of the position of the snake's head and the apple.
  lda $00                 ;load value at address $00 (the least significant
                          ;byte of the apple's position) into register A
  cmp $10                 ;compare to the value stored at address $10
                          ;(the least significant byte of the position of the snake's head)
  bne doneCheckingAppleCollision ;if different, branch to doneCheckingAppleCollision
  lda $01                 ;load value of address $01 (the most significant byte
                          ;of the apple's position) into register A
  cmp $11                 ;compare the value stored at address $11 (the most
                          ;significant byte of the position of the snake's head)
  bne doneCheckingAppleCollision ;if different, branch to doneCheckingAppleCollision

  ;Ending up here means the coordinates of the snake head are equal to that of
  ;the apple: eat apple
  inc $03                 ;increment the value held in memory $03 (snake length)
  inc $03                 ;twice because we're adding two bytes for one segment

  ;create a new apple
  jsr generateApplePosition ;jump to subroutine generateApplePosition

doneCheckingAppleCollision:
  ;the snake head was not on the apple. Don't do anything with the apple
  rts ;return


checkSnakeCollision:
  ldx #2 ;Load the value 2 into the X register, so we start with the first segment

snakeCollisionLoop:
  lda $10,x ;load the value stored at address $10 (the least significant byte of
            ;the location of the snake's head) plus the value of the x register
            ;(2 in the first iteration) to get the least significant byte of the
            ;position of the next snake segment
  cmp $10   ;compare to the value at address $10 (the least significant
            ;byte of the position of the snake's head
  bne continueCollisionLoop ;if not equals, we haven't found a collision yet,
                            ;branch to continueCollisionLoop to continue the loop

maybeCollided:
  ;ending up here means we found a segment of the snake's body that
  ;has a least significant byte that's equal to that of the snake's head.
  lda $11,x      ;load the value stored at address $11 (most significant byte of
                 ;the location of the snake's head) plus the value of the x register
                 ;(2 in the first iteration) to get the most significant byte
                 ;of the position of the next snake segment
  cmp $11        ;compare to the value at address $11 (the most significant
                 ;byte of the position of the snake head)
  beq didCollide ;both position bytes of the compared segment of the snake body
                 ;are equal to those of the head, so we have a collision of the
                 ;snake's head with its own body.

continueCollisionLoop:
  ;increment the value in the x register twice because we use two bytes to store
  ;the coordinates for snake head and body segments
  inx              ;increment the value of the x register
  inx              ;increment the value of the x register
  cpx $03          ;compare the value in the x register to the value stored at
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
  dex     ;decrement the value in the X register
  txa     ;transfer the value stored in the X register into the A register. WHY?

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
  ;from:  x===
  ;to:    ===
  lda $10,x ;load the value stored at address $10 + x into register A
  sta $12,x ;store the value of register A into address $12 
            ;plus the value of register X
  dex       ;decrement X, and set negative flag if value becomes negative
  bpl updateloop ;branch to updateLoop if positive (negative flag not set)

  ;now determine where to move the head, based on the direction of the snake
  ;lsr: Logical Shift Right. Shift all bits in register A one bit to the right
  ;the bit that "falls off" is stored in the carry flag
  lda $02   ;load the value from address $02 (direction) into register A
  lsr       ;shift to right
  bcs up    ;if a 1 "fell off", we started with bin 0001, so the snakes needs to go up
  lsr       ;shift to right
  bcs right ;if a 1 "fell off", we started with bin 0010, so the snakes needs to go right
  lsr       ;shift to right
  bcs down  ;if a 1 "fell off", we started with bin 0100, so the snakes needs to go down
  lsr       ;shift to right
  bcs left  ;if a 1 "fell off", we started with bin 1000, so the snakes needs to go left
up:
  lda $10   ;put value stored at address $10 (the least significant byte, meaning the
            ;position in a 8x32 strip) in register A
  sec       ;set carry flag
  sbc #$20  ;Subtract with Carry: subtract hex $20 (dec 32) together with the NOT of the
            ;carry bit from value in register A. If overflow occurs the carry bit is clear.
            ;This moves the snake up one row in its strip and checks for overflow
  sta $10   ;store value of register A at address $10 (the least significant byte
            ;of the head's position)
  bcc upup  ;If the carry flag is clear, we had an overflow because of the subtraction,
            ;so we need to move to the strip above the current one
  rts       ;return
upup:
  ;An overflow occurred when subtracting 20 from the least significant byte
  dec $11   ;decrement the most significant byte of the snake's head's position to
            ;move the snake's head to the next up 8x32 strip
  lda #$1   ;load hex value $1 (dec 1) into register A
  cmp $11   ;compare the value at address $11 (snake head's most significant
            ;byte, determining which strip it's in). If it's 1, we're one strip too
            ;(the first one has a most significant byte of $02), which means the snake
            ;hit the top of the screen

  beq collision ;branch if equal to collision
  rts       ;return
right:
  inc $10   ;increment the value at address $10 (snake head's least
            ;significant byte, determining where in the 8x32 strip the head is
            ;located) to move the head to the right
  lda #$1f  ;load value hex $1f (dec 31) into register A
  bit $10   ;the value stored at address $10 (the snake head coordinate) is ANDed
            ;with hex $1f (bin 11111), meaning all multiples of hex $20 (dec 32)
            ;will be zero (because they all end with bit patterns ending in 5 zeros)
            ;if it's zero, it means we hit the right of the screen
  beq collision ;branch to collision if zero flag is set
  rts       ;return
down: 
  lda $10   ;put value from address $10 (the least significant byte, meaning the
            ;position in a 8x32 strip) in register A
  clc       ;clear carry flag
  adc #$20  ;add hex $20 (dec 32) to the value in register A and set the carry flag
            ;if overflow occurs
  sta $10   ;store the result at address $10 
  bcs downdown ;if the carry flag is set, an overflow occurred when adding hex $20 to the
            ;least significant byte of the location of the snake's head, so we need to move
            ;the next 8x3 strip
  rts       ;return
downdown:
  inc $11   ;increment the value in location hex $11, holding the most significatnt byte
            ;of the location of the snake's head.
  lda #$6   ;load the value hex $6 into the A register
  cmp $11   ;if the most significant byte of the head's location is equals to 6, we're
            ;one strip to far down (the last one was hex $05)
  beq collision ;if equals to 6, the snake collided with the bottom of the screen
  rts       ;return

left:
  ;A collision with the left side of the screen happens if the head wraps around to
  ;the previous row, on the right most side of the screen, where, because the screen
  ;is 32 wide, the right most positions always have a least significant byte that ends
  ;in 11111 in binary form (hex $1f). ANDing with hex $1f in this column will always
  ;return hex $1f, so comparing the result of the AND with hex $1f will determine if
  ;the snake collided with the left side of the screen.

  dec $10   ;subtract one from the value held in memory position $10 (least significant
            ;byte of the snake head position) to make it move left.
  lda $10   ;load value held in memory position $10 (least significant byte of the
            ;snake head position) into register A
  and #$1f  ;AND the value hex $1f (bin 11111) with the value in register A
  cmp #$1f  ;compare the ANDed value above with bin 11111.
  beq collision ;branch to collision if equals
  rts       ;return
collision:
  jmp gameOver ;jump to gameOver


drawApple:
  ldy #0       ;load the value 0 into the Y register
  lda $fe      ;load the value stored at address $fe (the random number generator)
               ;into register A
  sta ($00),y  ;dereference to the address stored at address $00 and $01
               ;(the address of the apple on the screen) and set the value to
               ;the value of register A and add the value of Y (0) to it. This results
               ;in the apple getting a random color
  rts          ;return


drawSnake:
  ldx #0      ;set the value of the X register to 0
  lda #1      ;set the value of the A register to 1
  sta ($10,x) ;dereference to the memory address that's stored at address
              ;$10 (the two bytes for the location of the head of the snake) and
              ;set its value to the one stored in register A
  ldx $03     ;set the value of the x register to the value stored in memory at
              ;location $03 (the length of the snake)
  lda #0      ;set the value of the a register to 0
  sta ($10,x) ;dereference to the memory address that's stored at address
              ;$10, add the length of the snake to it, and store the value of
              ;register A (0) in the resulting address. This draws a black pixel on the
              ;tail. Because the snake is moving, the head "draws" on the screen in
              ;white as it moves, and the tail works as an eraser, erasing the white trail
              ;using black pixels
  rts         ;return


spinWheels:
  ;slow the game down by wasting cycles
  ldx #0       ;load zero in the X register
spinloop:
  nop          ;no operation, just skip a cycle
  nop          ;no operation, just skip a cycle
  dex          ;subtract one from the value stored in register x
  bne spinloop ;if the zero flag is clear, loop. The first dex above wrapped the
               ;value of x to hex $ff, so the next zero value is 255 (hex $ff)
               ;loops later.
  rts          ;return






--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
COMMENTS
----------------------------------------------------------------------------------------------

@RGrun
Tip
RGrun commented on Feb 5, 2016
There are typos on lines 47 and 56.

@ulidtko
Tip
ulidtko commented on Jan 9, 2017
Well, I finally get the whole "snake game" idea: you don't see any bugs until you play long enough to try to beat the game.

This one will crawl slower and slower as the snake gets longer and longer. This gets pretty serious pretty quick.

It will also spawn food on top of snake body. Which was actually funny to see, cause immediately I've known that there's no food spawn loop (gen random location - check if collides with body - loop - else continue) before reading the source code. Which is sort of sad in another way, because if there were a food spawn loop, food spawning would get exponentially slower as the current snake area to total field area ratio increased. At some point, waiting for a new "apple" (sic) could've taken good few minutes. Alas - not in this implementation, cause it just spawns food wherever, even on top of the snake body.

Finally, at snake length of around 55 (slightly more than 1½ of screen width) the game glitched while I was turning around near a wall. It made a hole in the snake body, and then stopped erasing the tail as the snake moved forward. Pretty soon, the game was over.

Thank you buggy snake, I now know 6502!

@hasseily
Tip
hasseily commented on Jun 13, 2018 • 
One simple way to mitigate the slowness is inside spinWheels to load into x the length of the snake and increment x. So spinWheels slows you down less and less as the snake grows in size.
Ideally one should calculate the exact increase in cycles for each additional snake length unit, and reduce spinWheels by so many cycles.
Below is a version that reduces the spinloop by twice the length of the snake and keeps the speed relatively constant as the snake grows in length. Note that the length of the snake grows by 2 every time you eat an apple, so the loop reduces by 4 every time.
You may wonder what happens when the addition rolls over and carries. Wonder not, as the game itself will bug at that length. The snake will keep extending and the tail will stop moving.

spinWheels:
lda snakeLength
adc snakeLength
spinloop:
nop
nop
adc #1
bne spinloop
rts

@grobda commented on Feb 15, 2019
I think a better way to code the snake and detect collisions with itself would be to only store the head and tail (last segment) locations. A collision would be detected by comparing the next head position to the colour of the target location. If that colour was white then collision would be positive. The head would be drawn and tail erased as normal. This might also fix the game bugging when the snake gets to a certain length, and make the speed consistent. White would be need to be removed as a possible apple colour.

@Joker-vD commented on Oct 8, 2019
@grobda How would you update the snake without storing the adjacency information? Look at these two snakes:

 ┏━━━>       ┏┓┏━>
 ┗━┓         ┃┃┃
━━━┛        ━┛┗┛
Both of them have 3x3 solid block in the middle, and their heads (and tails) look in the same directions. And yet, as they move, you would need to somehow tell them apart to correctly erase that 3x3 block of pixels.

@wkjagt commented on Oct 8, 2019
@cjoudrey do you know the answer to this?

@yevrah commented on Oct 14, 2019 • 
I was thinking the same as @grobda.

Playing around with the colors I noticed that they repeat when overflowing. So black, white, ..., light grey ($0, $1, ..., $f) overflow so that black can be $10 (which comes after $f), and white can be $11, $21, and $31 . From this, we get enough whites to encode the direction of the next segment into each pixel, which allows for some memory saving shortcuts.

We only need to store the location of the tail segment.
Before we remove a tail segment we need to calculate the position of the next segment based on the white value and store this back for the next iteration.
Checking for collisions should be updated to see if the next segment lands on a black pixel - otherwise you would need to compare against 4 types of whites in the current implementation.
We don't have to worry too much about the apple as it is handled before the snake collision test.
In essence, we are creating a linked list of directions and popping the last value when removing the tail. Having said that, this is purely an exercise in minimizing the memory footprint. The original method remains as a good teaching tool and maybe more valid when creating a real game with more features.
