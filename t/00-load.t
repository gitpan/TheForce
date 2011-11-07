#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'TheForce' ) || print "Bail out!\n";
}

diag( "Testing TheForce $TheForce::VERSION, Perl $], $^X" );
