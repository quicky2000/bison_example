%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "calc++-driver.h"
# include "calc++-parser.hpp"
%}
%option bison-bridge bison-locations reentrant
%option noyywrap nounput batch debug noinput
%option prefix="flex_prefix"
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
[\n]+      yylloc->lines (yyget_leng(yyscanner)); yylloc->step ();
"-"      return my_parser::calcxx_parser::make_MINUS(*yylloc);
"+"      return my_parser::calcxx_parser::make_PLUS(*yylloc);
"*"      return my_parser::calcxx_parser::make_STAR(*yylloc);
"/"      return my_parser::calcxx_parser::make_SLASH(*yylloc);
"("      return my_parser::calcxx_parser::make_LPAREN(*yylloc);
")"      return my_parser::calcxx_parser::make_RPAREN(*yylloc);
":="     return my_parser::calcxx_parser::make_ASSIGN(*yylloc);


{int}      {
  errno = 0;
  long n = strtol (yyget_text(yyscanner), NULL, 10);
  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
    driver.error (*yylloc, "integer is out of range");
  return my_parser::calcxx_parser::make_NUMBER(n, *yylloc);
}

{id}       return my_parser::calcxx_parser::make_IDENTIFIER(yyget_text(yyscanner), *yylloc);
.          driver.error (*yylloc, "invalid character");
<<EOF>>    return my_parser::calcxx_parser::make_END(*yylloc);
%%
//EOF
