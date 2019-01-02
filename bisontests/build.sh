rm pcat
rm pcat.yy.c
rm *.o
rm pcat.c pcat.h

bison -d --report=state -o pcat.c pcat.y
flex -o pcat.yy.c pcat.lex
gcc pcat.yy.c pcat.c -o pcat

./pcat < ../tests/test01.pcat > ./out/test01.out
./pcat < ../tests/test02.pcat > ./out/test02.out
./pcat < ../tests/test03.pcat > ./out/test03.out
./pcat < ../tests/test05.pcat > ./out/test05.out
./pcat < ../tests/test07.pcat > ./out/test07.out
./pcat < ../tests/test08.pcat > ./out/test08.out
./pcat < ../tests/test12.pcat > ./out/test12.out
./pcat < ../tests/test15.pcat > ./out/test15.out
./pcat < ../tests/test16.pcat > ./out/test16.out
./pcat < ../tests/test17.pcat > ./out/test17.out
./pcat < ../tests/test19.pcat > ./out/test19.out
./pcat < ../tests/test20.pcat > ./out/test20.out