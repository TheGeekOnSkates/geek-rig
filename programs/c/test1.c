#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <peekpoke.h>

void main() {
	uint8_t key;
	while(true) {
		key = PEEK(512);
		POKE(512, 7);
		POKE(513, 5);
		POKE(514, 5);
		POKE(515, 11);
		POKE(530, key);
	}
}