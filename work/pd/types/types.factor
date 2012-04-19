! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors kernel math sequences strings words.symbol ;
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

TUPLE: pd-array < pd-object
    { name string } ;

INSTANCE: pd-array pd-gobject

TUPLE: pd-graph-coords
    { x0 float } { y0 float }
    { x1 float } { y1 float } ;

TUPLE: pd-graph-header
    { name string }
    { coords pd-graph-coords }
    { pix-coords pd-graph-coords } ;

TUPLE: pd-canvas-props
    { coords pd-graph-coords }
    { w integer } { h integer }
    { xmargin integer } { ymargin integer }
    { gop boolean } ;

TUPLE: pd-rect
    { x integer } { y integer }
    { w integer } { h integer } ;

TUPLE: pd-patch < pd-object
    { name string }
    { rect pd-rect }
    { fontsize integer }
    { vis boolean }
    { props pd-canvas-props }
    { boxes pd-glist }
    { lines pd-linkage } ;

TUPLE: pd-subpatch < pd-box
    { patch maybe: pd-patch } ;

: <pd-patch> ( -- patch )
    pd-patch new V{ } [ clone >>boxes ] [ clone >>lines ] bi ;

TUPLE: pd-root < pd-patch
    { file-name string }
    { file-dir string } ;
