%{
#include <stdio.h>
#include <stdlib.h>

void yyerror(const char *str);
int yywrap();

extern int yylineno;
extern FILE *yyin;

//=======================================================//

typedef enum {
	NAMESPACE,
	FUNCTION,
	VARIABLE
} SymbolType;

#define SYMBOL_MEMBERS \
	struct Symbol * prev; \
	SymbolType sym_type; \
	char * name;

typedef struct Symbol {SYMBOL_MEMBERS} Symbol;

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

typedef struct Namespace {
	SYMBOL_MEMBERS;
} Namespace;

Namespace * new_namespace(char * name) {
	Namespace * namespace = malloc(sizeof(Namespace));
	
	namespace->sym_type = NAMESPACE;
	namespace->name = name;
	
	return namespace;
}

//=======================================================//

typedef struct Function {
	SYMBOL_MEMBERS;
} Function;

Function * new_func(char * name) {
	Function * func = malloc(sizeof(Function));
	if(func == NULL) {
		return NULL;
	}
	
	func->sym_type = FUNCTION;
	func->name = name;
	
	printf(" => Function '%s' created!\n", name);
	return func;
}

//=======================================================//

typedef enum {
	CHAR,
	INTEGER
} DataType;

#define DATA_MEMBERS \
	DataType type;

typedef struct Data {
	DATA_MEMBERS;
} Data;

typedef struct Integer {
	DATA_MEMBERS;
	int data;
} Integer;

Integer * new_integer(int data) {
	Integer * integer = malloc(sizeof(Integer));
	if(integer == NULL) {
		return NULL;
	}
	
	integer->data = data;
	return integer;
}

//=======================================================//

typedef struct Variable {
	SYMBOL_MEMBERS;
	Data * data;
} Variable;

Variable * new_var(char * name, Data * data) {
	Variable * var = malloc(sizeof(Variable));
	
	var->sym_type = VARIABLE;
	var->name = name;
	var->data = data;
	
	printf(" => Variable '%s' created!\n", name);
	printf("   > DataType [%d]\n", data->type);
	return var;
}

//=======================================================//

typedef struct ArgList {
	char * name;
	struct ArgList * prev;
} ArgList;

//=======================================================//

typedef struct Scope {
	Symbol * symbol;
	struct Scope * parent;
} Scope;

/**
 * Create new scope tree
 */
Scope * new_scope() {
	Scope * scope = malloc(sizeof(Scope));
	scope->symbol = NULL;
	scope->parent = NULL;
	return scope;
}

/**
 * Delete entire scope tree
 */
void del_scope(Scope * scope) {
	Scope * parent;
	
	while(scope != NULL) {
		parent = scope->parent;
		del_symbol(scope->symbol);
		free(scope);
		scope = parent;
	}
}

/**
 * Create a new scope level
 */
void push_scope(Scope ** scope) {
	Scope * newscope = new_scope();
	newscope->parent = *scope;
	*scope = newscope;
	
	printf("   > New scope created!\n");
}

/**
 * Delete the current scope level
 */
void pop_scope(Scope ** scope) {
	Scope * parent = (*scope)->parent;
	del_symbol((*scope)->symbol);
	free(*scope);
	*scope = parent;
	
	printf("   > Scope popped!\n");
}

/**
 * Add symbol to scope
 */
void add_sym_scope(Scope * scope, Symbol * symbol) {
	symbol->prev = scope->symbol;
	scope->symbol = symbol;
	
	printf("   > Symbol '%s' added to scope!\n", symbol->name);
}

/**
 * Lookup a symbol from scope
 */
Symbol * lookup_sym_scope(Scope * scope, char * name) {
	Symbol * symbol;
	
	while(scope != NULL) {
		symbol = lookup_symbol(scope->symbol, name);
		
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

// Debug tokens
%token EXISTS

%token IMPORT
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
	exists
	|
	cmd_import
	|
	cmd_writeln
	|
	function
	|
	assignment
	;

exists:
	EXISTS SYMBOL {
		if(lookup_sym_scope(global_scope, $2) != NULL) {
			printf("Symbol: '%s' exists!\n");	
		} else {
			printf("Symbol: '%s' doesn't exist!\n");
		}
	}
	;

cmd_import:
	IMPORT STRING_LITERAL {
		printf("Import %s\n", $2);
	}

cmd_writeln:
	WRITELN STRING_LITERAL {
		puts($2);
	}
	;

function:
	SYMBOL arg_list {
		Symbol * symbol = lookup_sym_scope(global_scope, $1);
		if(symbol != NULL) {
			if(symbol->sym_type != FUNCTION) {
				fprintf(stderr, "Not a function: '%s'\n", $1);
			}
			// Call function
		} else {
			fprintf(stderr, "No such function: '%s'\n", $1);
		}
	}
	|
	SYMBOL arg_list ':' {
		Function * func = new_func($1);
		if(func != NULL) {
			add_sym_scope(global_scope, (Symbol*)func);
			push_scope(&global_scope);
		}
	}
	;

arg_list:
	'(' ')'
	|
	'(' comma_list ')'
	;

comma_list:
	SYMBOL {
		printf("%s\n", $1);
	}
	|
	comma_list ',' SYMBOL {
		printf("%s\n", $3);
	}
	;

assignment:
	SYMBOL '=' NUMBER {
		Integer * integer = new_integer($3);
		if(integer != NULL) {
			Variable * var = new_var($1, (Data*)integer);
			if(var != NULL) {
				add_sym_scope(global_scope, (Symbol*)var);
			}
		}
	}
	;

/*data:
	STRING_LITERAL {
		//$$ = $1;
	}
	|
	NUMBER {
		//Integer * integer = new_integer($1);
		//$$ = (Data*)integer;
	}
	|
	SYMBOL {
		
	}
	;
*/

%%

/**
 * Error handling function
 */
void yyerror(const char *str) {
	fprintf(stderr, "[Line %i]: error: %s\n", yylineno, str);
}

/**
 * Function called when end of file reached
 */
int yywrap(void) {
	fclose(yyin);
	return 1;
}

int main(int argc, char * argv[]) {
	
	// If arguments have been passed, read from file instead of stdin
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
