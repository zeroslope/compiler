#if !defined(__AST__)
#define __AST__

#include "pcat.h"

// typedef enum {
//   Program,
//   BodyDef,
//   DeclareList,
//   VarDecs,
//   TypeDecs,
//   ProcDecs,
//   VarDec,
//   TypeDec,
//   ProcDec,
//   NamedTyp,
//   ArrayTyp,
//   RecordTyp,
//   NoTyp,
//   CompList,
//   Comp,
//   FormalParamList,
//   Param,
//   AssignSt,
//   CallSt,
//   ReadSt,
//   WriteSt,
//   IfSt,
//   WhileSt,
//   LoopSt,
//   ForSt,
//   ExitSt,
//   RetSt,
//   SeqSt,
//   ExprList,
//   BinOpExp,
//   UnOpExp,
//   LvalExp,
//   CallExp,
//   RecordExp,
//   ArrayExp,
//   IntConst,
//   RealConst,
//   StringConst,
//   RecordInitList,
//   RecordInit,
//   ArrayInitList,
//   ArrayInit,
//   LvalList,
//   Var,
//   ArrayDeref,
//   RecordDeref,

//   Gt,
//   Lt,
//   Eq,
//   Ge,
//   Le,
//   Ne,
//   Plus,
//   Minus,
//   Times,
//   Slash,
//   Div,
//   Mod,
//   And,
//   Or,
//   UPlus,
//   UMinus,
//   Not,

//   TypeInferenceNeeded,
//   VoidType,
//   EmptyStatement,
//   EmptyExpression
// } astKind;

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
  fnc_def,

  // here are added node types

  // -- binary operators
  fdiv_exp,
  mod_exp,
  neq_exp,

  // -- unary operators
  neg_exp,
  pos_exp,

  // -- other operators
  fcall_exp,
  finit_exp,
  ainit_exp,
  args_node,
  ids_node,
  idx_exp,
  mem_exp,
  fasg_node,
  fasg_exp,
  aval_node,
  aval_exp,
  io_node,
  if_node,
  else_node,

  retn_stat,
  exit_stat,
  for_stat,
  while_stat,
  loop_stat,
  asgn_stat,
  read_stat,
  write_stat,

  // -- nodes
  body_node,
  stat_node,

  field_decl,
  proc_decl,
  type_decl,
  var_decl,
  param_node,
  param_sec,
  arr_type,
  rec_type,

  var_decls,
  type_decls,
  proc_decls,

  genr_node,

  ast_kind_size,

} astKind;

static const char* ast_names[] = {
    "if_stat",
    "eq_exp",
    "lt_exp",
    "gt_exp",
    "le_exp",
    "ne_exp",
    "ge_exp",
    "plus_exp",
    "minus_exp",
    "times_exp",
    "div_exp",
    "or_exp",
    "and_exp",
    "not_exp",
    "call_exp",
    "fnc_def",

    // bin opt
    "float_div_exp",
    "mod_exp",
    "neq_exp",

    // unary opt
    "neg_exp",
    "pos_exp",

    // other opt
    "func_call_exp",
    "field_init_exp",
    "array_init_exp",
    "args_node",
    "ids_node",
    "index_exp",
    "member_exp",
    "field_inits_node",
    "field_init_assign",
    "array_values_node",
    "array_value_exp",
    "io_args_node",
    "if_element_node",
    "else_element_node",

    "return_stat",
    "exit_stat",
    "for_stat",
    "while_stat",
    "loop_stat",
    "assign_stat",
    "read_stat",
    "write_stat",

    // nodes
    "body_node",
    "stat_node",

    "field_decl",
    "procedure_decl",
    "type_decl",
    "var_decl",
    "param_node",
    "param_section",
    "array_type",
    "record_type",
    "var_decl_list",
    "type_decl_list",
    "proc_decl_list",

    "general_node",
};

typedef enum { intAst, realAst, varAst, strAst, nodeAst } astTag;

struct ast;
struct astList;

struct ast {
  astTag tag;
  YYLTYPE location;  // 位置信息
  union {
    int integer;
    double real;
    char* variable;
    char* string;
    struct {
      astKind tag;
      astList* arguments;
    } node;
  } info;
};

struct astList {
  ast* elem;
  astList* next;
};

ast* makeInt(const void* loc, const int x);
ast* makeReal(const void* loc, const double x);
ast* makeVar(const void* loc, const char* x);
ast* makeStr(const void* loc, const char* x);
ast* makeNode(const void* loc, const astKind, astList* args);
ast* makeNodeR(const void* locl,
               const void* locr,
               const astKind tag,
               astList* args);

// create an AST node for unary operation
ast* makeUnaryExp(const void* loc, const astKind tag, ast* val);

// create an AST node for binary operation
ast* makeBinExp(const void* loc, const astKind tag, ast* val1, ast* val2);

ast* makeStatBlock(const void* loc, astList* revstat);

ast* makeIdList(const void* locl,
                const void* locr,
                ast* firstid,
                astList* revlst);

/* put an AST e in the beginning of the list of ASTs r */
astList* unshift(ast* e, astList* r);

// create a list with serveral elements
astList* createList(int n, ...);

int length(astList*);

astList* reverse(astList*);

/* printing functions for ASTs */
void printAstList(astList* r);

void printAst(ast* x);
void printAstInternal(ast* x);

#endif  // __AST__