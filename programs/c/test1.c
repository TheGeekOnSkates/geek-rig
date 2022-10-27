#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <peekpoke.h>
#include "geekrig4000.h"

void main() {
	// Declare variables (cuz cc65 is awesome about being super-retro...
	// What was it, the K&R that required it be done this way?) :)
	uint8_t key;

	// Print the word "GEEK" on the screen, just cuz :)
	POKE(SCREEN, 7);
	POKE(SCREEN + 1, 5);
	POKE(SCREEN + 2, 5);
	POKE(SCREEN + 3, 11);

	while(true) {
		// Put randomness after "GEEK", lol
		POKE(SCREEN + 4, RANDOM());
		
		/*
		// Put the current key pressed after that
		// For some reason, this doesn't work.
		// Finish Viper first, and then come back.
		key = PEEK(KEY);
		POKE(SCREEN + 5, key);
		
		// This had the same result; key is always zero
		// (an "@" character is drawn here).  Yup, wait
		// till Viper is done.  That way I KNOW it's not
		// another bug in the Geek-Rig itself. :)
		key = KEY();
		if (key != 0)
			break;
		POKE(SCREEN + 7, key);
		*/
	}
}
