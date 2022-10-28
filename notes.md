# TO-DO'S

## The Geek-Rig itself

* Get disk writing working (test by setting high scores)
* The more I work on Viper, the more I wish I had some kind of debugger.  Maybe add a -d command-line option.
* Set it up so you can pass a game as a command-line option too

## Viper

* I'd kind of like to skip ahead to DRAW_SNAKE, just so I can make sure my keyboard-reading code works (cuz ASCII != PETSCII)
* Set up the collision-checking with walls and apples (oh yeah, and set up the score) 🤣
* Set up the snake's head - get it to respond to key presses etc.
* Set up the snake's body - get it to follow the head
* Add the high score screen (use that to get disk writing working) - make sure to credit the sites that helped me out :)
* There's a minor bug in CREATE_APPLE: because the low byte has a max of $BF, there are some places where an apple can never appear.  Fix it if it's noticeable at the end. :)

## Other games

Find and port open-source 6502 games like:

* Tetris
* Space Invaders.
* Breakout

And code a simple text-based game in C.  Not Darkest Hour big (not enough RAM yet, lol), more like a Mad Libs type game. :)

## The finishing touches

* Get it running on the Raspberry Pi 1
* Get it running on Termux (probably won't look right on mine cuz I got the text huge)
* WTFM :)

**Then, if all goes as planned, move on to the GEEK-RIG 8000!**
