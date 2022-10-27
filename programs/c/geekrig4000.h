#ifndef _GEEKRIG4000_
#define _GEEKRIG4000_

// -------------------------------------------------------------------------
// MEMORY MAP
// -------------------------------------------------------------------------

// Screen RAM (40x24)
#define SCREEN 0x0200

// Screen width
#define COLUMNS() PEEK(0x05C0)

// Screen height
#define ROWS() PEEK(0x05C1)

// Current key pressed
#define KEY() PEEK(0x05C2)

// Random number generator
#define RANDOM() PEEK(0x05C3)

// Clock (just counts seconds)
#define CLOCK() PEEK(0x05C4)

// Pointer to start of file read/write string
#define DISK_FILENAME 0x05C5

// Pointer to start of read/write buffer
#define DISK_BUFFER_START 0x05C7

// Pointer to end of read/write buffer
#define DISK_BUFFER_END 0x05C9

// Disk drive status and character set
#define DISK_STATUS 0x05CB

#endif
