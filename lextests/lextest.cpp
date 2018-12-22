#include <stdio.h>
#include <iostream>
using namespace std;

#define IDENTIFIER 258
#define INTEGERT 259
#define REALT 260
#define STRINGT 261
#define PROGRAM 262
#define IS 263
#define BEGINT 264
#define END 265
#define VAR 266
#define TYPE 267
#define PROCEDURE 268
#define ARRAY 269
#define RECORD 270
#define IN 271
#define OUT 272
#define READ 273
#define WRITE 274
#define IF 275
#define THEN 276
#define ELSE 277
#define ELSIF 278
#define WHILE 279
#define DO 280
#define LOOP 281
#define FOR 282
#define EXIT 283
#define RETURN 284
#define TO 285
#define BY 286
#define AND 287
#define OR 288
#define NOT 289
#define OF 290
#define DIV 291
#define MOD 292
#define LPAREN 293
#define RPAREN 294
#define LBRACKET 295
#define RBRACKET 296
#define LBRACE 297
#define RBRACE 298
#define COLON 299
#define DOT 300
#define SEMICOLON 301
#define COMMA 302
#define ASSIGN 303
#define PLUS 304
#define MINUS 305
#define STAR 306
#define SLASH 307
#define BACKSLASH 308
#define EQ 309
#define NEQ 310
#define LT 311
#define LE 312
#define GT 313
#define GE 314
#define LABRACKET 315
#define RABRACKET 316
#define EOFF 317
#define ERROR 318

#include "pcat.yy.c"

string keywords[] = {
    "identifier", "integer", "real",  "string",    "PROGRAM", "IS",     "BEGIN",
    "END",        "VAR",     "TYPE",  "PROCEDURE", "ARRAY",   "RECORD", "IN",
    "OUT",        "READ",    "WRITE", "IF",        "THEN",    "ELSE",   "ELSIF",
    "WHILE",      "DO",      "LOOP",  "FOR",       "EXIT",    "RETURN", "TO",
    "BY",         "AND",     "OR",    "NOT",       "OF",      "DIV",    "MOD",
    "(",          ")",       "[",     "]",         "{",       "}",      ":",
    ".",          ";",       ",",     ":=",        "+",       "-",      "*",
    "/",          "\\",      "=",     "<>",        "<",       "<=",     ">",
    ">=",         "[<",      ">]",    "EOF",       "ERROR"};

int main(int argc, char* args[]) {
  if (argc > 1) {
    FILE* file = fopen(args[1], "r");
    if (!file) {
      cerr << "Can not open file." << endl;
      return 1;
    } else {
      yyin = file;
      for (;;) {
        short n = yylex();
        if (n == EOFF)
          break;
        if (n < 262)
          cout << keywords[n - 258] << " (" << yytext << ")\n";
        else
          cout << keywords[n - 258] << "\n";
      };
    }
  }
  return 0;
}
