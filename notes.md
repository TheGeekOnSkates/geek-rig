# TO-DO'S

## The Geek-Rig itself

* Get disk writing working (test by setting high scores)
* The more I work on Viper, the more I wish I had some kind of debugger.  Maybe add a -d command-line option.
* Set it up so you can pass a game as a command-line option too

## Viper

* Set up the snake's head - get it to respond to key presses etc.
* Set up the snake's body - get it to follow the head
* I'm thinking of adding a visible wall - makes the collision-checking easier and adds a place to put the score
* Set up the collision-checking with walls and apples (oh yeah, and set up the score) 🤣
* There's a minor bug in CREATE_APPLE: because the low byte has a max of $BF, there are some places where an apple can never appear.  Fix it if it's noticeable at the end. :)
* When is playable, polish it up:
	- Set it up so it shows the player's score and the high score
	- Add a high score screen (use that to get disk writing working) - make sure to credit the sites that helped me out :)

## Other games

Find and port open-source 6502 games like:

* Tetris
* Space Invaders.
* Breakout

And code a simple text-based game in C.  Not Darkest Hour big (not enough RAM yet, lol), more like a Mad Libs type game. :)

## The finishing touches

* Set it up so players can pass in the name of the game as a command-line option.  Probably the easiest way for now.
* Write some docs explaining how play the games, and how to code for the FINISHED Geek-Rig 4000.
