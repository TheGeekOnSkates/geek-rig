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
 * @returns Zero unless the underlying OS says otherwise.
 */
int main() {
	// Declare variables
	MCS6502ExecutionContext context;
	char c;
	struct termios newSettings, oldSettings;
	
	// Set up non-blocking getchar()
	tcgetattr(STDIN_FILENO, &newSettings);
	oldSettings = newSettings;
	newSettings.c_lflag &= ~(ICANON | ECHO);
	newSettings.c_cc[VMIN] = 1;
	tcsetattr(STDIN_FILENO, TCSANOW, &newSettings);	

	// Set all memory to zeroes
	memset(ram, 0, 65536);
	
	// For now, start the PC at 0x0900.
	// The actual memory map is a work in progress, so I expect to be
	// writing a lot of machine code there...
	ram[0xFFFC] = 0x00;
	ram[0xFFFD] = 0x09;
	
	// Experiment: Clear the screen, turn on reverse mode,
	// and print a letter (easier/shorter test lol)
	
	// Clear the screen
	ram[0x0900] = 0xA9;
	ram[0x0901] = 0x1B;		// LDA #$1B (Escape)
	ram[0x0902] = 0x8D;
	ram[0x0903] = 0x00;
	ram[0x0904] = 0xF0;		// STA $F000
	ram[0x0905] = 0xA9;
	ram[0x0906] = 'c';		// LDA #ASCII char 'c'
	ram[0x0907] = 0x8D;
	ram[0x0908] = 0x00;
	ram[0x0909] = 0xF0;		// STA $F000
	
	// Turn on reverse color mode
	ram[0x090A] = 0xA9;
	ram[0x090B] = 0x1B;		// LDA #$1B (Escape)
	ram[0x090C] = 0x8D;
	ram[0x090D] = 0x00;
	ram[0x090E] = 0xF0;		// STA $F000
	ram[0x090F] = 0xA9;
	ram[0x0910] = '[';
	ram[0x0911] = 0x8D;
	ram[0x0912] = 0x00;
	ram[0x0913] = 0xF0;
	ram[0x0914] = 0xA9;
	ram[0x0915] = '7';
	ram[0x0916] = 0x8D;
	ram[0x0917] = 0x00;
	ram[0x0918] = 0xF0;
	ram[0x0919] = 0xA9;
	ram[0x091A] = 'm';
	ram[0x091B] = 0x8D;
	ram[0x091C] = 0x00;
	ram[0x091D] = 0xF0;
	ram[0x091E] = 0xA9;
	ram[0x091F] = 'A';
	ram[0x0920] = 0x8D;
	ram[0x0921] = 0x00;
	ram[0x0922] = 0xF0;
	
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

