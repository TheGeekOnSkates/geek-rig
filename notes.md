# TO-DO'S

## The Geek-Rig itself just needs some work on the disk drive

A few notes on this:

MM_BUFFER_START is not really what I initially thought it would be.
It's a pointer to a NULL-terminated string, the NAME of the file to load/save.
I should rename it to MM_DISK_FILE_NAME or something.

For writing, I'll need four bytes: 2 for the start of the area to write,
and 2 for the end.  I can't really do a NULL-terminated string like the file
name, because BRK (a.k.a 0, a.k.a. char code for NULL) is an instruction I
might find in the middle of a program.

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

* Get it running on the Raspberry Pi 1
* Get it running on Termux (probably won't look right on mine cuz I got the text huge)
* WTFM :)

**Then, if all goes as planned, move on to the GEEK-RIG 8000!**
