// -------------------------------------------------------------------------
// DEPENDENCIES
// -------------------------------------------------------------------------

// Standard C stuff
#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include <locale.h>
#include <errno.h>
#include <time.h>

// Libraries
#include <ncurses.h>
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

// Screen width
#define MM_COLUMNS 1472

// Screen height
#define MM_ROWS 1473

// Current key pressed
#define MM_KEY 1474

// Random number generator
#define MM_RANDOM 1475

// Clock (just counts seconds)
#define MM_CLOCK 1476

// Pointer to start of file read/write string
#define MM_DISK_FILENAME 1477

// Pointer to start of read/write buffer
#define MM_DISK_BUFFER_START 1479

// Pointer to end of read/write buffer
#define MM_DISK_BUFFER_END 1481

// Disk drive status and character set:
#define MM_DISK_STATUS 1483

// Start of user code
#define MM_USER 1484


// -------------------------------------------------------------------------
// OTHER MACROS
// -------------------------------------------------------------------------

// Disk drive instructions (stored in MM_DISK_STATUS)
// The structure of this byte is as follows:
//		- Bits 0-4 (numbers 0-31) are disk drive statuses (see below)
//		- Bits 5-6 are DISK_READ, DISK_WRITE, or DISK_APPEND, defined here
//		- Bit 7 changes which character set is used - unrelated, I know, but if the VIC-20 can store colors and sound volume in the same byte than what the puck. :)
#define DISK_READ		0b00100000
#define DISK_WRITE		0b01000000
#define DISK_APPEND		0b01100000

// Disk drive statuses
#define DISK_READING					1
#define DISK_WRITING					2
#define DISK_APPENDING					3
#define DISK_ERROR_UNKNOWN				4
#define DISK_ERROR_NULL_STRING			5
#define DISK_ERROR_FILE_NOT_FOUND		6
#define DISK_ERROR_ACCESS_DENIED		7
#define DISK_ERROR_RESOURCE_UNAVAILABLE	8
#define DISK_ERROR_BUSY					9
#define DISK_ERROR_FILE_TOO_BIG			10
#define DISK_ERROR_IS_FOLDER			11
#define DISK_ERROR_INTERRUPTED			12
#define DISK_ERROR_OUT_OF_MEMORY		13
#define DISK_ERROR_READ_ONLY_FS			14
#define DISK_ERROR_NOT_PERMITTED		16
// I can fit up to 16 more (31 is the highest disk status / disk error)
// But for now this is plenty, and more than I expected :)

// For now, start with 4 KB of RAM
#define RAM_MAX 4096


// -------------------------------------------------------------------------
// GLOBAL VARIABLES
// -------------------------------------------------------------------------

uint8_t ram[RAM_MAX];



// -------------------------------------------------------------------------
// DECLARATIONS (because {ancient language reasons}) :)
// -------------------------------------------------------------------------

void updateDisplay(void);
void updateDiskDrive(MCS6502ExecutionContext* context);


// -------------------------------------------------------------------------
// 6502 SIMULATOR CALLBACKS
// -------------------------------------------------------------------------

uint8 OnRead(uint16 address, void* readWriteContext) {
	if (address >= RAM_MAX) return 0;
	if (address == MM_RANDOM) return rand() % 256;
	if (address == MM_ROWS) {
		ram[address] = getmaxx(stdscr);
		return ram[address];
	}
	if (address == MM_COLUMNS) {
		ram[address] = getmaxy(stdscr);
		return ram[address];
	}
	if (address == MM_KEY) {
		int key = getch();
		if (key == -1)
			key++;
		else if (key >= 97 && key <= 122)
			key -= 96;
		ram[MM_KEY] = 0;
		return key;
	}
	return (uint8)ram[address];
}

void OnWrite(uint16 address, uint8 byte, void* readWriteContext) {
	if (address < RAM_MAX)
		ram[address] = byte;
	if (address == MM_DISK_STATUS)
		updateDiskDrive((MCS6502ExecutionContext*)readWriteContext);
}


// -------------------------------------------------------------------------
// TO BE SORTED
// -------------------------------------------------------------------------

void updateDisplay() {
	// If the high bit of MM_DISK_STATUS is on, use the lowercase character set
	if (ram[MM_DISK_STATUS] & 128) {
		for (int i=0; i<24; i++) {
			if (i == MM_ROWS) break;
			move(i, 0);
			for (int j=0; j<40; j++) {
				if (j == MM_COLUMNS) break;
				int x = (int)ram[MM_SCREEN + j + (i * 40)];
				if (x > 127) {
					x -= 128;
					attron(A_REVERSE);
				}
				else attroff(A_REVERSE);
				printw("%lc", CHARSET_LOWER[x]);
			}
		}
		return;
	}

	// Otherwise, use the uppercase character set
	for (int i=0; i<24; i++) {
		move(i, 0);
		for (int j=0; j<40; j++) {
			int x = (int)ram[MM_SCREEN + j + (i * 40)];
			if (x > 127) {
				x -= 128;
				attron(A_REVERSE);
			}
			else attroff(A_REVERSE);
			printw("%lc", CHARSET_UPPER[x]);
		}
	}
}

