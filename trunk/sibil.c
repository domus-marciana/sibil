#include <stdio.h>
#include <string.h>

#define BIGNUM	10000
#define TBLPTR	struct HashTable*
#define VTYPE	int
#define VINT	0
#define VSTR	1

#define BOOL	int
#define TRUE	1
#define FALSE	0

BOOL	interactive;

struct HashTable
{
	char* varName;
	void* ptrVal;
	VTYPE varType;
};

TBLPTR	listVars;
int	numVariables;
int	stack[BIGNUM];
int	stackPos;
char*	printStack[BIGNUM];
int	printPos;
BOOL	ifStack[BIGNUM];
int	ifPos;

void clean()
{
	int i;
	for(i=0; i<numVariables; ++i)
	{
		if(listVars[i].ptrVal)
			free(listVars[i].ptrVal);
	}
	free(listVars);
	numVariables = 0;
	stackPos = 0;
	printPos = 0;
}

void cleanexit(int exitStat)
{
	clean();
	if(interactive) printf("\nBye.\n");
	exit(exitStat);
}

/*
void dumpTable()
{
	int i;
	printf("[ ");
	for(i=0; i<numVariables; ++i)
	{
		switch(listVars[i].varType)
		{
			case VINT:
				printf("%s=%d ",
					listVars[i].varName,
					*((int*)listVars[i].ptrVal)
				      );
				break;
			case VSTR:
				printf("%s=%s ",
					listVars[i].varName,
					*((char**)listVars[i].ptrVal)
				      );
				break;
		}
	}
	printf("]\n");
}

void dumpStack()
{
	int i;
	printf("[");
	for(i=0; i<stackPos-1; ++i) printf("%d, ", stack[i]);
	printf("%d]\n", stack[stackPos-1]);
}
*/

void dumpPrintStack(int i)
{
	if(i > 0) dumpPrintStack(i-1);
	printf("%s", printStack[i]);
}

TBLPTR findIndex(const char* str)
{
	int i;
	for(i=0; i<numVariables; ++i)
		if(!strcmp(listVars[i].varName, str)) return listVars+i;
	return NULL;
}

void Push(int val)
{
//	printf("Push onto stack: %d\n", val);
	stack[stackPos++] = val;
//	dumpStack();
}

int Pop()
{
	return stack[--stackPos];
}

BOOL ifTop()
{
	return ifStack[ifPos-1];
}

BOOL ifPop()
{
	return ifStack[--ifPos];
}

void ifPush(BOOL val)
{
	ifStack[ifPos++] = val;
}

void PushPrint(const char* str)
{
	printStack[printPos++] = strdup(str);
//	printf("%d: %s pushed to %s\n", printPos-1, str, printStack[printPos-1]);
}
