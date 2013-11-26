%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *str);
int yywrap();

extern FILE *yyin;

//=======================================================//

/*
typedef struct ArgList {
	char * name;
	struct ArgList * prev;
} ArgList;
*/

//=======================================================//

// Symbol definitions
typedef enum SymbolType {
	NAMESPACE,
	FUNCTION,
	VARIABLE
} SymbolType;

#define SYMBOL_MEMBERS \
	struct Symbol * prev; \
	SymbolType sym_type; \
	char * name;

typedef struct Symbol {SYMBOL_MEMBERS} Symbol;

void init_symbol(Symbol * symbol, SymbolType sym_type, char * name) {
	symbol->sym_type = sym_type;
	symbol->name = name;
}

void del_symbol(Symbol * symbol) {
	Symbol * prev;
	
	while(symbol != NULL) {
		prev = symbol->prev;
		free(symbol);
		symbol = prev;
	}
}

Symbol * lookup_symbol(Symbol * symbol, char * name) {
	while(symbol != NULL) {
		if(strcmp(symbol->name, name) == 0) {
			return symbol;
		}
		
		symbol = symbol->prev;
	}
	
	return NULL;
}

//=======================================================//

// Namespace definitions
typedef struct Namespace {
	SYMBOL_MEMBERS	
} Namespace;

Namespace * new_namespace(char * name) {
	Namespace * namespace = malloc(sizeof(Namespace));
	init_symbol((Symbol *)namespace, NAMESPACE, name);
	return namespace;
}

//=======================================================//

// Function definitons
typedef struct Function {
	SYMBOL_MEMBERS
} Function;

Function * new_function(char * name) {
	Function * func = malloc(sizeof(Function));
	init_symbol((Symbol *)func, FUNCTION, name);
	return func;
}

//=======================================================//

typedef struct Data {
	SYMBOL_MEMBERS
} Data;

void init_data() {
	
}

//=======================================================//

// Variable definitions
typedef struct Variable {
	SYMBOL_MEMBERS
	Data * data;
} Variable;

Variable * new_variable() {
	Variable * var = malloc(sizeof(Variable));
	return var;
}

//=======================================================//

// Scope definitions
typedef struct Scope {
	Symbol * symbols;
	struct Scope * parent;
} Scope;

Scope * new_scope() {
	Scope * scope = malloc(sizeof(Scope));
	scope->symbols = NULL;
	scope->parent = NULL;
	return scope;
}

void del_scope(Scope * scope) {
	Scope * parent;
	
	while(scope != NULL) {
		parent = scope->parent;
		del_symbol(scope->symbols);
		free(scope);
		scope = parent;
	}
}

void push_scope(Scope ** scope) {
	Scope * newscope = new_scope();
	newscope->parent = *scope;
	*scope = newscope;
}

void pop_scope(Scope ** scope) {
	Scope * parent = (*scope)->parent;
	del_symbol((*scope)->symbols);
	free(*scope);
	*scope = parent;
}

void add_sym_scope(Scope * scope, Symbol * symbol) {
	symbol->prev = scope->symbols;
	scope->symbols = symbol;
}

Symbol * lookup_sym_scope(Scope * scope, char * name) {
	Symbol * symbol;
	
	while(scope != NULL) {
		symbol = lookup_symbol(scope->symbols, name);
		
		if(symbol != NULL) {
			return symbol;
		}
		
		scope = scope->parent;
	}
	
	return NULL;
}

//=======================================================//

Scope * global_scope;

%}

%union {
	int number;
	char * string;
}

%token WRITELN
%token <string> SYMBOL
%token <number> NUMBER
%token <string> STRING_LITERAL

%start commands
%%

commands:
	| commands command
	;

command:
	cmd_writeln
	|
	function
	|
	assignment
	;

cmd_writeln:
	WRITELN STRING_LITERAL {
		puts($2);
	}
	;

function:
	SYMBOL arg_list {
		printf("Funcion call '%s'\n", $1);
	}
	|
	SYMBOL arg_list ':' {
		printf("Function declaration %s\n", $1);
	}
	;

arg_list:
	'(' ')'
	|
	'(' comma_list ')'
	;

comma_list:
	SYMBOL
	|
	comma_list ',' SYMBOL
	;

assignment:
	SYMBOL '=' NUMBER {
		printf("Set %s equal to %i\n", $1, $3);
	}
	;

%%

/**
 * Error handling function
 */

void yyerror(const char *str) {
	fprintf(stderr, "error: %s\n", str);
}

/**
 * Function called when end of file reached
 */

int yywrap(void) {
	fclose(yyin);
	return 1;
}

int main(int argc, char * argv[]) {
	
	// Read from file
	if(argc > 1) {
		yyin = fopen(argv[1], "r");
		if(yyin == NULL) {
			fprintf(stderr, "Could not open file '%s'\n", argv[1]);
			return 1;
		}
	}

	global_scope = new_scope();
	yyparse();
	del_scope(global_scope);
	
	return 0;
}
