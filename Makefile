PROGRAM = kirc

all:
	lex $(PROGRAM).lex
	yacc -d $(PROGRAM).y
	gcc -fmax-errors=1 y.tab.c lex.yy.c -o $(PROGRAM)

run: all
	./$(PROGRAM)

clean:
	rm -f *~ $(PROGRAM) lex.yy.c y.tab.c y.tab.h
