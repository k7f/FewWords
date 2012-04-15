! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors addenda.classes.tuple arrays classes.tuple combinators
       kernel lexer math math.parser pd.types sequences vectors words ;
IN: pd.parser.dotpd

TUPLE: dotpd-root
    { commands sequence }
    { stack vector }
    { patch maybe: pd-patch } ;

: <dotpd-root> ( commands -- root )
    16 <vector> f dotpd-root boa ;

: push-patch ( patch root -- ) stack>> push ;
: pop-patch  ( root -- patch ) stack>> pop ;

TUPLE: unknown-command target name selector ;
: unknown-command ( name selector target -- * )
    -rot \ unknown-command boa throw ;

SYMBOLS:
    +pd-canvas+ +pd-pd+
    +pd-obj+ +pd-msg+ +pd-text+ +pd-floatatom+ +pd-symbolatom+
    +pd-connect+ +pd-array+ +pd-coords+ +pd-restore+ ;

: parse-selector ( -- name selector/f )
    scan-token dup "+pd-" "+" surround
    "pd.parser.dotpd" lookup-word ;

: parse-pd-box ( selector -- box )
    0 swap scan-token string>number scan-token string>number
    V{ } clone ";" [ suffix! ] each-token pd-box boa ;

: parse-pd-line ( selector -- line )
    drop 0 scan-token string>number scan-token string>number
    scan-token string>number scan-token string>number
    ";" [ drop ] each-token pd-line boa ;

: parse-pd-array ( selector -- array )
    drop 0 scan-token ";" [ drop ] each-token pd-array boa ;

: parse-pd-coords ( selector -- coords )
    drop ";" [ string>number ] map-tokens
    0 4 pick <slice> [ >float ] map! drop
    6 over nth 0 = not 6 pick set-nth
    8 0 pad-tail pd-canvas-coords slots>tuple ;

: parse-pd-subpatch ( selector -- subpatch )
    drop +pd-pd+ parse-pd-box f 1array pd-subpatch new-derived ;

<PRIVATE
: (canvas-rect) ( patch tokens -- patch )
    0 4 rot <slice> [ string>number >integer ] map!
    pd-rect slots>tuple >>rect ; inline

: (subcanvas-props) ( patch tokens name -- patch )
    swap [ >>name ] dip
    5 swap nth string>number 0 = not >>vis ;

: (canvas-props) ( patch tokens -- patch )
    4 over nth dup string>number [
        2nip >integer >>fontsize
    ] [ (subcanvas-props) ] if* ; inline
PRIVATE>

: parse-pd-patch ( selector -- patch )
    drop <pd-patch> ";" parse-tokens
    [ (canvas-rect) ] [ (canvas-props) ] bi ;

: parse-#X ( -- obj )
    parse-selector dup {
        { +pd-obj+        [ parse-pd-box ] }
        { +pd-msg+        [ parse-pd-box ] }
        { +pd-text+       [ parse-pd-box ] }
        { +pd-floatatom+  [ parse-pd-box ] }
        { +pd-symbolatom+ [ parse-pd-box ] }
        { +pd-connect+    [ parse-pd-line ] }
        { +pd-array+      [ parse-pd-array ] }
        { +pd-coords+     [ parse-pd-coords ] }
        { +pd-restore+    [ parse-pd-subpatch ] }
        [ drop "#X" unknown-command ]
    } case nip ;

: parse-#N ( -- obj )
    parse-selector dup {
        { +pd-canvas+ [ parse-pd-patch ] }
        [ drop "#N" unknown-command ]
    } case nip ;

<PRIVATE
: (box-suffix!) ( root parent obj -- root parent' )
    [ suffix! ] curry change-boxes ;

GENERIC: (suffix!) ( root parent obj -- root parent' )

M: pd-box (suffix!) ( root parent box -- root parent' )
    (box-suffix!) ;

M: pd-line (suffix!) ( root parent line -- root parent' )
    [ suffix! ] curry change-lines ;

M: pd-array (suffix!) ( root parent array -- root parent' )
    (box-suffix!) ;

M: pd-canvas-coords (suffix!) ( root parent coords -- root parent' )
    >>props ;

M: pd-subpatch (suffix!) ( root parent subpatch -- root parent' )
    [ dup pop-patch ] [ ] [ swap >>patch ] tri* (box-suffix!) ;

: (new-parent) ( root old new -- root parent )
    [ over push-patch ] dip ;
PRIVATE>

SYNTAX: #X parse-#X suffix! [ (suffix!) ] suffix! ;
SYNTAX: #N parse-#N suffix! [ (new-parent) ] suffix! ;
