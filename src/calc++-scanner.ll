%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "calc++-driver.h"
# include "calc++-parser.hpp"

#define YYSTYPE yy::calcxx_parser::semantic_type
#define YYLTYPE yy::calcxx_parser::location_type

// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
# undef yywrap
# define yywrap() 1

%}
%option bison-bridge bison-locations
%option noyywrap nounput batch debug noinput
id    [a-zA-Z][a-zA-Z_0-9]*
int   [0-9]+
blank [ \t]

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  yylloc->columns (yyleng);
%}

%%

%{
  // Code run each time yylex is called.
  yylloc->step ();
%}

{blank}+   yylloc->step ();
[\n]+      yylloc->lines (yyleng); yylloc->step ();
"-"      return yy::calcxx_parser::make_MINUS(*yylloc);
"+"      return yy::calcxx_parser::make_PLUS(*yylloc);
"*"      return yy::calcxx_parser::make_STAR(*yylloc);
"/"      return yy::calcxx_parser::make_SLASH(*yylloc);
"("      return yy::calcxx_parser::make_LPAREN(*yylloc);
")"      return yy::calcxx_parser::make_RPAREN(*yylloc);
":="     return yy::calcxx_parser::make_ASSIGN(*yylloc);


{int}      {
  errno = 0;
  long n = strtol (yytext, NULL, 10);
  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
    driver.error (*yylloc, "integer is out of range");
  return yy::calcxx_parser::make_NUMBER(n, *yylloc);
}

{id}       return yy::calcxx_parser::make_IDENTIFIER(yytext, *yylloc);
.          driver.error (*yylloc, "invalid character");
<<EOF>>    return yy::calcxx_parser::make_END(*yylloc);
%%

void
calcxx_driver::scan_begin ()
{
  yy_flex_debug = trace_scanning;
  if (file.empty () || file == "-")
    yyin = stdin;
  else if (!(yyin = fopen (file.c_str (), "r")))
    {
      error ("cannot open " + file + ": " + strerror(errno));
      exit (EXIT_FAILURE);
    }
}



void
calcxx_driver::scan_end ()
{
  fclose (yyin);
}

