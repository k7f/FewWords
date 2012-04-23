! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors arrays assocs classes classes.tuple hashtables kernel locals
       make math sequences strings words.symbol ;
IN: pd.types

TUPLE: pd-object { id integer } ;

MIXIN: pd-gobject

UNION: pd-atom
    float string ;  ! FIXME

PREDICATE: pd-binbuf < sequence
    ?first [ pd-atom? ] [ t ] if* ;

TUPLE: pd-box < pd-object
    { selector maybe: symbol }
    { x integer }
    { y integer }
    { args pd-binbuf } ;

INSTANCE: pd-box pd-gobject

PREDICATE: pd-glist < sequence
    ?first [ pd-gobject? ] [ t ] if* ;

TUPLE: pd-line < pd-object
    { from-id integer } { from-pin integer }
    { to-id integer } { to-pin integer } ;

PREDICATE: pd-linkage < sequence
    ?first [ pd-line? ] [ t ] if* ;

! FIXME
TUPLE: pd-scalar < pd-object
    { name string } ;

C: <pd-scalar> pd-scalar
    
TUPLE: pd-array < pd-object
    { name string }
    { data sequence } ;

INSTANCE: pd-array pd-gobject

TUPLE: pd-array-chunk
    { start integer }
    { chunk sequence } ;

! string is for arrays (element type definition may be deferred)
UNION: pd-slot-type class string ;

! FIXME specialize assoc's type as a mapping from strings to pd-slot-types
TUPLE: pd-struct
    { name string }
    { slots assoc } ;

<PRIVATE
: (parse-slot-type) ( typename -- type ) ; inline ! FIXME

: (next-array-slot) ( slots -- slot rest/f )
    3 cut-slice [
        [ second ] [ third (parse-slot-type) ] bi 2array
    ] dip ; inline

: (next-atomic-slot) ( slots typename -- slot rest/f )
    [ dup second ] [ (parse-slot-type) ] bi*
    2array swap 2 tail-slice ; inline

: (next-slot) ( slots -- slot rest/f )
    dup ?first [
        dup "array" =
        [ drop (next-array-slot) ]
        [ (next-atomic-slot) ] if
    ] [ drop f f ] if* ;
PRIVATE>

: <pd-struct> ( name slots -- struct )
    [
        [ (next-slot) dup ] [ [ , ] dip ] while 2drop
    ] { } make >hashtable pd-struct boa ;

TUPLE: pd-coords
    { x0 float } { y0 float }
    { x1 float } { y1 float } ;

C: <pd-coords> pd-coords
: make-pd-coords ( seq -- coords ) pd-coords slots>tuple ;
: >pd-coords< ( coords -- x0 y0 x1 y1 ) tuple-slots first4 ;

TUPLE: pd-rect
    { x integer } { y integer }
    { w integer } { h integer } ;

C: <pd-rect> pd-rect
: make-pd-rect ( seq -- rect ) pd-rect slots>tuple ;
: >pd-rect< ( coords -- x y w h ) tuple-slots first4 ;

<PRIVATE
CONSTANT: +DEF-GRAPH-WIDTH+  200
CONSTANT: +DEF-GRAPH-HEIGHT+ 140

! cf glist_addglist()
:: (normalize-pix-coords) ( px0 py0 px1 py1 -- px py pw ph )
    px0 px1 >= [ py0 py1 = ] unless* [
        100 20 +DEF-GRAPH-WIDTH+ +DEF-GRAPH-HEIGHT+
    ] [
        px0 px1 over -
        py0 py1 2dup > [ swap ] when over - swapd
    ] if ;
PRIVATE>

: pd-coords>pd-rect ( coords -- rect )
    >pd-coords< (normalize-pix-coords) <pd-rect> ;

TUPLE: pd-graph-header
    { name string }
    { coords pd-coords }
    { pix-coords pd-coords } ;

! pix-rect: on-parent
TUPLE: pd-canvas-props
    { coords pd-coords }
    { pix-rect pd-rect }
    { xmargin integer }
    { ymargin integer }
    { vis boolean }
    { gop boolean } ;

: <pd-canvas-props> ( -- props )
    pd-canvas-props new ;

! rect: on-screen
TUPLE: pd-patch < pd-object
    { name string }
    { rect pd-rect }
    { fontsize integer }
    { props pd-canvas-props }
    { boxes pd-glist }
    { lines pd-linkage } ;

: <pd-patch> ( -- patch )
    pd-patch new V{ } [ clone >>boxes ] [ clone >>lines ] bi ;

! props: temporary storage of graph props transferred to patch props during post-processing
TUPLE: pd-subpatch < pd-box
    { props maybe: pd-canvas-props }
    { patch maybe: pd-patch } ;

TUPLE: pd-root < pd-patch
    { file-name string }
    { file-dir string }
    { struct-defs assoc } ;

: new-pd-root ( class -- root )
    new 32 <hashtable> >>struct-defs ;