/**
 * Gets a string (ASCII, not Unicode... yet) stored in RAM
 * @param[in] Memory address of the start of the string
 * @param[in] A string of RAM_MAX bytes length
 */
void getStringAt(uint16_t pointer, char* buffer) {
	uint16_t i, address = ram[pointer] + (ram[pointer + 1] * 256);
	for (i=0; i<RAM_MAX - 1; i++) {
		buffer[i] = (char)ram[address + i];
		buffer[i + 1] = '\0';
		if ((char)ram[address + i] == 0) break;
	}
}

void setDiskError() {
	if (errno == ENOENT)
		ram[MM_DISK_STATUS] |= DISK_ERROR_FILE_NOT_FOUND;
	else if (errno == EACCES)
		ram[MM_DISK_STATUS] |= DISK_ERROR_ACCESS_DENIED;
	else if (errno == EAGAIN)
		ram[MM_DISK_STATUS] |= DISK_ERROR_RESOURCE_UNAVAILABLE;
	else if (errno == EBUSY)
		ram[MM_DISK_STATUS] |= DISK_ERROR_BUSY;
	else if (errno == EFBIG)
		ram[MM_DISK_STATUS] |= DISK_ERROR_FILE_TOO_BIG;
	else if (errno == EISDIR)
		ram[MM_DISK_STATUS] |= DISK_ERROR_IS_FOLDER;
	else if (errno == EINTR)
		ram[MM_DISK_STATUS] |= DISK_ERROR_INTERRUPTED;
	else if (errno == ENOMEM)
		ram[MM_DISK_STATUS] |= DISK_ERROR_OUT_OF_MEMORY;
	else if (errno == EROFS)
		ram[MM_DISK_STATUS] |= DISK_ERROR_READ_ONLY_FS;
	else if (errno == EPERM)
		ram[MM_DISK_STATUS] |= DISK_ERROR_NOT_PERMITTED;
	else ram[MM_DISK_STATUS] |= DISK_ERROR_UNKNOWN;
}

void updateDiskDrive(MCS6502ExecutionContext* context) {
	if (ram[MM_DISK_STATUS] & DISK_READ) {
		ram[MM_DISK_STATUS] &= ~DISK_READ;
		ram[MM_DISK_STATUS] |= DISK_READING;
		char path[RAM_MAX];
		memset(path, 0, RAM_MAX);
		getStringAt(MM_DISK_BUFFER_START, path);
		if (path[0] == '\0') {
			ram[MM_DISK_STATUS] &= ~DISK_READING;
			ram[MM_DISK_STATUS] |= DISK_ERROR_NULL_STRING;
			return;
		}
		FILE* file = fopen(path, "rb");
		if (file == NULL) {
			ram[MM_DISK_STATUS] &= ~DISK_READING;
			setDiskError();
			return;
		}
		uint16_t i = 0;
		uint8_t byte;
		while(!feof(file) && !ferror(file)) {
			fread(&byte, 1, 1, file);
			if (ferror(file)) {
				ram[MM_DISK_STATUS] &= ~DISK_READING;
				// Again, handle error codes
				break;
			}
			ram[i] = byte;
			i++;
		}
		fclose(file);
		ram[MM_DISK_STATUS] &= ~DISK_READING;
		context->pc = MM_USER;
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
	// For debugging
	// mvprintw(2, 41, "Disk status: %d", ram[MM_DISK_STATUS]);
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
	timeout(1);	// Play with this as needed

	// Test - load a file
	// FIrst, put the name of the file into RAM, like a program would
	const char* path = "./programs/asm/test1.rig\0";
	for (size_t i=0; i<strlen(path); i++) {
		ram[4000 + i] = (uint8_t)path[i];
	}
	// Then, tell the disk drive where the file name is in memory
	ram[MM_DISK_BUFFER_START] = 0xA0;
	ram[MM_DISK_BUFFER_START + 1] = 0x0F;

	bool testRunning = false;
	ram[MM_COLUMNS] = getmaxx(stdscr);
	ram[MM_ROWS] = getmaxy(stdscr);
	
	// Main event loop
	while(true) {

		// Update the display
		updateDisplay();
		
		// Update the clock
		ram[MM_CLOCK] = (clock() - start) / CLOCKS_PER_SEC;
		
		// Run the next 6502 instruction
		MCS6502ExecNext(&cpu);

		// Tell the disk drive to read (well, to read as soon as the loop below starts)
		if (!testRunning) {
			OnWrite(MM_DISK_STATUS, DISK_READ, &cpu);
			testRunning = true;
		}
	}
	endwin();
	return 0;
}
