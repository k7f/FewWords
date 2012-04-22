! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors addenda.classes.tuple arrays classes.tuple combinators
       kernel lexer math math.parser pd.types sequences vectors words ;
IN: pd.parser.dotpd

TUPLE: dotpd-root < pd-root
    { commands sequence }
    { stack vector } ;

: <dotpd-root> ( commands -- root )
    dotpd-root new 16 <vector> >>stack [ commands<< ] keep ;

: push-patch ( patch root -- ) stack>> push ;
: pop-patch  ( root -- patch ) stack>> pop ;

TUPLE: unknown-pd-command target name selector ;
: unknown-pd-command ( name selector target -- * )
    -rot \ unknown-pd-command boa throw ;

SYMBOLS:
    +pd-canvas+ +pd-pd+
    +pd-obj+ +pd-msg+ +pd-text+ +pd-floatatom+ +pd-symbolatom+
    +pd-connect+ +pd-array+ +pd-graph+
    +pd-coords+ +pd-restore+ +pd-pop+ ;

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
    drop 0 scan-token ";" [ drop ] each-token f pd-array boa ;

: parse-pd-graph ( selector -- header )
    drop scan-token ";" [ string>number >float ] map-tokens
    4 cut [ pd-graph-coords slots>tuple ] bi@
    pd-graph-header boa ;

: parse-pd-pop ( selector -- subpatch )
    drop ";" parse-tokens
    ?first [ string>number 0 = not ] [ f ] if*
    0 +pd-graph+ 0 0 f pd-box boa
    f 1array pd-subpatch clone-as*
    nip ;  ! FIXME swap >>vis

: parse-pd-coords ( selector -- props )
    drop ";" [ string>number ] map-tokens
    4 cut [
        [ >float ] map! pd-graph-coords slots>tuple
    ] dip
    5 0 pad-tail 3 cut
    [ first3 0 = not ] [ first2 ] bi* rot
    pd-canvas-props boa ;

: parse-pd-subpatch ( selector -- subpatch )
    drop +pd-pd+ parse-pd-box f 1array pd-subpatch clone-as* ;

<PRIVATE
: (canvas-rect) ( patch tokens -- patch )
    0 4 rot <slice> [ string>number >integer ] map!
    pd-rect slots>tuple >>rect ; inline

: (subcanvas-props) ( patch tokens name -- patch )
    swap [ >>name ] dip
    5 swap nth string>number 0 = not >>vis ;

: (canvas-props) ( patch tokens -- patch ? )
    4 over nth dup string>number [
        2nip >integer >>fontsize t
    ] [ (subcanvas-props) f ] if* ; inline
PRIVATE>

: parse-pd-patch ( selector -- patch )
    drop <pd-patch> ";" parse-tokens
    [ (canvas-rect) ] [ (canvas-props) ] bi
    [ pd-root new clone-as ] when ;

: parse-#X ( -- obj )
    parse-selector dup {
        { +pd-obj+        [ parse-pd-box ] }
        { +pd-msg+        [ parse-pd-box ] }
        { +pd-text+       [ parse-pd-box ] }
        { +pd-floatatom+  [ parse-pd-box ] }
        { +pd-symbolatom+ [ parse-pd-box ] }
        { +pd-connect+    [ parse-pd-line ] }
        { +pd-array+      [ parse-pd-array ] }
        { +pd-graph+      [ parse-pd-graph ] }
        { +pd-coords+     [ parse-pd-coords ] }
        { +pd-restore+    [ parse-pd-subpatch ] }
        { +pd-pop+        [ parse-pd-pop ] }
        [ drop "#X" unknown-pd-command ]
    } case nip ;

: parse-#A ( -- obj )
    scan-token string>number
    ";" [ string>number >float ] map-tokens
    pd-array-chunk boa ;

: parse-#N ( -- obj )
    parse-selector dup {
        { +pd-canvas+ [ parse-pd-patch ] }
        [ drop "#N" unknown-pd-command ]
    } case nip ;

<PRIVATE
: (box-post-process) ( root parent obj -- root parent' )
    [ suffix! ] curry change-boxes ;

GENERIC: (post-process) ( root parent obj -- root parent' )

M: pd-box (post-process) ( root parent box -- root parent' )
    (box-post-process) ;

M: pd-line (post-process) ( root parent line -- root parent' )
    [ suffix! ] curry change-lines ;

M: pd-array (post-process) ( root parent array -- root parent' )
    (box-post-process) ;

<PRIVATE
: (fill-pd-array) ( chunk array -- )
    [
        [ chunk>> ] [ start>> ] bi
    ] [
        dup data>> [ nip ] [
            V{ } clone [ swap data<< ] keep
        ] if*
    ] bi* copy ; inline

ERROR: (empty-boxes) chunk ;
ERROR: (not-an-array) chunk box ;
PRIVATE>

M: pd-array-chunk (post-process) ( root parent chunk -- root parent' )
    over boxes>> ?last [
        dup pd-array? [ (fill-pd-array) ] [ (not-an-array) ] if
    ] [ (empty-boxes) ] if* ;

M: pd-graph-header (post-process) ( root parent header -- root parent' )
    [ name>> <pd-patch> swap >>name ]
    [ coords>> ] [ pix-coords>> ] tri
    drop 0 0 0 0  ! FIXME
    t pd-canvas-props boa >>props
    [ over push-patch ] dip ;

M: pd-canvas-props (post-process) ( root parent coords -- root parent' )
    >>props ;

M: pd-subpatch (post-process) ( root parent subpatch -- root parent' )
    [ dup pop-patch ] [ ] [ swap >>patch ] tri*
    (box-post-process) ;

M: pd-patch (post-process) ( root parent patch -- root parent' )
    [ over push-patch ] dip ;
PRIVATE>

SYNTAX: #X parse-#X suffix! [ (post-process) ] suffix! ;
SYNTAX: #A parse-#A suffix! [ (post-process) ] suffix! ;
SYNTAX: #N parse-#N suffix! [ (post-process) ] suffix! ;
