! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors addenda.classes.tuple io io.encodings.ascii io.files kernel
       pd.parser pd.parser.dotpd pd.types sequences ;
IN: pd.io.dotpd

<PRIVATE
: (next-command) ( -- command ? )
    ";\n" read-until dup CHAR: \n = [
        drop (next-command) [
            over empty? [ nip ] [ " " glue ] if
        ] dip
    ] [
        over ?last [
            CHAR: \ = [
                drop (next-command) [ ";" glue ] dip
            ] when
        ] when*
    ] if ;

: (push-command) ( accum -- accum ? )
    (next-command) [
        [ " ;" append suffix! ] unless-empty
    ] dip ;
PRIVATE>

: load-commands ( name -- commands )
    ascii [
        V{ } clone [ (push-command) ] loop
    ] with-file-reader ;

: load-dotpd ( name -- commands objects actions )
    load-commands V{ } [ clone ] dup bi [
        [ parse-command ] 2curry each
    ] 3keep ;

: eval-dotpd ( name -- root )
    load-dotpd [
        [ <dotpd-root> f ] [ length iota ] bi
    ] 2dip [
        rot pick pd-object? [ pick id<< ] [ drop ] if
        call( root parent obj -- root parent' )
    ] 3each swap [ dup delete-all ] change-stack clone-as ;
