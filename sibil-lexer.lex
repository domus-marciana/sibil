%{
#include <stdio.h>
#include <string.h>

%}

%%
#(.*[ \t]*)*		printf("COMMENT ");
\"([^\"]*[ \t]*)*\"	printf("STRING ");

exit			printf("EXIT ");
print			printf("PRINT ");
input			printf("INPUT ");
mod			printf("MOD ");
is			printf("IS ");
is\ not			printf("IS NOT ");
and			printf("AND ");
or			printf("OR ");
if			printf("IF ");
then			printf("THEN ");
else			printf("ELSE ");

[1-9][0-9]*|0		printf("NUMBER ");
$[a-zA-Z][a-zA-Z0-9]*	printf("STRVAR ");
[a-zA-Z][a-zA-Z0-9]*	printf("VARIABLE ");
\n			printf("LF\n");
[ \t]+			/* IGNORING WHITESPACE */
.			printf("%c ", (int)yytext[0]);
%%
