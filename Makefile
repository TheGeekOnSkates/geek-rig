all:
	clear && gcc ./system/*.c -Wall -Wextra -lncursesw -ogeekrig4000 || exit 1
	./geekrig4000

c-test:
	clear && cl65 ./programs/c/test1.c -o test1.rig --start-addr 0x05CA -t none
	rm ./programs/c/*.o && ./geekrig4000 && clear