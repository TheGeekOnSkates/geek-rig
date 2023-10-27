all:
	clear & gcc ./*.c -ogeek-rig -Wall -Wextra -pedantic -Wno-unused-variable || exit 1

test1:
	clear && dasm ./tests/test1.s -otests/test1.rig -f3 || exit 1
	wc -c ./tests/test1.rig && hexdump -C ./tests/test1.rig

run:
	./geek-rig ./tests/test1.rig

