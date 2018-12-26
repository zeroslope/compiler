#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ast.h"

void setLocation(ast* tree, const void* loc) {
  const YYLTYPE* locptr = (YYLTYPE*)loc;
  if (tree && locptr) {
    tree->location = *locptr;
  }
}

static YYLTYPE comb_loc_result;
const void* combineLocation(const void* locl, const void* locr) {
  YYLTYPE ll = *(YYLTYPE*)locl;
  YYLTYPE lr = *(YYLTYPE*)locr;

  comb_loc_result.first_line = ll.first_line;
  comb_loc_result.last_line = lr.last_line;
  comb_loc_result.first_column = ll.first_column;
  comb_loc_result.last_column = lr.last_column;

  return &comb_loc_result;
}

ast* makeInt(const void* loc, const int x) {
  ast* res = new ast;
  res->tag = intAst;
  res->info.real = x;
  setLocation(res, loc);
  return res;
}

ast* makeReal(const void* loc, const double x) {
  ast* res = new ast;
  res->tag = realAst;
  res->info.real = x;
  setLocation(res, loc);
  return res;
}

ast* makeVar(const void* loc, const char* x) {
  ast* res = new ast;
  res->tag = varAst;
  res->info.variable = (char*)malloc(strlen(x) + 1);
  strcpy(res->info.variable, x);
  setLocation(res, loc);
  return res;
}

ast* makeStr(const void* loc, const char* x) {
  ast* res = new ast;
  res->tag = varAst;
  res->info.variable = (char*)malloc(strlen(x) + 1);
  strcpy(res->info.variable, x);
  setLocation(res, loc);
  return res;
}

ast* makeNode(const void* loc, const astKind tag, astList* args) {
  ast* res = new ast;
  res->tag = nodeAst;
  res->info.node.tag = tag;
  res->info.node.arguments = args;

  const YYLTYPE* locptr = (YYLTYPE*)loc;
  if (locptr) {
    res->location = *locptr;
  }
  return res;
}

ast* makeNodeR(const void* locl,
               const void* locr,
               const astKind tag,
               astList* args) {
  return makeNode(combineLocation(locl, locr), tag, args);
}

/* put an AST e in the beginning of the list of ASTs r */
astList* unshift(ast* e, astList* r) {
  astList* res = new astList;
  res->elem = e;
  res->next = r;
  return res;
}

int length(astList* r) {
  int i = 0;
  for (; r != NULL; r = r->next)
    i++;
  return i;
}

astList* rev(astList* r, astList* s) {
  if (r == NULL) {
    return s;
  }
  return rev(r->next, unshift(r->elem, s));
}

astList* reverse(astList* r) {
  return rev(r, NULL);
}

void printAstList(astList* r) {
  if (r == NULL)
    return;
  printf(" ");
  printAstInternal(r->elem);
  printAstList(r->next);
};

static int tabs = 0;
static YYLTYPE* lastloc = NULL;

void printAst(ast* x) {
  tabs = 0;
  lastloc = NULL;
  printAstInternal(x);
}

void printAstInternal(ast* x) {
  if (x) {
    switch (x->tag) {
      case intAst:
        printf("%d", x->info.integer);
        break;
      case realAst:
        printf("%lf", x->info.real);
        break;
      case varAst:
        printf("%s", x->info.variable);
        break;
      case strAst:
        printf("\"%s\"", x->info.string);
        break;
      case nodeAst: {
        // deal with indent
        int dtabs = 0;

        if (lastloc && x->location.first_line > lastloc->first_line)
          dtabs = 1;

        lastloc = &x->location;
        tabs += dtabs;

        if (dtabs) {
          printf("\n");
          for (int i = 0; i < tabs; i++)
            printf("\t");
        }

        // print ast
        printf("(%s[%d,%d:%d]", ast_names[x->info.node.tag],
               x->location.first_line, x->location.first_column,
               x->location.last_column);
        printAstList(x->info.node.arguments);
        printf(")");

        // indent(tail)
        tabs -= dtabs;
        break;
      }
    }
  } else
    printf("(NULL)");
}

// add
ast* makeUnaryExp(const void* loc, const astKind tag, ast* val) {
  astList* children = unshift(val, NULL);
  ast* r = makeNode(loc, tag, children);
  return r;
}

// add
ast* makeBinExp(const void* loc, const astKind tag, ast* val1, ast* val2) {
  astList* rch = unshift(val2, NULL);
  astList* lch = unshift(val1, rch);
  ast* r = makeNode(loc, tag, lch);
  return r;
}

ast* makeStatBlock(const void* loc, astList* revstat) {
  ast* r = makeNode(loc, stat_node, reverse(revstat));
  return r;
}

ast* makeIdList(const void* locl,
                const void* locr,
                ast* firstid,
                astList* revlst) {
  ast* r;
  astList* lst = reverse(revlst);

  if (firstid)
    lst = unshift(firstid, lst);

  r = makeNode(combineLocation(locl, locr), ids_node, lst);
  return r;
}

astList* createList(int n, ...) {
  astList* r = NULL;

  va_list vl;
  va_start(vl, n);
  {
    int i;
    for (int i = 0; i < n; i++) {
      r = unshift(va_arg(vl, ast*), r);
    }
  }
  va_end(vl);

  r = reverse(r);
  return r;
}

int main() {
  YYLTYPE locl;
  locl.first_line = 1;
  locl.last_line = 1;
  locl.first_column = 1;
  locl.last_column = 4;
  printf("Location a: %d %d %d %d\n", locl.first_column, locl.last_column,
         locl.first_line, locl.last_line);

  YYLTYPE locr;
  locr.first_line = 1;
  locr.last_line = 1;
  locr.first_column = 6;
  locr.last_column = 8;
  printf("Location a: %d %d %d %d\n", locr.first_column, locr.last_column,
         locr.first_line, locr.last_line);

  ast* a = makeInt(&locl, 123);
  ast* b = makeStr(&locr, "ha");

  astList* lst = createList(2, a, b);

  ast* node = makeNodeR(&locl, &locr, body_node, lst);

  printAstList(lst);
  printAst(node);
}
