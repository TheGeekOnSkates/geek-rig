// Program:				The Geek-Rig
// Description:			An 8-bt virtual machine for the Linux terminal
// Version:				1.0
// Author:				The Geek on Skates
// License:				My code: The Unlicense
//						MCS6502: "MIT Licence: With Attribution"
//						https://github.com/bzotto/MCS6502
//						(hope I'm doing this right, Ben Zotto wrote it.
//						Sorry, code monkey != legal beagle lol)
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
// GLOBAL VARIABLES & COMPILE-TIME CONSTANTS (MACROS)
// ======================================================================

// For now just the one, the full 64K of memory (technically both RAM
// and ROM... but I just called it "ram" to save some typing :-D)
uint8 ram[65536];

// The memory map as we know it:
// Zero-page							= 0x0000 to 0x00FF
// Stack								= 0x0100 to 0x01FF
// User code							= 0x0200 to ????
#define GEEK_RIG_STDIN	0xF000
#define GEEK_RIG_STDOUT	0xF001
// Pointer to where PC goeson reset		= 0xFFFC to 0xFFFD
// Unknown, but preobably used			= 0xFFFE to 0xFFFF



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
	newSettings.c_cc[VMIN] = 0;
    newSettings.c_cc[VTIME] = 0;
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
		tcsetattr(STDIN_FILENO, TCSANOW, &oldSettings);
		return 0;
	}
	
	// Run the file
	input = fopen(argv[1], "rb");
	if (input == NULL) {
		perror("Error opening input file");
		tcsetattr(STDIN_FILENO, TCSANOW, &oldSettings);
		return 0;
	}
	// Read the file into memory starting at 0x0200
	while(!feof(input) && !ferror(input)) {
		(void)fread(&c, 1, 1, input);
		if (ferror(input)) break;
		if (i + 1 >= 65536 - 0x0200) {
			printf("Error loading input file: file is too big\n");
			(void)fclose(input);
			tcsetattr(STDIN_FILENO, TCSANOW, &oldSettings);
			return 0;
		}
		ram[0x0200 + i] = c;
		i++;
	}
	
	// Close the file and print an error if one came up
	(void)fclose(input);
	if (ferror(input)) {
		perror("Error opening input file");
		tcsetattr(STDIN_FILENO, TCSANOW, &oldSettings);
		return 0;
	}
	
	// Set up the 6502
	MCS6502Init(&context, OnRead, OnWrite, NULL);
	MCS6502Reset(&context);
	
	// Main event loop
	tcsetattr(STDIN_FILENO, TCSANOW, &newSettings);	
	while(true) {
		
		// Run the next instruction
		MCS6502ExecNext(&context);
		
		// Read keyboard input
		if (read(STDIN_FILENO, &c, 1) == 1)
			ram[GEEK_RIG_STDIN] = c;
		else ram[GEEK_RIG_STDIN] = 0;
		if (c == 'q') break;
		/*
		LEFT OFF HERE: This little experiment shows that the limiting
		factor, the thing that is making my Assembly program so slow,
		may be some other kind of delay in read()...
		My new Assembly code works, but it only seems to register
		every 4-5 key presses.  But the 6502 is not being slow.  If I
		comment out the line (about 10 lines down):
		
			ram[GEEK_RIG_STDOUT] = 0;
		
		Then the screen gets flooded with whatever character I type.  But
		even then, it takes time for the character I type to get picked
		up (I have to press it 3-4 times).  So the 6502 is printing the
		character at that memory address CRAZY-fast.  So it's not the CPU.
		It definitely seems to be the read() calls... Maybe I don't have
		to call read() every time?  Either way, I've ruled out 
		*/
	
		else if (c == 'r' || c == 'e') {
			(void)write(STDOUT_FILENO, &c, 1);
			c = 0;
		}
		
		// Print the value at standard output
		if (ram[GEEK_RIG_STDOUT]) {
			(void)write(STDOUT_FILENO, ram + GEEK_RIG_STDOUT, 1);
			ram[GEEK_RIG_STDOUT] = 0;
		}
	}
	
	// Reset the terminal settings to what they were before
	tcsetattr(STDIN_FILENO, TCSANOW, &oldSettings);
	printf("\033c\x1b[0m");
	
	// And we're done
	return 0;
}

