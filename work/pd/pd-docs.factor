! Copyright (C) 2011 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: help.markup help.syntax layouts unicode.data kernel math pd.private
       sequences strings words words.symbol ;
IN: pd

HELP: string-or-number
{ $values
  { "str" string }
  { "str/real" { $link string } " or " { $link real } }
}
{ $description "A no-op, unless a string is a valid representation of a number, in which case it is converted to that number." }
{ $errors "Any non-string input throws an error." }
{ $notes "Result is guaranteed not to be a complex number, because complex numbers have no string representation in Factor." } ;

HELP: no-property
{ $values
  { "word" word }
  { "name" "a property name" }
}
{ $description "Throws a " { $link no-property } " error." } 
{ $error-description "Thrown if an undefined property of a word is requested." } ;

HELP: no-method
{ $values
  { "pd" "Pd object" }
  { "selector" "Pd selector" }
}
{ $description "Throws a " { $link no-method } " error." } 
{ $error-description "Thrown if a message is sent to a Pd object of a class which does not define a method for the message's selector." } ;

HELP: bad-atom
{ $values
  { "obj" object }
}
{ $description "Throws a " { $link bad-atom } " error." } 
{ $error-description "Thrown if an " { $link object } " is being used as a Pd atom, but it is neither a " { $link real } ", nor a Pd symbol, nor it can be converted to one." } ;

HELP: bad-selector
{ $values
  { "obj" object }
}
{ $description "Throws a " { $link bad-selector } " error." } 
{ $error-description "Thrown if an " { $link object } " is being used as a Pd selector, but it is neither a Pd symbol, nor it can be converted to one." } ;

! _______________________
! implementation articles

ARTICLE: "pd-float" "pd-float"
{ $see-also real } ;

ARTICLE: "pd-symbol" "pd-symbol"
{ $see-also symbol } ;

ARTICLE: "message-selector" "selector"
"A " { $link "pd-symbol" } " used." ;

ARTICLE: "message-arguments" "arguments"
"A flat sequence of " { $link "pd-float" } "s and " { $link "pd-symbol" } "s used." ;

ARTICLE: "message-target" "target"
"A " { $link "pd-symbol" } " used." ;

ARTICLE: "messages-underparsed" "Underparsed Pd messages"
{ $emphasis "Underparsed message representation" } " is a flat " { $link sequence } " of " { $link string } "s and " { $link real } "s, as stored in the " { $slot "underparsed" } " slot of " { $link (pd|patchable) } " objects."
$nl
"Requires " { $emphasis "parsing" } " with " { $link message-parse } " before use." ;

ARTICLE: "messages-parsed" "Parsed Pd messages"
{ $emphasis "Parsed message representation" } ", as stored in the " { $slot "parsed" } " slot of " { $link (pd|message) } ", is a sequence of tuples.  Each tuple consists of a " { $link "message-selector" } ", " { $link "message-arguments" } " and an optional " { $link "message-target" } "."
$nl
"Requires " { $emphasis "unparsing" } " with " { $link message-unparse } " in order to be transferred out of Factor, e.g. saved in a .pd file." ;

ARTICLE: "messages-overparsed" "Overparsed Pd messages"
{ $emphasis "Overparsed message representation" } " is any Factor " { $link object } " used as input to ->pd."
$nl
"internally, Pd objects defined in the " { $vocab-link "pd" } " vocabulary process Pd messages after " { $emphasis "downparsing" } " them with " { $link message-downparse } "." ;

ARTICLE: "messages" "Pd messages"
"There are three representations of a Pd message."
$nl
{ $subsections
  "messages-underparsed"
  "messages-parsed"
  "messages-overparsed"
}

"The three words performing conversion from one representation to another are"
{ $subsections
  message-parse
  message-unparse
  message-downparse
} ;

