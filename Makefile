all:
	clear & gcc ./*.c -ogeek-rig -Wall -Wextra -pedantic || exit 1
	./geek-rig

