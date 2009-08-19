%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "sibil.c"

#define	BIGNUM	10000

int	temp;
char	buffer[BIGNUM];

void yyerror(const char* str)
{
	fprintf(stderr, "error: %s\n", str);
	cleanexit(0);
}

int yywrap()
{
	return 1;
}

void init(BOOL init_ia)
{
	interactive = init_ia;
	numVariables = 0;
	stackPos = 0;
	printPos = 0;
	ifPos = 0;
	ifPush(TRUE);

	listVars = (TBLPTR)malloc(sizeof(struct HashTable)*BIGNUM);

	if(interactive) printf("amanda 0.1\nCopyright (C) 2009 Zee Zuo\n>>> ");
}

%}

%token EXIT PRINT INPUT MOD LF IF IS IS_NOT THEN ELSE ENDIF AND OR NOT IFX

%nonassoc IFX
%nonassoc ELSE

%union
{
	int number;
	char* string;
}

%token <number> NUMBER;
%token <string> VARIABLE STRING STRVAR;

%type <number> expr input;

%left IS IS_NOT
%left '+' '-'
%left '*' '/' MOD

%%
commands: /* epsilon */
	| commands command LF { if(interactive) printf(">>> "); }
	;

command: /* epsilon */
       | set_value
       | print_var
       | exit_prog
       | if_block
       ;

if_block: if_else %prec ELSE
	| if_then %prec IFX

if_else:  nonblock_if_first_part command_and_pop nonblock_else_part command_and_pop
       |  block_if_first_part commands_and_pop block_else_part commands_and_pop ENDIF
       ;

if_then:  nonblock_if_first_part command_and_pop
       |  block_if_first_part commands_and_pop ENDIF
       ;

nonblock_if_first_part: IF expr THEN	{ ifTop() ? ifPush($2) : ifPush(0); }
command_and_pop:	command		{ temp=ifPop(); }
nonblock_else_part:	ELSE		{ ifTop() ? ifPush(!temp) : ifPush(0); }
block_if_first_part:	IF expr ':' LF	{ ifTop() ? ifPush($2) : ifPush(0); }
commands_and_pop:	commands	{ temp=ifPop(); }
block_else_part:	ELSE ':' LF	{ ifTop() ? ifPush(!temp) : ifPush(0); }

input:
    INPUT '(' STRING ')'
    {
	char a;
    	if(ifTop())
	{
		printf("%s", $3); scanf("%d", &temp);
		$$ = temp;
		while(1)
		{
			a=getchar();
			if(a=='\n') break;
			if(a!=' ' && a!='\t') yyerror("input not recognized");
		}
	}
    }
    | INPUT '(' ')'
    {
	char a;
    	if(ifTop())
	{
		scanf("%d", &temp);
		$$ = temp;
		while(1)
		{
			a=getchar();
			if(a=='\n') break;
			if(a!=' ' && a!='\t') yyerror("input not recognized");
		}
	}
    }

expr: VARIABLE		
      {
		TBLPTR index = findIndex($1);
//		printf("%s found at postition %d with value %d\n", $1, index, listValues[index]);
		if(!index) yyerror("var undefined");
		if(index->varType != VINT) yyerror("var not number");
		else $$ = *((int*)index->ptrVal);
    }
    | NUMBER		{ $$ = $1; }
    | input		
    | expr '+' expr	{ $$ = $1 + $3; }
    | expr '-' expr	{ $$ = $1 - $3; }
    | expr '*' expr	{ $$ = $1 * $3; }
    | expr '/' expr
    {
    	if(!$3) yyerror("divide by zero");
	$$ = $1 / $3;
    }
    | expr MOD expr
    { 
    	if(!$3) yyerror("divide by zero");
	$$ = $1 % $3;
    }
    | expr IS expr	{ $$ = ($1 == $3); }
    | expr IS_NOT expr	{ $$ = ($1 != $3); }
    | expr '<' expr	{ $$ = ($1 < $3); }
    | expr '>' expr	{ $$ = ($1 > $3); }
    | expr AND expr	{ $$ = ($1 && $3); }
    | expr OR expr	{ $$ = ($1 || $3); }
    | NOT expr		{ $$ = !($2); }
    | '(' expr ')'	{ $$ = $2; }
    ;

print_list: print_item
	  | print_list ',' print_item
	  ;

print_item: STRING	{ if(ifTop()) PushPrint($1); }
	  | STRVAR
	  {
	  	if(ifTop())
		{
	//	  	dumpTable();
	//	  	printf("Attempting to print variable %s\n", $1);
			TBLPTR index = findIndex($1);
			if(!index) yyerror("var undefined");
			if(index->varType != VSTR) yyerror("var not string");
			PushPrint(*((char**)index->ptrVal));
		}
	  }
	  | expr
	  {
	  	if(ifTop())
		{
			sprintf(buffer, "%d", $1);
			PushPrint(buffer);
		}
	  }
	  ; 

set_value:
	   VARIABLE '=' expr
	   { 
	   	if(ifTop())
		{
			TBLPTR index = findIndex($1);
			int rvalue = $3;
			if(!index)
			{
				listVars[numVariables].varType = VINT;
				listVars[numVariables].varName = strdup($1);
				listVars[numVariables].ptrVal = malloc(sizeof(int));
				*((int*)listVars[numVariables].ptrVal) = rvalue;
	//			printf("NEW VARIABLE %s SET TO %d\n",
	//				$1, rvalue);
				++numVariables;
			}
			else
			{
				if(index->varType != VINT) yyerror("wrong type");
				*((int*)index->ptrVal) = rvalue;
	//			printf("EXISTING VARIABLE %s SET TO %d\n",
	//				$1, rvalue);
			}
	//		printf("%d items remaining on stack\n", stackPos);
	//		dumpTable();
		}
	   }
	   |
	   STRVAR '=' STRING
	   {
	   	if(ifTop())
		{
			TBLPTR index = findIndex($1);
			if(!index)
			{
				listVars[numVariables].varType = VSTR;
				listVars[numVariables].varName = strdup($1);
				listVars[numVariables].ptrVal = malloc(sizeof(char)*BIGNUM);
				*((char**)listVars[numVariables].ptrVal) = strdup($3);
				++numVariables;
			}
			else
			{
				if(index->varType != VSTR) yyerror("wrong type");
				*((char**)index->ptrVal) = strdup($3);
			}
	//		dumpTable();
		}
	   }
	   ;

print_var:
	  PRINT print_list
	  {
	  	if(ifTop())
		{
	//	  	printf("POS=%d", printPos);
			dumpPrintStack(printPos-1);
			printf("\n");
			printPos = 0;
		}
	  }
	  ;

exit_prog:
	 EXIT '(' NUMBER ')'
	 { 
	 	if(ifTop()) cleanexit($3);
	 }
%%
