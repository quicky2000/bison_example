#include "calc++-driver.h"
#include "calc++-parser.hpp"
#include "calc++-scanner.h"


calcxx_driver::calcxx_driver ()
  : trace_scanning (false), trace_parsing (false)
{
  variables["one"] = 1;
  variables["two"] = 2;
}

calcxx_driver::~calcxx_driver ()
{
}

int
calcxx_driver::parse (const std::string &f)
{
  flex_prefixlex_init(&m_scanner);
  file = f;
  FILE * in = fopen(f.c_str(),"r");
  if (!in)
    {
      error ("cannot open " + f + ": " + strerror(errno));
      exit (EXIT_FAILURE);
    }
  flex_prefixset_in(in,m_scanner);
  flex_prefixset_debug(trace_scanning,m_scanner);
  my_parser::calcxx_parser parser (m_scanner,*this,&m_loc,NULL);
  parser.set_debug_level (trace_parsing);
  int res = parser.parse ();
  flex_prefixlex_destroy(m_scanner);
  fclose(in);
  return res;
}

void
calcxx_driver::error (const my_parser::location& l, const std::string& m)
{
  std::cerr << l << ": " << m << std::endl;
}

void
calcxx_driver::error (const std::string& m)
{
  std::cerr << m << std::endl;
}
