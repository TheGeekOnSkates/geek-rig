#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <peekpoke.h>
#include <string.h>
#include "../../system/geekrig4000.h"

int main() {
	// Declare variables
	uint8_t rows = PEEK(ROWS);
	uint8_t columns = PEEK(COLUMNS);

	// Weird bug: Why are both of these variables zero?
	POKE(SCREEN, rows);
	POKE(SCREEN + 1, columns);

	// It's clearly not a problem with the Geek-Rig, because...
	POKE(SCREEN + 2, PEEK(ROWS));		// Gives me 24, as it should
	POKE(SCREEN + 3, PEEK(COLUMNS));	// Gives me 40, as it should

	// Whatever it is, this didn't help either.
	// Same result with or without the while-loop.
	// Probably because I haven't cracked cc65's
	// insane config-language and just went with
	// -t none... maybe someday, when I understand
	// all binary formats, in ones and zeroes, in
	// my sleep, I'll be able to depuzzle their
	// wacky syntax and minimalist explanations,
	// and actually work the magic-bordering-on-
	// miracle that would be adding the Geek-Rig
	// (by then a highly advanced model beyond my
	// wildest dreams) as a legit build target.
	while(true) {
		rows = PEEK(ROWS);
		columns = PEEK(COLUMNS);
		POKE(SCREEN, rows);
		POKE(SCREEN + 1, columns);
		POKE(SCREEN + 5, PEEK(KEY));	// Just to confirm the while-loop works :)
	}
	return 0;
}
