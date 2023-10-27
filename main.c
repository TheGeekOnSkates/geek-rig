// Program:				The Geek-Rig
// Description:			An 8-bt virtual machine for the Linux terminal
// Version:				1.0
// Author:				The Geek on Skates
// License:				To Be Decided
//
// ======================================================================
// DEPENDENCIES
// ======================================================================

// Standard C stuff
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

// The awesome 6502 emulator library I'm using
#include "MCS6502.h"

// Some Linux-only stuff
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>



// ======================================================================
// GLOBAL VARIABLES
// ======================================================================

// For now just the one, the full 64K of memory (technically both RAM
// and ROM... but I just called it "ram" to save some typing :-D)
uint8 ram[65536];



// ======================================================================
// FUNCTIONS
// ======================================================================

/**
 * MCS6502 callback that runs when it reads data
 * @param[in] The memory address being read
 * @param[in] Not used (yet)
 * @todo Once I learn how RAM "banking" works on real 6502s, if I decide
 * I want more than 64 KB of RAM (which I probably will, lol), set this up
 * to write to whichever bank is currently selected.
 */
uint8 OnRead(uint16 address, void* context) {
	// But for now, it's easy cheesy:
	return ram[address];
}

/**
 * MCS6502 callback that runs when it write data
 * @param[in] The memory address being written to
 * @param[in] The data to write there
 * @param[in] Not used (yet)
 */
void OnWrite(uint16 address, uint8 value, void* readWriteContext) {
	// POKE address, value (or LDA #value, STA address) :-)
	ram[address] = value;
	
	// Print the value at address 0xF000
	if (ram[0xF000]) {
		printf("%c", ram[0xF000]);
		ram[0xF000] = 0;
	}
}

/**
 * The program starts here
 * @param[in] The number of command-line parameters
 * @param[in] The command-line parameters
 * @returns Zero unless the underlying OS says otherwise.
 */
int main(int argc, const char** argv) {
	// Declare variables
	MCS6502ExecutionContext context;
	char c;
	struct termios newSettings, oldSettings;
	FILE* input = NULL;
	uint16_t i = 0;
	
	// Set up non-blocking getchar()
	tcgetattr(STDIN_FILENO, &newSettings);
	oldSettings = newSettings;
	newSettings.c_lflag &= ~(ICANON | ECHO);
	newSettings.c_cc[VMIN] = 1;
	tcsetattr(STDIN_FILENO, TCSANOW, &newSettings);	

	// Set all memory to zeroes
	memset(ram, 0, 65536);
	
	// For now, start the PC at 0x0200.
	// The actual memory map is a work in progress, so I expect to be
	// writing a lot of machine code there...
	ram[0xFFFC] = 0x00;
	ram[0xFFFD] = 0x02;
	
	// Make sure I passed a file
	if (argc != 2) {
		printf("Usage: geek-rig inputFile.rig\n");
		return 0;
	}
	
	// Run the file
	input = fopen(argv[1], "rb");
	if (input == NULL) {
		perror("Error opening input file");
		return 0;
	}
	// Read the file into memory starting at 0x0200
	while(!feof(input) && !ferror(input)) {
		(void)fread(&c, 1, 1, input);
		if (ferror(input)) break;
		if (i + 1 >= 65536 - 0x0200) {
			printf("Error loading input file: file is too big\n");
			(void)fclose(input);
			return 0;
		}
		ram[0x0200 + i] = c;
		printf("%02x (%c), ", ram[0x0200 + i], ram[0x0200 + i]);
		i++;
	}
	(void)fclose(input);
	if (ferror(input)) {
		perror("Error opening input file");
		return 0;
	}
	
	// Set up the 6502
	MCS6502Init(&context, OnRead, OnWrite, NULL);
	MCS6502Reset(&context);
	
	// Main event loop
	while(true) {
		// Experiment
		c = 0;
		(void)read(STDIN_FILENO, &c, 1);
		if (c) {
			printf("%d %c\n", c, c);
			if (c == 'q') break;
		}
		fflush(stdout);
		
		// Run the next instruction
		MCS6502ExecNext(&context);
	}
	
	// Reset the terminal settings to what they were before
	tcsetattr(STDIN_FILENO, TCSANOW, &oldSettings);
	printf("\033c\x1b[0m");
	
	// And we're done
	return 0;
}

