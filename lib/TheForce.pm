package TheForce;

$TheForce::VERSION = '0.001';

=head1 NAME

TheForce - Use the force!

=head1 DESCRIPTION

Have you ever wanted to be a Jedi and use the force? Now you can.
B<TODO>

  Add more characters and actually have some purpose to this useless module.

=head1 SYNOPSIS

    use TheForce 'Luke';

    use TheForce [qw/Luke R2D2 Vader/];

=cut

sub import {
    my ($class, $attr) = @_;

    my @jedi = qw/
        luke
        obi-one
        darth vader
        vader
        darth maul
        yoda
    /;
    my @droid = qw/
        c3po
        r2d2
    /;

    if (ref $attr eq 'ARRAY') {
        for my $char (@$attr) {
            $char = lc $char;
            if (grep { $_ eq $char } @droid) {
                print "A Droid can't use the Force!\n";
                next;
            }
            if (! grep { $_ eq $char } @jedi) {
                print "$char is not a known Jedi/Sith\n";
                next;
            }
            print "The force is with " . ucfirst($char) . "\n";
        }
    }
    else {
        $attr = lc $attr;
        if (grep { $_ eq $attr } @droid) {
            print "A Droid can't use the Force!\n";
            return ;
        }
        if (! grep { $_ eq $attr } @jedi) {
            print "$char is not a known Jedi/Sith\n";
            return ;
        }
        print "The force is strong with you, " . ucfirst($attr) . "\n";
   }
}

=head1 AUTHOR

Brad Haywood <brad@geeksware.net>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
        
1; # End of TheForce
