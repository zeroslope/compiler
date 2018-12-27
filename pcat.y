%{

#include "ast.h"
#include "pcat.yy.c"

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
  ast*        Tast;
  astList*    TastList;
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

%type <Tast>
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

%type <TastList>
  IDClosure
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
start: program { printf("[Accept]\n"); printAst($1); }
  ;
program: PROGRAM IS body SEMICOLON { $$ = $3; }
  ;
body: declarationClosure BEGINT statementClosure END { $$ = makeNode(&(@$), body_node, createList(2, makeNode(&(@1), genr_node, reverse($1)), makeStatBlock(&(@3), $3))); }
  ;
declarationClosure: /* empty */     { $$ = NULL; }
  | declarationClosure declaration  { $$ = unshift($2, $1); }
  ;
declaration: VAR varDeclClosure     { $$ = makeNode(&(@$), var_decls, reverse($2)); }
  | TYPE typeDeclClosure            { $$ = makeNode(&(@$), type_decls, reverse($2)); }
  | PROCEDURE procedureDeclClosure  { $$ = makeNode(&(@$), proc_decls, reverse($2)); }
  ;
statementClosure: /* empty */   { $$ = NULL; }
  | statementClosure statement  { $$ = unshift($2, $1); }
  ;
varDeclClosure: /* empty */ { $$ = NULL; }
  | varDeclClosure varDecl  { $$ = unshift($2, $1); }
  ;
typeDeclClosure: /* empty */  { $$ = NULL; }
  | typeDeclClosure typeDecl  { $$ = unshift($2, $1); }
  ;
procedureDeclClosure: /* empty */       { $$ = NULL; }
  | procedureDeclClosure procedureDecl  { $$ = unshift($2, $1); }
  ;
varDecl: identifier IDClosure typenameOption ASSIGN expression SEMICOLON { $$ = makeNode(&(@$), var_decl, createList(3, makeIdList(&(@1), &(@2), $1, $2), $3, $5)); }
  ;
IDClosure: /* empty */          { $$ = NULL; }
  | IDClosure COMMA identifier  { $$ = unshift($3, $1); }
  ;
typenameOption: /* empty */     { $$ = NULL; }
  | COLON typename              { $$ = $2; }
  ;
typeDecl: identifier IS type SEMICOLON { $$ = makeNode(&(@$), type_decl, createList(1, $3)); }
  ;
procedureDecl: identifier formalParams typenameOption IS body SEMICOLON { $$ = makeNode(&(@$), proc_decl, createList(4, $1, $2, $3, $5)); }
  ;
typename: identifier
  ;
type: ARRAY OF typename                   { $$ = makeNode(&(@$), arr_type, createList(1, $3)); }
  | RECORD component componentClosure END { $$ = makeNode(&(@$), rec_type, unshift($2, reverse($3))); }
  ;
componentClosure: /* empty */   { $$ = NULL; }
  | componentClosure component  { $$ = unshift($2, $1); } 
  ;
component: identifier COLON typename SEMICOLON  { $$ = makeNode(&(@$), field_decl, createList(2, $1, $3)); }
  ;
formalParams: LPAREN RPAREN                   { $$ = makeNode(&(@$), param_node, NULL); }  
  | LPAREN fpSection fpSectionClosure RPAREN  { $$ = makeNode(&(@$), param_node, unshift($2, reverse($3))); }   
  ;
fpSectionClosure: /* empty */             { $$ = NULL; }
  | fpSectionClosure SEMICOLON fpSection  { $$ = unshift($3, $1); }
  ;
fpSection: identifier IDClosure COLON typename  { $$ = makeNode(&(@$), param_sec, createList(2, makeIdList(&(@1), &(@2), $1, $2), $4)); }
  ;
statement: lvalue ASSIGN expression SEMICOLON
                                          { $$ = makeNode(&(@$), asgn_stat, createList(2, $1, $3)); }
  | identifier actualParams SEMICOLON     { $$ = makeNode(&(@$), fcall_exp, createList(2, $1, $2)); }
  | READ LPAREN lvalue statementLvalueClosure RPAREN SEMICOLON
                                          { $$ = makeNode(&(@$), read_stat, unshift($3, reverse($4))); }
  | WRITE writeParams SEMICOLON           { $$ = makeNode(&(@$), write_stat, createList(1, $2)); }
  | IF expression THEN statementClosure
    statementElsifClosure
    statementElseOption 
    END SEMICOLON                         { 
                                              $$ = makeNode(&(@$), if_stat, 
                                                  createList
                                                  (
                                                      3, makeNodeR(&(@1), &(@4), if_node, createList(2, $2, $4)),
                                                      makeStatBlock(&(@5), $5),
                                                      $6
                                                  )
                                              ); 
                                          }
  | WHILE expression DO statementClosure END SEMICOLON
                                          { $$ = makeNode(&(@$), while_stat, createList(2, $2, makeStatBlock(&(@4), $4))); }
  | LOOP statementClosure END SEMICOLON
                                          { $$ = makeNode(&(@$),  loop_stat, createList(1, makeStatBlock(&(@2), $2))); }
  | FOR identifier ASSIGN expression TO expression statementByOption DO statementClosure END SEMICOLON
                                          { $$ = makeNode(&(@$), for_stat, 
                                                createList
                                                (
                                                    5, $2, $4, $6, $7,
                                                    makeStatBlock(&(@9), $9)
                                                )
                                            ); 
                                          }
  | EXIT SEMICOLON                        { $$ = makeNode(&(@$), exit_stat, NULL); }
  | RETURN expressionOption SEMICOLON     { $$ = makeNode(&(@$), exit_stat, NULL); }
  ;
statementLvalueClosure: /* empty */     { $$ = NULL; }
  | statementLvalueClosure COMMA lvalue { $$ = unshift($3, $1); }
  ;
statementElsifClosure: /* empty */                                { $$ = NULL; }
  | statementElsifClosure ELSIF expression THEN statementClosure  { $$ = unshift(makeNodeR(&(@3), &(@5), if_node, createList(2, $3, $5)), $1); }
  ;
statementElseOption: /* empty */  { $$ = NULL; }
  | ELSE statementClosure         { $$ = makeNode(&(@$), else_node, createList(1, $2)); }
  ;
statementByOption: /* empty */  { $$ = NULL; }
  | BY expression               { $$ = $2; }
  ;
writeParams: LPAREN RPAREN                          { $$ = makeNode(&(@$), io_node, NULL); }
  | LPAREN writeExpr writeParamsExprClosure RPAREN  { $$ = makeNode(&(@$), io_node, unshift($2, reverse($3))); }                        
  ;
writeParamsExprClosure: /* empty */         { $$ = NULL; }
  | writeParamsExprClosure COMMA writeExpr  { $$ = unshift($3, $1); }
  ;
writeExpr: string { $$ = $1; }
  | expression    { $$ = $1; }
  ;
expressionOption: /* empty */ { $$ = NULL; }
  | expression                { $$ = $1; }
  ;
expression: orOperand { $$ = $1; }
  ;
orOperand: orOperand OR andOperand      { $$ = makeBinExp(&(@$), or_exp, $1, $3); }
  | andOperand                          { $$ = $1; }
  ;
andOperand: andOperand AND relationship { $$ = makeBinExp(&(@$), and_exp, $1, $3); }
  | relationship                        { $$ = $1; }
  ;
relationship: summand GT summand  { $$ = makeBinExp(&(@$), gt_exp, $1, $3); }
  | summand LT summand            { $$ = makeBinExp(&(@$), lt_exp, $1, $3); }
  | summand EQ summand            { $$ = makeBinExp(&(@$), eq_exp, $1, $3); }
  | summand NEQ summand           { $$ = makeBinExp(&(@$), neq_exp, $1, $3); }
  | summand GE summand            { $$ = makeBinExp(&(@$), ge_exp, $1, $3); }
  | summand LE summand            { $$ = makeBinExp(&(@$), le_exp, $1, $3); }
  | summand                       { $$ = $1; }
  ;
summand: summand PLUS factor  { $$ = makeBinExp(&(@$), plus_exp, $1, $3); }
  | summand MINUS factor      { $$ = makeBinExp(&(@$), minus_exp, $1, $3); }
  | factor                    { $$ = $1; }
  ;
factor: factor STAR unary   { $$ = makeBinExp(&(@$), times_exp, $1, $3); }
  | factor SLASH unary      { $$ = makeBinExp(&(@$), fdiv_exp, $1, $3); }
  | factor DIV unary        { $$ = makeBinExp(&(@$), div_exp, $1, $3); }
  | factor MOD unary        { $$ = makeBinExp(&(@$), mod_exp, $1, $3); }
  | unary                   { $$ = $1; }
  ;
unary: PLUS unary { $$ = makeUnaryExp(&(@$), pos_exp, $2); }
  | MINUS unary   { $$ = makeUnaryExp(&(@$), neg_exp, $2); }
  | NOT unary     { $$ = makeUnaryExp(&(@$), not_exp, $2); }
  | term          { $$ = $1; }
  ;
term: number                  { $$ = $1; }
  | lvalue                    { $$ = $1; }
  | identifier actualParams   { $$ = makeNode(&(@$), fcall_exp, createList(2, $1, $2)); }
  | identifier recordInits    { $$ = makeNode(&(@$), ainit_exp, createList(2, $1, $2)); }
  | identifier arrayInits     { $$ = makeNode(&(@$), finit_exp, createList(2, $1, $2)); }
  | LPAREN expression RPAREN  { $$ = $2; }
  | constant                  { $$ = $1; }
  ;
lvalue: identifier
  | lvalue LBRACKET expression RBRACKET { $$ = makeNode(&(@$), idx_exp, createList(2, $1, $3)); }
  | lvalue DOT identifier               { $$ = makeNode(&(@$), mem_exp, createList(2, $1, $3)); }
  ;
actualParams: LPAREN expression actualParamsExprClosure RPAREN  { $$ = makeNode(&(@$), args_node, unshift($2, reverse($3))); }
  | LPAREN RPAREN                                               { $$ = makeNode(&(@$), args_node, NULL); }
  ;
actualParamsExprClosure: /* empty */          { $$ = NULL; } 
  | actualParamsExprClosure COMMA expression  { $$ = createList(2, $3, $1); }
  ;
recordInits: LBRACE identifier ASSIGN expression recordInitsPairClosure RBRACE { $$ = makeNode(&(@$), fasg_node, unshift(makeNodeR(&(@2), &(@4), fasg_exp, createList(2, $2, $4)), reverse($5))); }
  ;
recordInitsPairClosure: /* empty */                               { $$ = NULL; }
  | recordInitsPairClosure SEMICOLON identifier ASSIGN expression { $$ = unshift(makeNodeR(&(@3), &(@5), fasg_exp, createList(2, $3, $5)), $1); }
  ;
arrayInits: LABRACKET arrayInit arrayInitClosure RABRACKET { $$ = makeNode(&(@$), aval_node, unshift($2, reverse($3))); }
  ;
arrayInitClosure: /* empty */         { $$ = NULL; }
  | arrayInitClosure COMMA arrayInit  { $$ = unshift($3, $1); }
  ;
arrayInit: expression         { $$ = makeNode(&(@$), aval_exp, createList(1, $1)); }
  | expression OF expression  { $$ = makeNode(&(@$), aval_exp, createList(2, $1, $3)); }
  ;
number: INTEGERT  { $$ = makeInt(&(@$), yylval.Tint); }
  | REALT         { $$ = makeReal(&(@$), yylval.Treal); }
  ;
string: STRINGT { $$ = makeStr(&(@$), yylval.Tstring); }
  ;
identifier: IDENTIFIER { $$ = makeVar(&(@$), yylval.Tstring); }
  ;
constant: TRUET { $$ = makeStr(&(@$), yylval.Tstring); }
  | FALSET      { $$ = makeStr(&(@$), yylval.Tstring); }
  | NILT        { $$ = makeStr(&(@$), yylval.Tstring); }
  ;

%%
// for debug
// int
// main (void)
// {
//   #if YYDEBUG
//     yydebug = 1;
//   #endif
//   yyparse ();
//   return 0;
// }

// NOTE: add read_args read_args_optext