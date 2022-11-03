#ifndef _GEEKRIG4000_
#define _GEEKRIG4000_

// -------------------------------------------------------------------------
// GEEK-RIG 4000 MEMORY MAP
// -------------------------------------------------------------------------

// 0-255 ($00-$FF): Zero-page
// 256-511 ($0100-01FF): 6502 stack
// I have never needed macros for these,
// either for the system itself or for games,
// but feel free to add them back if you like :)

// 512-1471 ($0200-$05BF) Screen RAM (40x24)
#define SCREEN 512

// 1472 ($05C0): Screen width, in character cells
#define COLUMNS 1472

// 1473 ($05C1): Screen height, in character cells
#define ROWS 1473

// 1474 ($05C2): Current key pressed
#define KEY 1474

// 1475 ($05C3): Random number generator
#define RANDOM 1475

// 1476 ($05C4): Clock (just counts seconds)
#define CLOCK 1476

// 1477-1478 ($05C5-$05C6): Pointer to start of file read/write string
#define DISK_FILENAME 1477

// 1479-1480 ($05C7-$05C8): Pointer to start of read/write buffer
#define DISK_BUFFER_START 1479

// 1481-1482 ($05C9-$05CA): Pointer to end of read/write buffer
#define DISK_BUFFER_END 1481

// 1483 ($05CB): Disk drive status and character set:
#define DISK_STATUS 1483

// 1484 ($05CC): Start of user code
#define USER 1484


// -------------------------------------------------------------------------
// DISK DRIVE INSTRUCTIONS (stored in DISK_STATUS)
// -------------------------------------------------------------------------

#define DISK_READ		0b00100000
#define DISK_WRITE		0b01000000
#define DISK_APPEND		0b01100000


// -------------------------------------------------------------------------
// DISK DRIVE STATUS CODES
// -------------------------------------------------------------------------

#define DISK_READING						1
#define DISK_WRITING						2
#define DISK_APPENDING						3
#define DISK_ERROR_UNKNOWN					4
#define DISK_ERROR_NULL_STRING				5
#define DISK_ERROR_FILE_NOT_FOUND			6
#define DISK_ERROR_ACCESS_DENIED			7
#define DISK_ERROR_READ_ONLY_FS				8
#define DISK_ERROR_OUT_OF_MEMORY			9
#define DISK_ERROR_NOT_PERMITTED			10
#define DISK_ERROR_IS_FOLDER				11
#define	DISK_ERROR_INTERRUPTED				12
#define DISK_ERROR_RESOURCE_UNAVAILABLE		13
#define DISK_ERROR_FILE_TOO_BIG				14
#define DISK_ERROR_BUSY						15
// I can add up to 15 more (31 is the highest number you can reach in the first 5 bits of a byte)


// -------------------------------------------------------------------------
// KEY CODES (stored in KEY [0x05C2] obviously :D)
// -------------------------------------------------------------------------

#define KEY_BACKSPACE	8
#define KEY_TAB			9
#define KEY_ESCAPE		27
#define KEY_SPACE		32
#define KEY_A			65
#define KEY_B			66
#define KEY_C			67
#define KEY_D			68
#define KEY_E			69
#define KEY_F			70
#define KEY_G			71
#define KEY_H			72
#define KEY_I			73
#define KEY_J			74
#define KEY_K			75
#define KEY_L			76
#define KEY_M			77
#define KEY_N			78
#define KEY_O			79
#define KEY_P			80
#define KEY_Q			81
#define KEY_R			82
#define KEY_S			83
#define KEY_T			84
#define KEY_U			85
#define KEY_V			86
#define KEY_W			87
#define KEY_X			88
#define KEY_Y			89
#define KEY_Z			90

#endif
