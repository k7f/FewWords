! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: addenda.help.markup help.markup help.syntax pd.types quotations strings ;
IN: pd.parser

HELP: parse-command
{ $values
  { "command" string }
  { "objects" { $sequence-of pd-object } }
  { "actions" { $sequence-of quotation } }
}
{ $description "" } ;

ARTICLE: "pd.parser" "pd.parser"
{ "The " { $vocab-link "pd.parser" } " vocabulary contains the frontend API for parsing and unparsing between Pd patches and text.  Command list (aka \"dotpd\") format is supported, json is a TODO." } ;

ABOUT: "pd.parser"
