all: sibil lexer

sibil: sibil.yy.c sibil.tab.c
	gcc -o sibil sibil.yy.c sibil.tab.c
sibil.yy.c: sibil.lex
	lex -o sibil.yy.c sibil.lex
sibil.tab.c: sibil.y
	yacc -d -o sibil.tab.c sibil.y
lexer: lexer.yy.c
	gcc -lfl -o lexer lexer.yy.c
lexer.yy.c: sibil-lexer.lex
	lex -o lexer.yy.c sibil-lexer.lex

clean:
	rm -f sibil.yy.c sibil.tab.c lexer.yy.c lexer.yy.h
