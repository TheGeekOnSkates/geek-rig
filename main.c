#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "MCS6502.h"

uint8 ram[65536];

uint8 OnRead(uint16 address, void* readWriteContext) {
	return ram[address];
}

void OnWrite(uint16 address, uint8 value, void* readWriteContext) {
	ram[address] = value;
	// The experiment below - worked :-)
	printf("Address #1234 = %2x, address #5678 = $%4x\n", ram[0x1234],
		ram[0x5678]);
}


int main() {
	MCS6502ExecutionContext context;
	memset(ram, 0, 65536);
	
	// Experiment - start the PC at 0x0900; and at that location,
	// we'll write some machine code (cuz we're cool like that) :-D
	ram[0xFFFC] = 0x00;
	ram[0xFFFD] = 0x09;
	ram[0x0900] = 0xA9;	// LDA
	ram[0x0901] = 0x77; // #$77
	ram[0x0902] = 0x8D; // STA
	ram[0x0903] = 0x34;
	ram[0x0904] = 0x12; // $1234
	ram[0x0905] = 0xA9;	// LDA
	ram[0x0906] = 0x33; // #$33
	ram[0x0907] = 0x8D; // STA
	ram[0x0908] = 0x78;
	ram[0x0909] = 0x56; // $5678
	
	
	MCS6502Init(&context, OnRead, OnWrite, NULL);
	MCS6502Reset(&context);
	while(true) MCS6502ExecNext(&context);
	return 0;
}

