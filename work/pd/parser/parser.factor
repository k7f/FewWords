! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: addenda.eval kernel sequences ;
IN: pd.parser

: parse-command ( command objects actions -- )
    [
        { "pd.parser.dotpd" } ( -- obj act ) eval-using
    ] 2dip swapd [ push ] 2bi@ ;
