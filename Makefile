CFLAGS = #-Wall -g

all: kirc.y.c kirc.l.c
	gcc -o kirc kirc.l.c kirc.y.c $(CFLAGS)

kirc.y.c:
	bison -o $@ -d kirc.y

kirc.l.c:
	flex -o $@ kirc.lex

run: all
	@echo "================================================="
	@./kirc

clean:
	rm -f kirc.l.c kirc.y.c kirc.y.h kirc
