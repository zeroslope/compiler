rm pcat.yy.c
rm lextest

flex -o pcat.yy.c ../pcat.lex
g++ lextest.cpp -o lextest

./lextest ../tests/test01.pcat > ./out/test01.out
./lextest ../tests/test02.pcat > ./out/test02.out
./lextest ../tests/test03.pcat > ./out/test03.out
./lextest ../tests/test05.pcat > ./out/test05.out
./lextest ../tests/test07.pcat > ./out/test07.out
./lextest ../tests/test08.pcat > ./out/test08.out
./lextest ../tests/test12.pcat > ./out/test12.out
./lextest ../tests/test15.pcat > ./out/test15.out
./lextest ../tests/test16.pcat > ./out/test16.out
./lextest ../tests/test17.pcat > ./out/test17.out
./lextest ../tests/test19.pcat > ./out/test19.out
./lextest ../tests/test20.pcat > ./out/test20.out