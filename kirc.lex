%{
#include <stdio.h>
#include "kirc.y.h"

extern YYSTYPE yylval;
%}

out									{ return TOKOUT; }
({SP}?\"([^"\\\n]|{ES})*\"{WS}*)+	{ return STRING_LITERAL; }
.									{ yyerror("Illegal character %s", yytext[0]); }

%%
