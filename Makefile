all: pingpong

pingpong: pingpong.asm
	nasm -f elf64 pingpong.asm -o pingpong.o
	ld -o pingpong pingpong.o

run: pingpong
	stty -icanon -echo
	./pingpong
	stty icanon echo

clean:
	rm -f pingpong pingpong.o 