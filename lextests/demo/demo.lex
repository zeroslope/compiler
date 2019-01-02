%{
#include "yacc.h"

int yycolumn = 1;

#define YY_USER_ACTION yylexUpdateLocation();
void yylexUpdateLocation();
%}
%option     nounput
%option     noyywrap
%option     yylineno

DIGIT       [0-9]
INTEGER     {DIGIT}+
REAL        {DIGIT}+"."{DIGIT}*
WS          [ \t]+

%%
{WS}        /* skip blanks and tabs */
"+"         return ADD;
"-"         return SUB;
"*"         return MUL;
"/"         return DIV;
"("         return OP;
")"         return CP;
\n          { yycolumn = 1; return EOL; }
{INTEGER}|{REAL}   { yylval.val = atof(yytext); return NUMBER; }
%%

void yylexUpdateLocation() {
  yylloc.first_line = yylineno;
  yylloc.last_line = yylineno;
  yylloc.first_column = yycolumn;
  yylloc.last_column = yycolumn + yyleng - 1;
  yycolumn += yyleng;
}
