%{
#include <stdio.h>

void yyerror(const char *str);
int yywrap();

typedef struct KirAst {
	
} KirAst;

%}

%union {
	int number;
	char * string;
}

%token IF ELSE ELIF

%token OUT
%token <string> SYMBOL
%token <number> NUMBER
%token <string> STRING_LITERAL

%start commands
%%

commands:
    | commands command
    ;

command:
    func_call
    |
    func_declare
    |
    assignment
    ;

func_declare:
	SYMBOL arg_list ':' {
		printf("Function declaration of '%s'\n", $1);
	}
	;

func_call:
	SYMBOL '(' ')' {
		printf("Funcion call '%s'\n", $1);
	}
	|
	SYMBOL arg_list
	;

arg_list:
	'(' ')'
	|
	'(' comma_list ')'
	;

comma_list:
	data_container
	|
	comma_list ',' data_container
	;

assignment:
	SYMBOL '=' data_container {
		printf("Set %s equal to\n", $1);
	}
	;

data_container:
	STRING_LITERAL
	|
	NUMBER
	|
	SYMBOL
	;

%%

void yyerror(const char *str) {
    fprintf(stderr, "error: %s\n", str);
}
 
int yywrap() {
    return 1;
}

int main() {
    yyparse();
    return 0;
}
