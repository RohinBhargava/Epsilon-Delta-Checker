%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include "function.h"

	void yyerror(char *); 
	int yylex(void);

%}

%token RPARENTHESIS LPARENTHESIS VARIABLE NUMBER EOLN MULTIPLY DIVIDE ADD SUBTRACT EXPONENT

%union {
	struct function *fun;
	double du;
}

%type<du> expression exponent parenthesis number
%start print

%%

	print
		: expression { yylval.du = $1; YYACCEPT; }	
		;

	expression
		: expression MULTIPLY exponent { $$ = $1 * $3; }
		| expression DIVIDE exponent { $$ = $1 / $3; }
		| expression ADD exponent { $$ = $1 + $3; }
		| expression SUBTRACT exponent{ $$ = $1 - $3; }
		| exponent { $$ = $1; }
		;		

	exponent
		: exponent EXPONENT parenthesis { $$ = pow($1,$3); }
		| parenthesis { $$ = $1; }
		;

	parenthesis
		: LPARENTHESIS expression RPARENTHESIS { $$ = $2; }
		| number exponent { $$ = $1 * $2; }
		| number { $$ = $1; }
		;

	number
		: NUMBER { $$ = yylval.fun->dub; }
		| VARIABLE { $$ = yylval.fun->c; }
		;

%%

