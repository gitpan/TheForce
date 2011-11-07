package TheForce::Jedi;

$TheForce::Jedi::VERSION = '0.002';
=head1 NAME

TheForce::Jedi - The "Meta" Class for L<TheForce>

=head1 DESCRIPTION

This class holds all the information about the other classes and accessors for L<TheForce>. 

=cut

$TheForce::Jedi::Classes = {};

sub create_accessor {
    my ($self, $class, $attr, $val) = @_;

    $TheForce::Jedi::Classes->{$class}->{accessors}->{$attr} = $val;
}

sub class {
    my ($self, $class) = @_;
    
    $TheForce::Jedi::Classes->{$class} = {};
    $TheForce::Jedi::Classes->{$class}->{accessors} = {};
}

sub exists {
    my ($self, $class) = @_;

    if (exists $TheForce::Jedi::Classes->{$class}) { return 1; }
    
    return 0;
}

sub extends {
    # TODO
}

=head1 AUTHOR

Brad Haywood <brad@geeksware.net>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
