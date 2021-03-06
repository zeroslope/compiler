%{
#include <stdio.h>
#include "ast.h"
#include "pcat.h"

#define min(a, b) ((a) < (b)) ? (a) : (b)
#define printableAscii(ch)  ((0x20 <= (ch) && (ch) <= 0x7E && (ch) != '"'))

int yycolumn = 1;
#define YY_USER_ACTION yylexUpdateLocation();

char* createCstr();
void yyerror(const char* message);
void yyerrorUnknownChar(char ch);
void yylexUpdateLocation();

%}

%option noyywrap
%option yylineno

%x COMMENT

whitespace  [\ \t\r]+
digit       [0-9]
alpha       [a-zA-Z]

digits      {digit}+

INTEGERT    {digits}
REALT       ({digits}\.{digit}*)
IDENTIFIER  [a-zA-Z][a-zA-Z0-9]*
STRINGT     \"([^"\n])*\"
BADSTR      \"([^"\n])*

LPAREN      \(
RPAREN      \)
LBRACKET    \[
RBRACKET    \]
LBRACE      \{
RBRACE      \}
COLON       :
DOT         \.
SEMICOLON	  ;  
COMMA	      ,  
ASSIGN	    := 
PLUS	      \+  
MINUS	      -  
STAR	      \*  
SLASH	      \/  
BACKSLASH	  \\  
EQ		      =  
NEQ		      <> 
LT		      <  
LE		      <= 
GT		      >  
GE		      >= 
LABRACKET	  \[<
RABRACKET	  >\]

%%
    
{whitespace}        { }

 /* comment */
"(*"                { BEGIN(COMMENT); }
<COMMENT>[^)*\n]+
<COMMENT>\n         { yycolumn = 1; }
<COMMENT><<EOF>>    { yyerror("Unterminated comment"); return EOFF; }
<COMMENT>"*)"       { BEGIN(INITIAL); }
<COMMENT>[*)]

\n                  { yycolumn = 1; } 

{LPAREN}    { return LPAREN; }
{RPAREN}    { return RPAREN; }
{LBRACKET}  { return LBRACKET; }
{RBRACKET}  { return RBRACKET; }
{LBRACE}    { return LBRACE; }
{RBRACE}    { return RBRACE; }
{COLON}     { return COLON; }
{DOT}       { return DOT; }
{SEMICOLON} { return SEMICOLON; }
{COMMA}     { return COMMA; }
{ASSIGN}    { return ASSIGN; }
{PLUS}      { return PLUS; }
{MINUS}     { return MINUS; }
{STAR}      { return STAR; }
{SLASH}     { return SLASH; }
{BACKSLASH} { return BACKSLASH; }
{EQ}        { return EQ; }
{NEQ}       { return NEQ; }
{LT}        { return LT; }
{LE}        { return LE; }
{GT}        { return GT; }
{GE}        { return GE; }
{LABRACKET} { return LABRACKET; }
{RABRACKET} { return RABRACKET; }

PROGRAM     { return PROGRAM; }
IS          { return IS; }
BEGIN       { return BEGINT; }
END         { return END; }
VAR         { return VAR; }
TYPE        { return TYPE; }
PROCEDURE   { return PROCEDURE; }
ARRAY       { return ARRAY; }
RECORD      { return RECORD; }
IN          { return IN; }
OUT         { return OUT; }
READ        { return READ; }
WRITE       { return WRITE; }
IF          { return IF; }
THEN        { return THEN; }
ELSE        { return ELSE; }
ELSIF       { return ELSIF; }
WHILE       { return WHILE; }
DO          { return DO; }
LOOP        { return LOOP; }
FOR         { return FOR; }
EXIT        { return EXIT; }
RETURN      { return RETURN; }
TO          { return TO; }
BY          { return BY; }
AND         { return AND; }
OR          { return OR; }
NOT         { return NOT; }
OF          { return OF; }
DIV         { return DIV; }
MOD         { return MOD; }
TRUE        { yylval.Tstring = createCstr(); return TRUET; }
FALSE       { yylval.Tstring = createCstr(); return FALSET; }
NIL         { yylval.Tstring = createCstr(); return NILT; }

{IDENTIFIER} {
  if(yyleng < 256) {
    yylval.Tstring = yytext;
    return IDENTIFIER; 
  }
  yyerror("Identifier too long");
  return ERROR;
}

{STRINGT} {
  if(yyleng-2 < 256) {
    for(int i = 1;i < yyleng-1;i ++) {
      if(!printableAscii(yytext[i])) {
        yyerrorUnknownChar(yytext[i]);
        return ERROR;
      }
    }
    yylval.Tstring = createCstr();
    return STRINGT; 
  }
  yyerror("String too long");
  return ERROR;
}

{INTEGERT} {
  if(yyleng>10 || (yyleng==10 && (strcmp(yytext,"2147483647")>0))){
    yyerror("Integer out of range.\n");
    return ERROR;                  
  }
  int val = atoi(yytext);
  yylval.Tint = (int)val;
  return INTEGERT; 
}

{REALT} {
  double val = atof(yytext);
  yylval.Treal = (long)val;
  return REALT; 
}

{BADSTR} { 
  yyerror("Unterminated string"); 
  return ERROR; 
}
                
<<EOF>> return 0;
            
 /* fallback */
. { 
  yyerrorUnknownChar(yytext[0]); 
  return ERROR;
}

%%

void yyerror(const char *message) {
  static char preview[14] = "??????????...";
  memcpy(preview, yytext, min(yyleng+1, 10));
  
  if(yytext) {
    fprintf(stdout, "*** \"%s\" (line: %d, token:`%s')\n", message, yylineno, preview);
  }
}

void yyerrorUnknownChar(char ch) {
  if(yytext) {
    fprintf(stdout, "Error: \"Illegal character`\\%03o' ignored\" in line %d.\n", ch, yylineno);
  }
}

char* createCstr() {
    if(!yytext) return NULL;

    char* str = (char*)malloc(yyleng-1);
    memcpy(str, yytext+1, sizeof(char) * (yyleng-2));
    str[yyleng-2] = '\0';

    return str;
}

void yylexUpdateLocation() {
  yylloc.first_line = yylineno;
  yylloc.last_line = yylineno;
  yylloc.first_column = yycolumn;
  yylloc.last_column = yycolumn + yyleng - 1;
  yycolumn += yyleng;
}

