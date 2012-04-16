! Copyright (C) 2012 krzYszcz.
! See http://factorcode.org/license.txt for BSD license.

USING: accessors addenda.vocabs.files io.pathnames kernel pd.io.dotpd
       pd.parser.dotpd prettyprint sequences tools.test ;
IN: pd.io.dotpd.tests

: all-files? ( quot: ( path -- ? ) -- ? )
    [ "pd.io.dotpd" ".pd" vocab-tests-dir* ] dip
    [ dup . ] prepose all? ; inline

[ t ] [
    [ eval-dotpd dotpd-root? ] all-files?
] unit-test

[ t ] [
    [ eval-dotpd file-dir>> file-stem "tests" = ] all-files?
] unit-test
