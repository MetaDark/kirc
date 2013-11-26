%{
#include <stdio.h>
#include "kirc.y.h"

int lineno = 0;
extern YYSTYPE yylval;
%}

%%

[a-zA-Z][a-zA-Z0-9]*  yylval.string = strdup(yytext); return SYMBOL;
\"(\\.|[^"])*\"       yylval.string = strdup(yytext); return STRING_LITERAL;
[0-9]+                yylval.number = atoi(yytext); return NUMBER;
:                     return ':';
=                     return '=';
,                     return ',';
\(                    return '(';
\)                    return ')';

\n                    lineno++;
[ \t]+
.			          fprintf(stderr, "[Line: %i]: Unexpected character '%c'\n", lineno, yytext[0]);

%%
