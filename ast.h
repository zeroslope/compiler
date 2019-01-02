#ifndef __AST__
#define __AST__

typedef enum {
  if_stat = 0,
  eq_exp,
  lt_exp,
  gt_exp,
  le_exp,
  ne_exp,
  ge_exp,
  plus_exp,
  minus_exp,
  times_exp,
  div_exp,
  or_exp,
  and_exp,
  not_exp,
  call_exp,

  fdiv_exp,
  mod_exp,
  neq_exp,

  neg_exp,
  pos_exp,

  fcall_exp,
  finit_exp,
  ainit_exp,
  args_node,
  ids_node,
  idx_exp,
  mem_exp,
  record_node,
  record_exp,
  array_node,
  array_exp,
  io_node,
  if_node,
  else_node,

  retn_stat,
  exit_stat,
  for_stat,
  while_stat,
  loop_stat,
  assign_stat,
  read_stat,
  write_stat,

  // -- nodes
  body_node,
  stat_node,

  component_decl,
  procedure_decl,
  type_decl,
  var_decl,
  param_node,
  param_sec,
  array_type,
  record_type,

  var_decls,
  type_decls,
  procedure_decls,

  genr_node,

  ast_kind_size,

} astKind;

static const char* ast_names[] = {
    "IfSt",
    "eqExp",
    "ltExp",
    "gtExp",
    "leExp",
    "neExp",
    "geExp",
    "plusExp",
    "minusExp",
    "timesExp",
    "divExp",
    "orExp",
    "andExp",
    "notExp",
    "callExp",

    // bin opt
    "floatDivExp",
    "modExp",
    "neqExp",

    // unary opt
    "negExp",
    "posExp",

    // other opt
    "funcCallExp",
    "fieldInitExp",
    "arrayInitExp",
    "argsNode",
    "idsNode",
    "indexExp",
    "memberExp",
    "fieldInitsNode",
    "fieldInitAssign",
    "arrayValuesNode",
    "arrayValueExp",
    "ioArgsNode",
    "ifElementNode",
    "elseElementNode",

    "returnSt",
    "exitSt",
    "forSt",
    "whileSt",
    "loopSt",
    "assignSt",
    "readSt",
    "writeSt",

    // nodes
    "bodyNode",
    "statNode",

    "componentDecl",
    "procedureDecl",
    "typeDecl",
    "varDecl",
    "paramNode",
    "paramSection",
    "arrayType",
    "recordType",
    "varDeclList",
    "typeDeclList",
    "procedureDeclList",

    "declarationNode",
};

typedef enum { intAst, realAst, varAst, strAst, nodeAst } astTag;

typedef struct astLoction {
  int first_line;
  int first_column;
  int last_line;
  int last_column;
} astLoction;

typedef struct ast {
  astTag tag;
  astLoction location;  // 位置信息
  union {
    int integer;
    double real;
    char* variable;
    char* string;
    struct {
      astKind tag;
      struct astList* arguments;
    } node;
  } info;
} ast;

typedef struct astList {
  ast* elem;
  struct astList* next;
} astList;

ast* makeInt(const void* loc, const int x);
ast* makeReal(const void* loc, const double x);
ast* makeVar(const void* loc, const char* x);
ast* makeStr(const void* loc, const char* x);
ast* makeNode(const void* loc, const astKind, astList* args);
ast* makeNodeR(const void* locl,
               const void* locr,
               const astKind tag,
               astList* args);

ast* makeUnaryExp(const void* loc, const astKind tag, ast* val);

ast* makeBinExp(const void* loc, const astKind tag, ast* val1, ast* val2);

ast* makeStatBlock(const void* loc, astList* revstat);

ast* makeIdList(const void* locl,
                const void* locr,
                ast* firstid,
                astList* revlst);

astList* unshift(ast* e, astList* r);

astList* createList(int n, ...);

int length(astList*);

astList* reverse(astList*);

void printAst(ast* x);
void printAstList(astList* r);
void printAstInternal(ast* x);

#endif  // __AST__