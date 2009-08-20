%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
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
	// stackPos = 0;
	printPos = 0;
	ifPos = 0;
	ifPush(TRUE);

	listVars = (TBLPTR)malloc(sizeof(struct HashTable)*BIGNUM);

	if(interactive) printf("sibil 0.1\nCopyright (C) 2009 Zee Zuo\n>>> ");
}

%}

%token EXIT PRINT INPUT MOD LF IF IS IS_NOT THEN ELSE END AND OR NOT IFX
%token WHILE DO HELP GT LT GE LE SQRT RAISED_TO

%nonassoc IFX
%nonassoc ELSE

%union
{
	long number;
	char* string;
}

%token <number> NUMBER;
%token <string> VARIABLE STRING STRVAR;

%type <number> expr input;

%left EXIT PRINT INPUT WHILE DO IF HELP END LF
%left AND OR
%right NOT
%left IS IS_NOT
%left GT LT GE LE
%left '+' '-'
%left '*' '/' MOD
%right RAISED_TO
%right SQRT

%%
commands: /* epsilon */
	| commands command LF { if(interactive) printf("%s ", (ifPos > 1) ? "..." : ">>>"); }
	;

command: /* epsilon */
       | show_help
       | set_value
       | print_var
       | exit_prog
       | if_block
       | while_block
       ;

show_help: HELP
	 {
	 	if(interactive) showHelp();
		else yyerror("syntax error");
	}

if_block: if_else %prec ELSE
	| if_then %prec IFX

if_else:  nonblock_if_first_part command_and_pop nonblock_else_part command_and_pop
       |  block_if_first_part commands_and_pop block_else_part commands_and_pop END
       ;

if_then:  nonblock_if_first_part command_and_pop
       |  block_if_first_part commands_and_pop END
       ;

nonblock_if_first_part: IF expr THEN	{ ifTop() ? ifPush($2) : ifPush(0); }
command_and_pop:	command		{ temp=ifPop(); }
nonblock_else_part:	ELSE		{ ifTop() ? ifPush(!temp) : ifPush(0); }
block_if_first_part:	IF expr ':'	{ ifTop() ? ifPush($2) : ifPush(0); }
commands_and_pop:	commands	{ temp=ifPop(); }
block_else_part:	ELSE ':'	{ ifTop() ? ifPush(!temp) : ifPush(0); }

while_block: WHILE expr
	     DO command
	     |
	     WHILE expr ':'
	     commands
	     END
	     ;

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
		else $$ = *((long*)index->ptrVal);
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
    | expr LT expr	{ $$ = ($1 < $3); }
    | expr GT expr	{ $$ = ($1 > $3); }
    | expr LE expr	{ $$ = ($1 <= $3); }
    | expr GE expr	{ $$ = ($1 >= $3); }
    | SQRT '(' expr ')'	{ $$ = sqrt($3); }
    | expr AND expr	{ $$ = ($1 && $3); }
    | expr OR expr	{ $$ = ($1 || $3); }
    | NOT expr		{ $$ = !($2); }
    | expr RAISED_TO expr
    			{ $$ = pow($1, $3); }
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
			long rvalue = $3;
			if(!index)
			{
				listVars[numVariables].varType = VINT;
				listVars[numVariables].varName = strdup($1);
				listVars[numVariables].ptrVal = malloc(sizeof(long));
				*((long*)listVars[numVariables].ptrVal) = rvalue;
	//			printf("NEW VARIABLE %s SET TO %d\n",
	//				$1, rvalue);
				++numVariables;
			}
			else
			{
				if(index->varType != VINT) yyerror("wrong type");
				*((long*)index->ptrVal) = rvalue;
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
