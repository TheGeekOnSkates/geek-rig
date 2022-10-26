#ifndef _GEEKRIG4000_
#define _GEEKRIG4000_

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

#endif
