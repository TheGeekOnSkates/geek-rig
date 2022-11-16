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

; If using the kernel, it uses these memory addresses
; (and actually, I would just say leave $00 to $0F alone, lol)
KERNEL_CURSOR_LSB = $00
KERNEL_CURSOR_MSB = $01





; If not using any of the stuff in the "math" folder, you can put whatever
; you like in these memory addresses.

MATH_N1_LO = $09FA			; low-byte of the left number
							; i.e. in $1234 + $5678, this would be $34
MATH_N1_HI = $09FB			; high-byte of the left number
							; This would be the $12 in the example above
MATH_N2_LO = $09FC			; low-byte of the right number (i.e. $78)
MATH_N2_HI = $09FD			; high-byte of the right number (i.e. $56)
MATH_RESULT_LO = $09FE		; Low-byte of the result
							; For example, $1234 + $5678 = $68AC, so the
							; low-byte would be $AC
MATH_RESULT_HI = $09FF		; High-byte of the result (i.e. $68)





; --------------------------------------------------------------------------
; Disk drive instructions (stored in DISK_STATUS)
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
; KEY CODES (stored in KEY [0x05C2] obviously :D)
; --------------------------------------------------------------------------

KEY_BACKSPACE =		$08
KEY_TAB	=			$09
KEY_ESCAPE =		$1B
KEY_SPACE =			$20
KEY_0 =				$30
KEY_1 =				$31
KEY_2 =				$32
KEY_3 =				$33
KEY_4 =				$34
KEY_5 =				$35
KEY_6 =				$36
KEY_7 =				$37
KEY_8 =				$38
KEY_9 =				$39
KEY_A =				$61
KEY_B =				$62
KEY_C =				$63
KEY_D =				$64
KEY_E =				$65
KEY_F =				$66
KEY_G =				$67
KEY_H =				$68
KEY_I =				$69
KEY_J =				$6A
KEY_K =				$6B
KEY_L =				$6C
KEY_M =				$6D
KEY_N =				$6E
KEY_O =				$6F
KEY_P =				$70
KEY_Q =				$71
KEY_R =				$72
KEY_S =				$73
KEY_T =				$74
KEY_U =				$75
KEY_V =				$76
KEY_W =				$77
KEY_X =				$78
KEY_Y =				$79
KEY_Z =				$7A

; --------------------------------------------------------------------------
; PETSCII CHARACTER CODES
; --------------------------------------------------------------------------

PETSCII_AT =					$00
PETSCII_CAPITAL_A =				$01
PETSCII_CAPITAL_B =				$02
PETSCII_CAPITAL_C =				$03
PETSCII_CAPITAL_D =				$04
PETSCII_CAPITAL_E =				$05
PETSCII_CAPITAL_F =				$06
PETSCII_CAPITAL_G =				$07
PETSCII_CAPITAL_H =				$08
PETSCII_CAPITAL_I =				$09
PETSCII_CAPITAL_J =				$0A
PETSCII_CAPITAL_K =				$0B
PETSCII_CAPITAL_L =				$0C
PETSCII_CAPITAL_M =				$0D
PETSCII_CAPITAL_N =				$0E
PETSCII_CAPITAL_O =				$0F
PETSCII_CAPITAL_P =				$10
PETSCII_CAPITAL_Q =				$11
PETSCII_CAPITAL_R =				$12
PETSCII_CAPITAL_S =				$13
PETSCII_CAPITAL_T =				$14
PETSCII_CAPITAL_U =				$15
PETSCII_CAPITAL_V =				$16
PETSCII_CAPITAL_W =				$17
PETSCII_CAPITAL_X =				$18
PETSCII_CAPITAL_Y =				$19
PETSCII_CAPITAL_Z =				$1A
PETSCII_LEFT_BRACKET =			$1B
PETSCII_SLASH =					$1C
PETSCII_RIGHT_BRACKET =			$1D
PETSCII_ARROW_UP =				$1E
PETSCII_ARROW_LEFT =			$1F
PETSCII_SPACE =					$20
PETSCII_EXCLAMATION_POINT =		$21
PETSCII_QUOTES =				$22
PETSCII_HASHTAG =				$23
PETSCII_DOLLAR_SIGN =			$24
PETSCII_PERCENT_SIGN =			$25
PETSCII_QUOTES_AND =			$26
PETSCII_APOSTROPHE =			$27
PETSCII_LEFT_PAREN =			$28
PETSCII_RIGHT_PAREN =			$29
PETSCII_ASTERISK =				$2A
PETSCII_PLUS_SIGN =				$2B
PETSCII_COMMA =					$2C
PETSCII_DASH =					$2D
PETSCII_PERIO =					$2E
PETSCII_BACKSLASH =				$2F
PETSCII_0 =						$30
PETSCII_1 =						$31
PETSCII_2 =						$32
PETSCII_3 =						$33
PETSCII_4 =						$34
PETSCII_5 =						$35
PETSCII_6 =						$36
PETSCII_7 =						$37
PETSCII_8 =						$38
PETSCII_9 =						$39
PETSCII_COLON =					$3A
PETSCII_SEMICOLON =				$3B
PETSCII_LESS_THAN =				$3C
PETSCII_EQUALS =				$3D
PETSCII_GREATER_THAN =			$3E
PETSCII_QUESTION_MARK =			$3F
PETSCII_HORIZONTAL_LINE_1 =		$40
; Leaving off here for now... some of these are just nuts, not sure how to describe them all :D
; Not to mention, this is just for the UPPERCASE character set
PETSCII_TRIANGLE_UP_LEFT =		$DF
PETSCII_TRIANGLE_UP_RIGHT =		$E9
