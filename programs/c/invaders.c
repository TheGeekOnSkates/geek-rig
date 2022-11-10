#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <peekpoke.h>
#include <string.h>
#include "../../system/geekrig4000.h"

void main() {
	// Same problem... it won't let me store data in variables
	uint8_t key;
	while(true) {
		key = PEEK(KEY);
		POKE(SCREEN, key);
		POKE(SCREEN + 1, PEEK(KEY));
	}
	
	/*
	// Same problem here as well... why can't you set variables?
	uint8_t i;
	for (i = 0; i<3; i++) {
		POKE(SCREEN + i, 160);
	}
	*/
}
