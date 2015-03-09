%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include "function.h"

	void yyerror(char *); 
	int yylex(void);

%}

%token RPARENTHESIS LPARENTHESIS VARIABLE NUMBER EOLN MULTIPLY DIVIDE ADD SUBTRACT EXPONENT COS SIN TAN SEC CSC COT E ARCSIN ARCCOS ARCTAN ARCSEC ARCCSC ARCCOT LN LOG SQRT

%union {
	struct function *fun;
	double du;
}

%type<du> expression exponent parenthesis number prec md
%start print

%%

	print
		: expression { yylval.du = $1; YYACCEPT; }	
		;

	expression
		: expression ADD md { $$ = $1 + $3; }
		| expression SUBTRACT md{ $$ = $1 - $3; }
		| md { $$ = $1; }
		;		

	md
		: md MULTIPLY exponent { $$ = $1 * $3; }
        | md DIVIDE exponent { $$ = $1 / $3; }
		| exponent { $$ = $1; }
		;

	exponent
		: exponent EXPONENT prec { $$ = pow($1,$3); }
		| prec { $$ = $1; }
		;

	prec
		: SIN parenthesis { $$ = sin($2); }
		| COS parenthesis { $$ = cos($2); }
		| TAN parenthesis { $$ = tan($2); }
		| SEC parenthesis { $$ = 1/(cos($2)); }
		| CSC parenthesis { $$ = 1/(sin($2)); }
		| COT parenthesis { $$ = 1/(tan($2)); }
		| ARCSIN parenthesis { $$ = asin($2); }
		| ARCCOS parenthesis { $$ = acos($2); }
		| ARCTAN parenthesis { $$ = atan($2); }
		| ARCSEC parenthesis { $$ = 1/(acos($2)); }
		| ARCCSC parenthesis { $$ = 1/(asin($2)); }
		| ARCCOT parenthesis { $$ = 1/(atan($2)); }
		| LN parenthesis { $$ = log($2); }
		| LOG parenthesis { $$ = log10($2); }
		| SQRT parenthesis { $$ = sqrt($2); }
        | SUBTRACT parenthesis { $$ = -1 * $2; }
		| parenthesis { $$ = $1; }
		;

	parenthesis
		: LPARENTHESIS expression RPARENTHESIS { $$ = $2; }
        | number parenthesis { $$ = $1 * $2; }
		| number { $$ = $1; }
		;


	number
		: NUMBER { $$ = yylval.fun->dub; }
		| E { $$ = M_E; }
		| VARIABLE { $$ = yylval.fun->c; }
		;

%%

