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

// The 4000's memory map and other constants
#include "geekrig4000.h"


// -------------------------------------------------------------------------
// COMPILE-TIME CONSTANTS
// -------------------------------------------------------------------------

const wchar_t *CHARSET_UPPER = L"@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]↑← !\"#$%&'()*+,-./0123456789:;<=>?─♠🭲🭸🭷🭶🭺🭱🭴╮╰╯🭼╲╱🭽🭾•🭻♥🭰╭╳○♣🭵♦┼🮌│π◥ ▌▄▔▁▏▒▕🮏◤🮇├▗└┐▂┌┴┬┤▎▍🮈🮂🮃▃🭿▖▝┘▘▚";
const wchar_t *CHARSET_LOWER = L"@abcdefghijklmnopqrstuvwxyz[\\]↑← !\"#$%&'()*+,-./0123456789:;<=>?─ABCDEFGHIJKLMNOPQRSTUVWXYZ┼🮌│🮖🮘 ▌▄▔▁▏▒▕🮏🮙🮇├▗└┐▂┌┴┬┤▎▍🮈🮂🮃▃✓▖▝┘▘▚";

// For now, start with 4 KB of RAM
#define RAM_MAX 4096


// -------------------------------------------------------------------------
// GLOBAL VARIABLES
// -------------------------------------------------------------------------

uint8_t ram[RAM_MAX];
clock_t start;


// -------------------------------------------------------------------------
// DECLARATIONS (because {ancient language reasons}) :)
// -------------------------------------------------------------------------

void updateDisplay(void);
void updateDiskDrive(MCS6502ExecutionContext* context);


// -------------------------------------------------------------------------
// 6502 SIMULATOR CALLBACKS
// -------------------------------------------------------------------------

uint8 OnRead(uint16 address, void* context) {
	if (address >= RAM_MAX) return 0;
	if (address == CLOCK) return (clock() - start) / CLOCKS_PER_SEC;
	if (address == RANDOM) return rand() % 256;
	if (address == ROWS) {
		ram[address] = getmaxy(stdscr);
		if (ram[address] > 24) ram[address] = 24;
		return ram[address];
	}
	if (address == COLUMNS) {
		ram[address] = getmaxx(stdscr);
		if (ram[address] > 40) ram[address] = 40;
		return ram[address];
	}
	if (address == KEY) {
		int key = getch();
		if (key != -1) ram[KEY] = key;
	}
	return (uint8)ram[address];
}

void OnWrite(uint16 address, uint8 byte, void* context) {
	if (address < RAM_MAX)
		ram[address] = byte;
	if (address == DISK_STATUS)
		updateDiskDrive((MCS6502ExecutionContext*)context);
}


// -------------------------------------------------------------------------
// TO BE SORTED
// -------------------------------------------------------------------------

// Resets the geek-rig
void resetGeekRig(MCS6502ExecutionContext* cpu) {
	// Reset the 6502
	MCS6502Reset(cpu);

	// Reset the screen RAM
	for (int i=0; i<960; i++) ram[SCREEN + i] = 32;

	// Reset the rows and columns
	ram[COLUMNS] = getmaxx(stdscr);
	if (ram[COLUMNS] > 40) ram[COLUMNS] = 40;
	ram[ROWS] = getmaxy(stdscr);
	if (ram[ROWS] > 24) ram[ROWS] = 24;
}

