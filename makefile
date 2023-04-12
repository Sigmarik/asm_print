LST_NAME = build.lst
BLD_FOLDER = build
BLD_FILE_CORE = build.out
BLD_FILE = $(BLD_FOLDER)/$(BLD_FILE_CORE)

CFLAGS = -Wall -Wextra -c -O0

all: ccall

CALL_OBJECTS = transition.o scuffedio.o caller.o
ccall: $(CALL_OBJECTS)
	mkdir -p $(BLD_FOLDER)
	gcc $(CALL_OBJECTS) -o $(BLD_FILE)

run: $(BLD_FILE)
	cd ./$(BLD_FOLDER) && ./$(BLD_FILE_CORE)

clean:
	rm -f *.o *.lst

rm: clean
	rm -rf $(BLD_FOLDER)

caller.o: caller.c
	gcc $(CFLAGS) $^ -o $@

%.o: %.s
	nasm -f elf64 -l $(LST_NAME) $^ -o $@

debug: $(BLD_FILE)
	radare2 -d $(BLD_FILE)