#include "geek-rig.h"

void main() {
	char buffer[80];
	
	// Clear the screen
	PutChar(0x1B);
	PutChar(99);
	
	// REPL! :-)
	while(true) {
		Print("the 8-bit shell:  ");
		ReadLine(buffer, 80);
		Run(buffer);
		Print("\r\n\n");
	}
}

