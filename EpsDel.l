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

\( 		{ return LPARENTHESIS; }
\)		{ return RPARENTHESIS; }
\^		{ return EXPONENT; }
\*		{ return MULTIPLY; }
\/		{ return DIVIDE; }
\+		{ return ADD; }
\-		{ return SUBTRACT; }
[xX]		{ return VARIABLE; }
[0-9\.]* { sscanf(yytext, "%lf", &yylval.fun->dub); return NUMBER; }
[ \t\n]	;

%%

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
		yylval.fun = init_function((ub += 0.000001));
		YY_BUFFER_STATE my_string_buffer = yy_scan_string(function); 
		yy_switch_to_buffer( my_string_buffer ); 
		yyparse(); 
		yy_delete_buffer(my_string_buffer );
		loopNumUp = fabs(yylval.du - fvalue);
		if (loopNumUp >= epsilon) {
			ud = true;
			break;
		}

		yylval.fun = init_function((lb -= 0.000001));
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
		return ub-c;
	else
		return lb-c;
}

int main() 
{
	char function[88];
	double epsilon;
	double c;
	printf("Please enter a value for epsilon:\n");
	scanf("%lf", &epsilon);
	printf("Epsilon entered: %lf\n", epsilon);
	printf("Please enter a value for a point in the domain where you are trying to evaluate a delta:\n");
	scanf("%lf", &c);
	printf("Value entered: %lf\n", c);
	yylval.fun = init_function(c);
	printf("Please enter a single-variable function (will treat all letters as same variable): ");
	scanf("%s", function);
	YY_BUFFER_STATE my_string_buffer = yy_scan_string(function); 
	yy_switch_to_buffer( my_string_buffer ); 
	yyparse(); 
	yy_delete_buffer(my_string_buffer );
	double copy;
	memcpy(&copy, &yylval.du, sizeof(double));
	printf("The delta that satisfies this system is less than %lf.\n", solve_delta(epsilon, copy, c, function));
}