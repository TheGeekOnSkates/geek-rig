// -------------------------------------------------------------------------
// DEPENDENCIES
// -------------------------------------------------------------------------

#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <locale.h>
#include <ncurses.h>
#include <time.h>
#include "MCS6502.h"


// -------------------------------------------------------------------------
// COMPILE-TIME CONSTANTS
// -------------------------------------------------------------------------

const wchar_t *CHARSET_UPPER = L"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]↑← !\"#$%&'()*+,-./0123456789:;<=>?─♠🭲🭸🭷🭶🭺🭱🭴╮╰╯🭼╲╱🭽🭾•🭻♥🭰╭╳○♣🭵♦┼🮌│π◥ ▌▄▔▁▏▒▕🮏◤🮇├▗└┐▂┌┴┬┤▎▍🮈🮂🮃▃🭿▖▝┘▘▚";
const wchar_t *CHARSET_LOWER = L"@abcdefghijklmnopqrstuvwxyz[\\]↑← !\"#$%&'()*+,-./0123456789:;<=>?─ABCDEFGHIJKLMNOPQRSTUVWXYZ┼🮌│🮖🮘 ▌▄▔▁▏▒▕🮏🮙🮇├▗└┐▂┌┴┬┤▎▍🮈🮂🮃▃✓▖▝┘▘▚";


// -------------------------------------------------------------------------
// MEMORY MAP MACROS
// -------------------------------------------------------------------------

// Zero-page
#define MM_ZP 0

// 	6502 stack
#define MM_STACK 256 

// Screen RAM (40x24)
#define MM_SCREEN 512

// Current key pressed
#define MM_KEY 1472

// Random number generator
#define MM_RANDOM 1473

// Clock (just counts seconds)
#define MM_CLOCK 1474

// Pointer to start of file read/write string
#define MM_DISK_FILENAME 1475

// Pointer to start of read/write buffer
#define MM_DISK_BUFFER_START 1477

// Pointer to end of read/write buffer
#define MM_DISK_BUFFER_END 1479

// Disk drive status and character set:
#define MM_DISK_STATUS 1481

// Start of user code
#define MM_USER 1482


// -------------------------------------------------------------------------
// OTHER MACROS
// -------------------------------------------------------------------------

// Disk drive instructions (stored in MM_DISK_STATUS)
#define DISK_READ		0b00100000
#define DISK_WRITE		0b01000000
#define DISK_APPEND		0b01100000

// Disk drive statuses
#define DISK_READING	1
#define DISK_WRITING	2
#define DISK_APPENDING	3

// For now, start with 4 KB of RAM
#define RAM_MAX 4096


// -------------------------------------------------------------------------
// GLOBAL VARIABLES
// -------------------------------------------------------------------------

uint8_t ram[RAM_MAX];


// -------------------------------------------------------------------------
// 6502 SIMULATOR CALLBACKS
// -------------------------------------------------------------------------

uint8 OnRead(uint16 address, void * readWriteContext) {
	if (address >= RAM_MAX) return 0;
	return (uint8)ram[address];
}

void OnWrite(uint16 address, uint8 byte, void * readWriteContext) {
	if (address < RAM_MAX)
		ram[address] = byte;
}


// -------------------------------------------------------------------------
// TO BE SORTED
// -------------------------------------------------------------------------

void updateDisplay() {
	for (int i=0; i<24; i++) {
		move(i, 0);
		for (int j=0; j<40; j++) {
			int x = (int)ram[MM_SCREEN + j + (i * 40)];
			printw("%lc", CHARSET_UPPER[x]);
		}
	}
}

void updateDiskDrive() {
	if (ram[MM_DISK_STATUS] & DISK_READ) {
		ram[MM_DISK_STATUS] &= ~DISK_READ;
		ram[MM_DISK_STATUS] |= DISK_READING;
		// to-do: Read the file
	}
	else if (ram[MM_DISK_STATUS] & DISK_WRITE) {
		ram[MM_DISK_STATUS] &= ~DISK_WRITE;
		ram[MM_DISK_STATUS] |= DISK_WRITING;
		// to-do: Overwrite the file
	}
	else if (ram[MM_DISK_STATUS] & DISK_APPEND) {
		ram[MM_DISK_STATUS] &= ~DISK_APPEND;
		ram[MM_DISK_STATUS] |= DISK_APPENDING;
		// to-do: append to the file
	}
}

int main() {
	setlocale(LC_ALL, "");
	srand(time(NULL));
	clock_t start = clock();

	// Set up the 6502
	MCS6502ExecutionContext cpu;
	MCS6502Init(&cpu, OnRead, OnWrite, NULL);
	MCS6502Reset(&cpu);

	// Set all the screen RAM to 32 (a space character)
	for (int i=MM_SCREEN; i<MM_KEY; i++) ram[i] = 32;

	// Set up ncurses
	initscr();
	clear();
	curs_set(0);
	noecho();
	nocbreak();
	noraw();
	timeout(100);	// Play with this as needed

	while(true) {
		// Update the current key pressed
		int key = getch();
		if (key == -1) key = 255;
		ram[MM_KEY] = key;

		// If the program wants to read or write anything, do that
		updateDiskDrive();

		// Update the display
		updateDisplay();
		
		// Update the clock
		ram[MM_CLOCK] = (clock() - start) / CLOCKS_PER_SEC;
		
		// Update the random number generator
		ram[MM_RANDOM] = rand() % 256;

		// Run the next 6502 instruction
		MCS6502ExecNext(&cpu);
	}
	endwin();
	return 0;
}
