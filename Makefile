CFLAGS = -g #-Wall
VALFLAGS = --leak-check=full --show-leak-kinds=all # -v

all: kirc.y.c kirc.l.c
	gcc -o kirc kirc.l.c kirc.y.c $(CFLAGS)

kirc.y.c:
	bison -o $@ -d kirc.y

kirc.l.c:
	flex -o $@ kirc.lex

ast.o:
	gcc -c ast.c -o ast.o

.PHONY: run
run: all
	@echo "================================================="
	@./kirc

.PHONY: test
test: all
	@echo "================================================="
	@./kirc examples/test.kir

.PHONY: debug
debug: all
	@echo "================================================="
	@gdb ./kirc

.PHONY: memtest
memtest: all
	@echo "================================================="
	@valgrind $(VALFLAGS) ./kirc examples/test.kir

clean:
	rm -f *~ kirc.l.c kirc.y.c kirc.y.h kirc
