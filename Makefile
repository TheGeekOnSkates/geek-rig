all:
	clear && gcc ./system/*.c -Wall -Wextra -lncursesw -ogeekrig4000 || exit 1
	./geekrig4000 ./programs/asm/test1.rig
