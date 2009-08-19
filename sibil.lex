%{
#include <stdio.h>
#include <string.h>
#include "sibil.tab.h"

#define	BOOL	int
#define	TRUE	1
#define	FALSE	0

char buffer[10000];

int main(int argc, char** argv)
{
	BOOL myia;

	if(argc > 1)
	{
		if(argc > 2) yyerror("invalid arguments");
		yyin = fopen(argv[1], "r");
		if(!yyin) yyerror("no input file");
		myia = FALSE;
	}
	else
	{
		myia = TRUE;
		yyin = stdin;
	}

	init(myia);
	yyparse();
	fclose(yyin);
	cleanexit(0);
}

%}

%%
#(.*[ \t]*)*\n		/* IGNORING COMMENT */
\"([^\"]*[ \t]*)*\"	memset(buffer, 0, sizeof(buffer)); strncpy(buffer, yytext+1, strlen(yytext)-2); yylval.string=strdup(buffer); return STRING;

exit			return EXIT;
print			return PRINT;
input			return INPUT;
mod			return MOD;
if			return IF;
then			return THEN;
is\ not			return IS_NOT;
is			return IS;
else			return ELSE;
;;			return ENDIF;
and			return AND;
or			return OR;
not			return NOT;

[1-9][0-9]*|0		yylval.number=atoi(yytext); return NUMBER;
$[a-zA-Z][a-zA-Z0-9]*	yylval.string=strdup(yytext+1); return STRVAR;
[a-zA-Z][a-zA-Z0-9]*	yylval.string=strdup(yytext); return VARIABLE;
\n			return LF;
[ \t]+			/* IGNORING WHITESPACE */
.			return (int)yytext[0];
%%
