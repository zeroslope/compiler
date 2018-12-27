#include <iostream>
#include <stdio.h>
#include "ast.h"

int yyparse();
extern "C" FILE* yyin;

int main(int argc, char* args[]) {
  if (argc > 1) {
    FILE *file = fopen(args[1], "r");
    if (!file) {
      std::cerr << "Can not open file." << std::endl;
      return 1;
    } else {
      yyin = file;
    }
  }

  yyparse();

  printf("\n[END]\n");

  return 0;
}
