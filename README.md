# 疑问
左递归在LALR分析中会有什么影响呢？
actualParams -> 实参

# 流程
1. 阅读《PCAT语言参考指南》,整理出ebnf范式
2. ebnf -> bnf
  1. varDeclType0 & procedureDeclType0 重复
  2. varDeclIDArray & fpSectionIDArray
3. bnf -> bnf-fixed 
  1. %option yylineno ⚠️： 词法分析器本身并不会初始化yylineno
  2. bison处理左递归要比处理右递归更有效率
    * $ 在语义动作中，$引入一个值的引用
    * @ 在语义动作中，@引入一个位置
    * ' 文字记号用单引号引起
    <!-- * <> 在语义动作的值引用中，可以通过在尖括号中类型名来覆盖默认的值类型。 -->
    * %union 标识出符号值可能拥有的所有C类型
    * %type 声明非终结符的类型 %type <type> name name ...
4. 继续整理bnf
  1. varDeclIDClosure 和 fpSectionIDClosure 合并为 IDClosure
    ```bison
    A -> A ',' identifier
      -> 
    ```
  2. change 0 to Option
  3. add constant
  4. varDeclType0 和 procedureDeclType0 合并为 typenameOption
    ```bison
    A -> ':' typename
      ->
    ```
5. pcat.l
  1. YY_USER_ACTION
    The YY_USER_ACTION macro is "called" before each of your token actions and updates yylloc.

    https://www.gnu.org/software/bison/manual/html_node/Location-Type.html#Location-Type
    ```c
    typedef struct YYLTYPE
    {
      int first_line;
      int first_column;
      int last_line;
      int last_column;
    } YYLTYPE;
    ```
  2. %option noyywrap