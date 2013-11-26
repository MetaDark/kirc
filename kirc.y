%{
#include <stdio.h>
 
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

%}

%token TOKOUT STRING_LITERAL

%%

commands:
	| commands command
	;

command:
	cmd_out
	;

cmd_out:
	TOKOUT STRING_LITERAL {
		printf("Complete zone for found\n");
	}
	;