ARTICLE: "examples" "Examples"
"Create a literal message box"
{ $example "USING: pd prettyprint ; Pd{ bang } ."
  "T{ (pd|message)
    { underparsed { \"message\" \"bang\" } }
    { parsed { T{ pd-message { selector pd:bang } } } } }" }
"Declare a Pd class"
{ $example "USING: pd pd.private prettyprint ;"
  "TUPLE: pd|test < (pd|patchable) { rhs float } ;"
  "pd|test new ."
  "T{ pd|test }" }
"Define and call the constructor"
{ $example ": <pd|test> ( car cdr -- pd )"
  "[ pd|test (new-pd|patchable) ] keep"
  "0 swap ?nth [ 0.0 ] unless* >>rhs ;"
  "\"test\" { 7 } <pd|test> ."
  "T{ pd|test { underparsed { \"test\" 7 } } { rhs 7.0 } }" }
"Create a literal object box"
{ $example "Pd[ test 7 ] ."
  "T{ pd|test { underparsed { \"test\" 7 } } { rhs 7.0 } }" }
"Define and call a method for a bang in left inlet"
  { $example "INLET: 0 bang pd|test nip rhs>> . ;"
  "\"bang\" Pd[ test 7 ] ->pd"
  "7.0" }
"Define and call a method for a float in right inlet"
{ $example "INLET: 1 float pd|test rhs<< ;"
  "Pd[ test 7 ] 4 over 1 ->pd# ."
  "T{ pd|test { underparsed { \"test\" 7 } } { rhs 4.0 } }" }
"There are two other ways of interfacing with an object (in this case \u{em-dash} modifying its state, i.e. replacing 7 with 4, as above)."
{ $list
  { "The object is represented by its inlet:"
    { $example "Pd[ test 7 ] 1 inlet 4 over ->pd ."
      "" } }
  { "The object is bound to a symbol:"
    { $example "Pd[ test 7 ] 1 \"target\" pd-bind 4 \"target\" ->pd ."
      "" } }
} ;

! ___________________
! background articles

ARTICLE: "PureData" "PureData"
{ $see-also "FewWords" }
$nl
{ $emphasis "PureData" } ", canonically abbreviated as " { $emphasis "Pd" } ", is a language, an engine, and a graphical environment used for building and executing programming constructs called " { $emphasis "patches" } ".  Pd combines two models of computation: unbuffered, push-style message passing, and isochronous dataflow."
$nl
"Pd is a DSL in the sense that the application area it was originally designed for, and which still attracts most users, is computer music and, to some extent, interactive visuals.  The name, however, " { $emphasis "PureData" } ", enshrines the idea that the core language is agnostic as to what is music: it deals with abstract data, not with notes and sounds.  The name also alludes to the public domain license of Pd."
$nl
"The canonical representation of Pd patches is a set of " { $emphasis "objects" } ", arbitrarily placed in a two-dimensional space, and connected with lines.  Object definitions come in several flavors.  Apart from one-off " { $emphasis "subpatches" } " and reusable, parametrized " { $emphasis "abstractions" } ", both of which are coded in Pd itself, there are built-in or dynamically loaded primitives coded by utilizing an API for the language C."
$nl
"Some objects are widgets, and a user may interact with GUI elements of a patch directly in the Pd editor (after entering the \"run\" mode).  Most objects, however, are plain boxes filled with text: a constructor name followed by arguments.  Input ports are depicted on the top border, and output ports \u{em-dash} on the bottom border of an object.  Therefore, dataflow of messages through a network of Pd objects is graphically top-to-bottom, which corresponds to the textual postfix notation and left-to-right concatenation of words in stack languages." ;

ARTICLE: "Pd" "Pd"
{ $see-also "PureData" "FewWords" } ;

ARTICLE: "FewWords" "Pd in a few words"
"The " { $vocab-link "pd" } " vocabulary assists in building and running simple Pd patches in Factor."
$nl
{ $subsections
  "messages"
  "examples"
} ;

ABOUT: "FewWords"
