GCC = g++
CFLAGS = -O0 -g -fno-omit-frame-pointer
YACC = bison
LEX = flex

all: parser

parser: main.cpp ast.h pcat.o ast.o
	$(GCC) $(CFLAGS) main.cpp pcat.o ast.o -o parser

ast.o:  ast.cpp ast.h pcat.h
	$(GCC) $(CFLAGS) -c ast.cpp

pcat.c: pcat.y
	$(YACC) -d -v -g -o pcat.c pcat.y

pcat.o: pcat.c pcat.yy.c ast.h
	$(GCC) $(CFLAGS) -c pcat.c

pcat.yy.c: pcat.lex
	$(LEX) -o pcat.yy.c pcat.lex

clean:
	rm -f *.o *~ pcat.yy.c pcat.c pcat.output parser