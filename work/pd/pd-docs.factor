USING: help.markup help.syntax kernel math strings unicode.data ;
IN: pd

ABOUT: "PureData"

ARTICLE: "PureData" "PureData"
{ $emphasis "PureData" } ", canonically abbreviated as " { $emphasis "Pd" } ", is a language, an engine, and a graphical environment used for building and executing programming constructs called " { $emphasis "patches" } ".  Pd combines two models of computation: unbuffered, push-style message passing, and isochronous dataflow."
$nl
"Pd is a DSL in the sense that application area it was originally designed for is computer music and, to some extent, interactive visuals.  The name, however, " { $emphasis "PureData" } ", enshrines the idea that the core language is agnostic as to what is music: it deals with abstract data, not with notes and sounds.  The name also alludes to the public domain license of Pd."
$nl
"The canonical representation of Pd patches is a set of " { $emphasis "objects" } ", arbitrarily placed in a two-dimensional space, and connected with lines.  Object definitions come in several flavors.  Apart from one-off " { $emphasis "subpatches" } " and reusable, parametrized " { $emphasis "abstractions" } ", both of which are coded in Pd itself, there are built-in or dynamically loaded primitives coded by utilizing an API for the language C."
$nl
"Some objects are widgets, and a user may interact with GUI elements of a patch directly in the Pd editor (after entering the \"run\" mode).  Most objects, however, are plain boxes filled with text: a constructor name followed by arguments.  Input ports are depicted on the top border, and output ports \u{em-dash} on the bottom border of an object.  Therefore, dataflow of messages through a network of Pd objects is graphically top-to-bottom, which corresponds to the textual postfix notation and left-to-right concatenation of words in stack languages." ;

ARTICLE: "Pd" "Pd"
{ $see-also "PureData" } ;
