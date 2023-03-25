LST_NAME = build.lst
BLD_FOLDER = build
BLD_FILE = $(BLD_FOLDER)/build.exe

all: main

test:
	@make rm
	@make
	@make clean
	@make run

MAIN_OBJECTS = scuffedio.o
main: $(MAIN_OBJECTS)
	mkdir -p $(BLD_FOLDER)
	ld -s -o $(BLD_FILE) $(MAIN_OBJECTS)

run: $(BLD_FILE)
	./$(BLD_FILE)

clean:
	rm -f *.o *.lst

rm: clean
	rm -rf $(BLD_FOLDER)

%.o: %.s
	nasm -f elf64 -l $(LST_NAME) $^

debug: $(BLD_FILE)
	radare2 -d $(BLD_FILE)