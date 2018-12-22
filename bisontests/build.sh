rm pcat
rm pcat.yy.c
rm *.o
rm pcat.c pcat.h

bison -d --report=state -o pcat.c pcat.y
flex -o pcat.yy.c pcat.lex
gcc pcat.yy.c pcat.c -o pcat