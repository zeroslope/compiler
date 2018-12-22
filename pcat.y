%{
#include <stdio.h>
#include <stdarg.h>

// #include "ast.h"
// #include "pcat.tab.cxx"
// #include "pcat.tab.h"
// #include "pcat.yy.c"

// #define YYDEBUG 1


#define min(a, b) ((a) < (b)) ? (a) : (b)
#define max(a, b) ((a) > (b)) ? (a) : (b)
void yyerror(const char* s);  // error handler defined in pcat.lex

%}

%locations 
%error-verbose

%union {
  char*       Tstring;
  int         Tint;
  double      Treal;
}

%token IDENTIFIER INTEGERT REALT STRINGT
  PROGRAM IS BEGINT END VAR TYPE PROCEDURE ARRAY RECORD
  IN OUT READ WRITE 
  IF THEN ELSE ELSIF WHILE DO LOOP FOR TO BY EXIT RETURN
  AND OR NOT OF
  LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE COLON DOT SEMICOLON COMMA
  ASSIGN PLUS MINUS DIV MOD STAR SLASH BACKSLASH
  EQ NEQ LT LE GT GE LABRACKET RABRACKET EOFF ERROR
  TRUET FALSET NILT

%type <Tstring>
  program
  body
  declaration
  varDecl 
  typeDecl
  procedureDecl
  typenameOption
  typename
  type
  component
  formalParams fpSection
  statement statementElseOption statementByOption
  writeParams writeExpr
  orOperand andOperand // ?
  expressionOption expression relationship summand factor unary term
  lvalue actualParams 
  recordInits arrayInits arrayInit
  number string identifier constant
  // 35

%type <Tstring>
  declarationList
  declarationClosure
  statementClosure
  varDeclClosure
  typeDeclClosure
  procedureDeclClosure
  componentClosure
  fpSectionClosure
  statementLvalueClosure statementElsifClosure
  writeParamsExprClosure
  actualParamsExprClosure
  recordInitsPairClosure arrayInitClosure
  // 14

%%
start: program { printf("[Accept]\n"); }
  ;
program: PROGRAM IS body SEMICOLON
  ;
body: declarationList BEGINT statementClosure END
  ;
declarationList: declarationClosure
  ;
declarationClosure: /* empty */
  | declarationClosure declaration
  ;
declaration: VAR varDeclClosure
  | TYPE typeDeclClosure
  | PROCEDURE procedureDeclClosure
  ;
statementClosure: /* empty */
  | statementClosure statement
  ;
varDeclClosure: varDeclClosure varDecl
  |/* empty */
  ;
typeDeclClosure: /* empty */
  | typeDeclClosure typeDecl
  ;
procedureDeclClosure: /* empty */
  | procedureDeclClosure procedureDecl
  ;
varDecl: identifier IDClosure typenameOption ASSIGN expression SEMICOLON
  ;
IDClosure: /* empty */
  | IDClosure COMMA identifier
  ;
typenameOption: /* empty */
  | COLON typename
  ;
typeDecl: identifier IS type SEMICOLON
  ;
procedureDecl: identifier formalParams typenameOption IS body SEMICOLON
  ;
typename: identifier
  ;
type: ARRAY OF typename
  | RECORD component componentClosure END
  | typename {} // ???? 可以去掉
  ;
componentClosure: /* empty */
  | componentClosure component
  ;
component: identifier COLON typename SEMICOLON
  ;
formalParams: LPAREN fpSection fpSectionClosure RPAREN
  | LPAREN RPAREN
  ;
fpSectionClosure: /* empty */
  | fpSectionClosure SEMICOLON fpSection
  ;
fpSection: identifier IDClosure COLON typename
  ;
statement: lvalue ASSIGN expression SEMICOLON
  | identifier actualParams SEMICOLON
  | READ LPAREN lvalue statementLvalueClosure RPAREN SEMICOLON
  | WRITE writeParams SEMICOLON
  | IF expression THEN statementClosure
    statementElsifClosure
    statementElseOption 
    END SEMICOLON
  | WHILE expression DO statementClosure END SEMICOLON
  | LOOP statementClosure END SEMICOLON
  | FOR identifier ASSIGN expression TO expression statementByOption DO statementClosure END SEMICOLON
  | EXIT SEMICOLON
  | RETURN expressionOption SEMICOLON
  ;
statementLvalueClosure: /* empty */
  | statementLvalueClosure COMMA lvalue
  ;
statementElsifClosure: /* empty */
  | statementElsifClosure ELSIF expression THEN statementClosure
  ;
statementElseOption: /* empty */
  | ELSE statementClosure
  ;
statementByOption: /* empty */
  | BY expression
  ;
writeParams: LPAREN writeExpr writeParamsExprClosure RPAREN
  | LPAREN RPAREN
  ;
writeParamsExprClosure: /* empty */
  | writeParamsExprClosure COMMA writeExpr
  ;
writeExpr: string
  | expression
  ;
expressionOption: /* empty */
  | expression
  ;
expression: orOperand
  ;
orOperand: orOperand OR andOperand
  | andOperand
  ;
andOperand: andOperand AND relationship
  | relationship
  ;
relationship: summand GT summand
  | summand LT summand
  | summand EQ summand
  | summand NEQ summand
  | summand GE summand
  | summand LE summand
  | summand
  ;
summand: summand PLUS factor
  | summand MINUS factor
  | factor
  ;
factor: factor STAR unary
  | factor SLASH unary
  | factor DIV unary
  | factor MOD unary
  | unary
  ;
unary: PLUS unary
  | MINUS unary
  | NOT unary
  | term
  ;
term: number
  | lvalue
  | identifier actualParams
  | identifier recordInits
  | identifier arrayInits
  | LPAREN expression RPAREN
  | constant
  ;
lvalue: identifier
  | lvalue LBRACKET expression RBRACKET
  | lvalue DOT identifier
  ;
actualParams: LPAREN expression actualParamsExprClosure RPAREN
  | LPAREN RPAREN
  ;
actualParamsExprClosure: /* empty */ 
  | actualParamsExprClosure COMMA expression
  ;
recordInits: LBRACE identifier ASSIGN expression recordInitsPairClosure RBRACE
  ;
recordInitsPairClosure: /* empty */
  | recordInitsPairClosure SEMICOLON identifier ASSIGN expression
  ;
arrayInits: LABRACKET arrayInit arrayInitClosure RABRACKET
  ;
arrayInitClosure: /* empty */
  | arrayInitClosure COMMA arrayInit
  ;
arrayInit: expression
  | expression OF expression
  ;
number: INTEGERT
  | REALT
  ;
string: STRINGT { $$ = yylval.Tstring;  }
  ;
identifier: IDENTIFIER
  ;
constant: TRUET
  | FALSET
  | NILT
  ;

%%
int
main (void)
{
  #if YYDEBUG
    yydebug = 1;
  #endif
  yyparse ();
  return 0;
}