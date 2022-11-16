# Current status

I'm seriously considering skipping to the "finishing touches" section below;
the 4000 works.  I can compile and run software for it.  You could fork this
right now and (from reading the comments in my header and .asm files) start to
use it.  But before I move on to the 8000, there are a few things I want to try:

* Finish the kernel - this has actually been more fun than building games (which is weird, but I'm cool w/that) :)
* Use the kernel to create a text based game (maybe a "Mad Libs" game I can go on to port to other 6502's :))
* Finish Tic-Tac-Tie.  I've made great progress, but just got tired of it. :)
* Keep trying on cc65.  Seriously thinking about reaching out on a forum about this.
* Get it working on the Pi 1 and on Termux; maybe include binaries in the project for that.
* Write docs - at least show the memory map, supported disk statuses, etc. like in the header file.
* THEN it's time to start on the 8000. :)



============================================================================

# TO-DO'S

## Tic-Tac-Tie

* Code a PLAYER_TURN subroutine
* Code a CPU_TURN subroutine
* Actually set it up so the player goes, then the CPU goes
* Set it up so who goes first is random
* When the game ends, code little messages like "You tied.  Again.  There's a big shock." or "Holy smokes!  You actually won!" etc. followed by "press any key to play again."

## The Geek-Rig itself just needs disk writing

MM_BUFFER_START is not really what I initially thought it would be.
It's a pointer to a NULL-terminated string, the NAME of the file to load/save.
I should rename it to MM_DISK_FILE_NAME or something.

For writing, I'll need four bytes: 2 for the start of the area to write,
and 2 for the end.  I can't really do a NULL-terminated string like the file
name, because BRK (a.k.a 0, a.k.a. char code for NULL) is an instruction I
might find in the middle of a chunk of data I want to save (i.e. saving multiple strings).

Also, I don't think I'm going to have an "append mode vs. overwrite mode".
Until I have an actual "disk" structure, supporting multiple files, there's
really no point in that (and even then I think I could do better).  Thoughts
for the 8000, when I get there.

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

* Get it running on the Raspberry Pi 1 - It runs on the Pi 3, but what's it like on a REALLY pared-down, terminal-only Pi 1?
* Get it running on Termux
* WTFM :)

**Then, if all goes as planned, move on to the GEEK-RIG 8000!**
