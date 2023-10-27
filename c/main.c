#include "geek-rig.h"

void main() {
	char buffer[80];
	
	// Clear the screen
	PutChar(0x1B);
	PutChar(99);
	
	// REPL! :-)
	while(true) {
		Print("type something:  ");
		ReadLine(buffer, 80);
		Print("\r\nyou typed:   ");
		Print(buffer);
		Print("\r\n\n");
	}
}

