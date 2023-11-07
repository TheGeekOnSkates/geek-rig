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
		if (buffer[i] == 8) {
			// do I need to print something?
			if (i) i--;
			continue;
		}
	}
}

/**
 * Runs an extermal program/command
 * @param[in] The program to run
 * @remarks This is where a lot of the "magic" happens.  With this, you're
 * really programming a "6502 in the Matrix".  Now you can truly harness
 * all the full power of a Linux terminal from a 6502 emulator. :-)
 */
void Run(const char* program) {
	// Copy the pointer into 0xF002-03 (GEEK_RIG_SYSTEM_LO/HI)
	uint16_t address = (uint16_t)program;
	POKE(0xF002, address % 256);
	POKE(0xF003, address / 256);
	
	// Set the GEEK_RIG_SYSTEM_STATUS bit to run the command
	POKE(0xF004, 1);
}




#endif

