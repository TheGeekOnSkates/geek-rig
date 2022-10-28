; --------------------------------------------------------------------------
; MEMORY MAP
; --------------------------------------------------------------------------

SCREEN = $0200				; Screen RAM (40x24)
COLUMNS = $05C0				; Screen width, in character cells
ROWS = $05C1				; Screen height, in character cells
KEY = $05C2					; Current key pressed
RANDOM = $05C3				; Random number generator
CLOCK = $05C4				; Clock (just counts seconds)
DISK_FILENAME = $05C5		; Pointer to start of file read/write string
DISK_BUFFER_START = $05C7	; Pointer to start of read/write buffer
DISK_BUFFER_END = $05C9		; Pointer to end of read/write buffer
DISK_STATUS = $05CB			; Disk drive status and character set:

; --------------------------------------------------------------------------
; Disk drive instructions (stored in MM_DISK_STATUS)
; --------------------------------------------------------------------------

DISK_READ = %00100000
DISK_WRITE = %01000000
DISK_APPEND = %01100000

; --------------------------------------------------------------------------
; Disk drive status codes
; --------------------------------------------------------------------------

; The disk drive isn't doing anything
DISK_IDLE = 0

; Reading in progress
DISK_READING = 1

; Writing in progress - overwrite mode
DISK_WRITING = 2

; Writing in progress - append mode
DISK_APPENDING = 3

; There was a disk Read/write error that isn't on the list of errors below
DISK_ERROR_UNKNOWN = 4

; DISK_BUFFER_START points to an empty string
DISK_ERROR_NULL_STRING = 5

; "No such file or directory"
DISK_ERROR_FILE_NOT_FOUND = 6

; "Permission denied" ("access denied" just sounds cooler and more retro)
DISK_ERROR_ACCESS_DENIED = 7

; "Read-only filesystem" (I've only ever seen this on micro-SD cards)
DISK_ERROR_READ_ONLY_FS	= 8

; Not enough memory to open the file (unlikely, but it can happen I guess)
DISK_ERROR_OUT_OF_MEMORY = 9

; "Operation not permitted" (never seen this, not sure how it's
; different from "permission denied", but still, may as well include it)
DISK_ERROR_NOT_PERMITTED = 10

; The file the disk drive tried to open is a folder ("directory")
DISK_ERROR_IS_FOLDER = 11

; Something interrupted the read (like you unplugged the USB drive)
DISK_ERROR_INTERRUPTED = 12

; "Resource unavailable", whatever that means
DISK_ERROR_RESOURCE_UNAVAILABLE = 13

; The file is too big
DISK_ERROR_FILE_TOO_BIG = 14

; The file is being used by another program
DISK_ERROR_BUSY = 15


; --------------------------------------------------------------------------
; KEYCODES
; --------------------------------------------------------------------------

KEY_A = $61
KEY_D = $64
KEY_S = $73
KEY_W = $77
