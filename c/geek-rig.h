#ifndef _GEEK_RIG_H
#define _GEEK_RIG_H

#include <stdint.h>
#include <stdbool.h>
#include <peekpoke.h>

#define PutChar(n) POKE(0xF001L, n);
#define GetKey() PEEK(0xF000L)

uint8_t GetChar() {
	uint8_t key;
	while(true) {
		key = GetKey();
		if (key) return key;
	}
}

void Print(char* string) {
	while(string[0] != '\0') {
		PutChar(string[0]);
		string++;
	}
}

void ReadLine(char* buffer, uint8_t bufferSize) {
	static uint8_t i;
	for (i=0; i<bufferSize-1; i++) {
		buffer[i] = GetChar();
		buffer[i+1] = '\0';
		PutChar(buffer[i]);
		if (buffer[i] == 10) return;
	}
}



#endif

