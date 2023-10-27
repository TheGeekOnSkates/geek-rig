all:
	clear & gcc ./*.c -ogeek-rig -Wall -Wextra -pedantic -Wno-unused-variable || exit 1
	./geek-rig

