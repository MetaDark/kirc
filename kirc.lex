%{
#include <stdio.h>
#include "kirc.y.h"
%}

%%

"#".*                // Eat up the tasty one line comments

exists                return EXISTS;

import                return IMPORT;
writeln               return WRITELN;

[a-zA-Z][a-zA-Z0-9]*  yylval.string = strdup(yytext); return SYMBOL;
\"(\\.|[^"])*\"       yylval.string = strdup(yytext); return STRING_LITERAL;
[0-9]+                yylval.number = atoi(yytext); return NUMBER;
:                     return ':';
=                     return '=';
,                     return ',';
\(                    return '(';
\)                    return ')';

\n
[ \t]+                // Ingore whitespace

.			          fprintf(stderr, "[Line: %i]: Unexpected character '%c'\n", yylineno, yytext[0]);

%%