void updateDisplay() {
	// If the high bit of DISK_STATUS is on, use the lowercase character set
	if (ram[DISK_STATUS] & 128) {
		for (int i=0; i<24; i++) {
			if (i > ROWS) break;
			move(i, 0);
			for (int j=0; j<40; j++) {
				if (j > COLUMNS) break;
				int x = (int)ram[SCREEN + j + (i * 40)];
				if (x > 127) {
					x -= 128;
					attron(A_REVERSE);
				}
				else attroff(A_REVERSE);
				printw("%lc", CHARSET_LOWER[x]);
			}
		}
		refresh();
		return;
	}

	// Otherwise, use the uppercase character set
	for (int i=0; i<24; i++) {
		if (i > ROWS) break;
		move(i, 0);
		for (int j=0; j<40; j++) {
			if (j > COLUMNS) break;
			int x = (int)ram[SCREEN + j + (i * 40)];
			if (x > 127) {
				x -= 128;
				attron(A_REVERSE);
			}
			else attroff(A_REVERSE);
			printw("%lc", CHARSET_UPPER[x]);
		}
	}
	refresh();
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

/** Sets the disk status byte to an error code */
void setDiskError() {
	if (errno == ENOENT)
		ram[DISK_STATUS] |= DISK_ERROR_FILE_NOT_FOUND;
	else if (errno == EACCES)
		ram[DISK_STATUS] |= DISK_ERROR_ACCESS_DENIED;
	else if (errno == EAGAIN)
		ram[DISK_STATUS] |= DISK_ERROR_RESOURCE_UNAVAILABLE;
	else if (errno == EBUSY)
		ram[DISK_STATUS] |= DISK_ERROR_BUSY;
	else if (errno == EFBIG)
		ram[DISK_STATUS] |= DISK_ERROR_FILE_TOO_BIG;
	else if (errno == EISDIR)
		ram[DISK_STATUS] |= DISK_ERROR_IS_FOLDER;
	else if (errno == EINTR)
		ram[DISK_STATUS] |= DISK_ERROR_INTERRUPTED;
	else if (errno == ENOMEM)
		ram[DISK_STATUS] |= DISK_ERROR_OUT_OF_MEMORY;
	else if (errno == EROFS)
		ram[DISK_STATUS] |= DISK_ERROR_READ_ONLY_FS;
	else if (errno == EPERM)
		ram[DISK_STATUS] |= DISK_ERROR_NOT_PERMITTED;
	else ram[DISK_STATUS] |= DISK_ERROR_UNKNOWN;
}

void updateDiskDrive(MCS6502ExecutionContext* context) {
	if (ram[DISK_STATUS] & DISK_READ) {
		ram[DISK_STATUS] &= ~DISK_READ;
		ram[DISK_STATUS] |= DISK_READING;
		char path[RAM_MAX];
		memset(path, 0, RAM_MAX);
		getStringAt(DISK_BUFFER_START, path);
		if (path[0] == '\0') {
			ram[DISK_STATUS] &= ~DISK_READING;
			ram[DISK_STATUS] |= DISK_ERROR_NULL_STRING;
			return;
		}
		FILE* file = fopen(path, "rb");
		if (file == NULL) {
			ram[DISK_STATUS] &= ~DISK_READING;
			setDiskError();
			return;
		}
		resetGeekRig(context);
		uint16_t i = USER;
		uint8_t byte;
		while(!feof(file) && !ferror(file)) {
			fread(&byte, 1, 1, file);
			if (ferror(file)) {
				ram[DISK_STATUS] &= ~DISK_READING;
				// Again, handle error codes
				break;
			}
			ram[i] = byte;
			i++;
		}
		fclose(file);
		ram[DISK_STATUS] = 0;
		context->pc = USER;
	}
	else if (ram[DISK_STATUS] & DISK_WRITE) {
		ram[DISK_STATUS] &= ~DISK_WRITE;
		ram[DISK_STATUS] |= DISK_WRITING;
		// to-do: Overwrite the file
	}
	else if (ram[DISK_STATUS] & DISK_APPEND) {
		ram[DISK_STATUS] &= ~DISK_APPEND;
		ram[DISK_STATUS] |= DISK_APPENDING;
		// to-do: append to the file
	}
	// For debugging
	// mvprintw(2, 41, "Disk status: %d", ram[DISK_STATUS]);
}

int main(int argc, const char** argv) {
	if (argc < 2 || argc > 3) {
		printf("GEEK-RIG 4000\n\n");
		printf("Usage: geekrig4000 [-d] game.rig\n");
		printf("    -d: print Assembly debug info to debug.tsv\n");
		printf("    game.rig: The game to load\n");
		return 0;
	}
	bool debugMode = false;
	const char* game;
	FILE* debugFile = NULL;
	uint16_t i;
	for (i=1; i<argc; i++) {
		if (strcmp(argv[i], "-d") == 0)
			debugMode = true;
		else game = argv[i];
	}

	// Set up some other stuff
	setlocale(LC_ALL, "");
	srand(time(NULL));
	start = clock();

	// Set up the 6502
	MCS6502ExecutionContext cpu;
	MCS6502Init(&cpu, OnRead, OnWrite, &cpu);
	resetGeekRig(&cpu);

	// Load the game
	debugFile = fopen(game, "rb");
	if (debugFile == NULL) {
		perror("Error loading game");
		return 0;
	}
	i = USER;
	uint8_t byte;
	while(!feof(debugFile) && !ferror(debugFile)) {
		fread(&byte, 1, 1, debugFile);
		if (ferror(debugFile)) {
			perror("Error reading game file");
			fclose(debugFile);
			return 0;
		}
		ram[i] = byte;
		i++;
	}
	fclose(debugFile);
	cpu.pc = USER;

	// Set up ncurses
	initscr();
	clear();
	curs_set(0);
	noecho();
	nocbreak();
	noraw();
	timeout(0);	// Play with this as needed

	// Open the debug file if the user wants one
	if (debugMode) {
		debugFile = fopen("debug.tsv", "w");
		if (debugFile == NULL) {
			perror("Error opening debug file");
			return 0;
		}
		
		// And write the column headers
		fprintf(debugFile, "A\tX\tY\tPC\tRAM\n");
	}
	
	// Main event loop
	while(true) {

		// Update the display
		updateDisplay();
		
		// Run the next 6502 instruction
		MCS6502ExecNext(&cpu);

		// Print debug info if debug mode is on
		if (!debugMode) continue;
		fprintf(debugFile, "$%02x\t$%02x\t$%02x\t$%04x\t$%02x\n", cpu.a, cpu.x, cpu.y, cpu.pc, ram[cpu.pc]);
	}
	fclose(debugFile);
	endwin();
	return 0;
}
