CFLAGS = -fmax-errors=1

PROGRAM = kirc

all: yacc lex
	mkdir -p build
	gcc y.tab.c lex.yy.c -o build/$(PROGRAM) $(CFLAGS)

yacc:
	lex $(PROGRAM).lex

lex:
	yacc -d $(PROGRAM).y

run: all
	./build/$(PROGRAM)

clean:
	rm -f *~ build y.tab.c lex.yy.c

