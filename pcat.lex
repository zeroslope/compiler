%{
#include <cstdio>

#define min(a, b) ((a) < (b)) ? (a) : (b)
#define printableAscii(ch)  ((0x20 <= (ch) && (ch) <= 0x7E && (ch) != '"'))

int yycolumn = 1;
#define YY_USER_ACTION yylexUpdateLocation();

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

{IDENTIFIER} {
  if(yyleng < 256) {
    // yylval.Tstring = yytext;
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
  return INTEGERT; 
}

{REALT} {
  double val = atof(yytext);
  return REALT; 
}

{BADSTR} { 
  yyerror("Unterminated string"); 
  return ERROR; 
}
                
<<EOF>> return EOFF;
            
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

void yylexUpdateLocation() {
  yycolumn += yyleng;
}

