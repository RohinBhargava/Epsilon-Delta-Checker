%{
	#include <stdio.h>
	#include "y.tab.h"
	#include "function.h"
	#include "float.h"
	#include "math.h"
	#include <stdbool.h>
	#include <string.h>

	int yyparse();

	#undef ECHO
	#define ECHO printf ("[%s]\n", yytext)
	
%}

%option noyywrap

%%

[ \t\n]	;
"cos"	{ return COS; }
"sin"	{ return SIN; }
"tan"	{ return TAN; }
"sec"	{ return SEC; }
"csc"	{ return CSC; }
"cot"	{ return COT; }
"e"		{ return E; }
"arcsin" { return ARCSIN; }
"arccos" { return ARCCOS; }
"arctan"	{ return ARCTAN; }
"arcsec"	{ return ARCSEC; }
"arccsc"	{ return ARCCSC; }
"arccot"	{ return ARCCOT; }
"ln"		{ return LN; }
"log"		{ return LOG; }
"sqrt"		{ return SQRT; }
\( 		{ return LPARENTHESIS; }
\)		{ return RPARENTHESIS; }
\^		{ return EXPONENT; }
\*		{ return MULTIPLY; }
\/		{ return DIVIDE; }
\+		{ return ADD; }
\-		{ return SUBTRACT; }
[xX]		{ return VARIABLE; }
[0-9\.]* { sscanf(yytext, "%lf", &yylval.fun->dub); return NUMBER; }
. { printf("Invalid input. Exiting.\n"); exit(0); }

%%

bool contains_x(char *func)
{
	int i;
	for(i = 0; i < strlen(func); i++)
		if (func[i] == 'x' || func[i] == 'X')
			return true;
	return false;
}

function* init_function(double c)
{
	function *returner = (function *) calloc(1, sizeof(function));

	returner->c = c;
	returner->dub = 0;

	return returner;
}

void free_func(function *f)
{
	free(f);
}

double solve_delta(double epsilon, double fvalue, double c, char *function)
{
	double loopNumUp = 0;
	double loopNumDown = 0; 
	double ub = c;
	double lb = c;
	bool ud = false;
	while (1) {
		yylval.fun = init_function((ub += 0.0000001));
		YY_BUFFER_STATE my_string_buffer = yy_scan_string(function); 
		yy_switch_to_buffer( my_string_buffer ); 
		yyparse(); 
		yy_delete_buffer(my_string_buffer );
		loopNumUp = fabs(yylval.du - fvalue);
		if (loopNumUp >= epsilon) {
			ud = true;
			break;
		}

		yylval.fun = init_function((lb -= 0.0000001));
		my_string_buffer = yy_scan_string(function); 
		yy_switch_to_buffer( my_string_buffer ); 
		yyparse(); 
		yy_delete_buffer(my_string_buffer );
		loopNumDown = fabs(yylval.du - fvalue);
		if (loopNumDown >= epsilon) {
			ud = false;
			break;
		}
	}

	if (ud)
		return fabs(ub-c);
	else
		return fabs(lb-c);
}

int main() 
{
	char function[88];
	double epsilon;
	double c;
	printf("Please enter a single-variable function (will treat all letters as same variable): ");
	scanf("%[^\n]", function);
	printf("Function entered: %s\n", function);
	printf("Please enter a positive value for epsilon (larger epsilons take more time to compute): ");
	scanf("%lf", &epsilon);
	printf("Epsilon entered: %.7lf\n", epsilon);
	printf("Please enter a value for a point in the domain where you are trying to evaluate a delta: ");
	scanf("%lf", &c);
	printf("Value entered: %.7lf\n", c);
	printf("Please wait while we compute. Thank you!\n");
	yylval.fun = init_function(c);
	YY_BUFFER_STATE my_string_buffer = yy_scan_string(function); 
	yy_switch_to_buffer( my_string_buffer ); 
	yyparse(); 
	yy_delete_buffer(my_string_buffer );
	double copy;
	memcpy(&copy, &yylval.du, sizeof(double));
	if (contains_x(function))
		printf("The delta that satisfies this system is less than %.7lf.\n", solve_delta(epsilon, copy, c, function));
	else
		printf("There is no such delta that satisfies this epsilon.\n");
}