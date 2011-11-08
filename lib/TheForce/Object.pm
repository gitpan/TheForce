package TheForce::Object;

=head1 NAME

TheForce::Object - The "mother" class for all classes in L<TheForce>

=head1 DESCRIPTION

It's in the NAME

=cut

$TheForce::Object::VERSION = '0.003';

sub new {
    my ($class, %args) = @_;

    # welcome to the world, my pretties
    my $self = {};
    return bless $self, $class;
}

=head1 AUTHOR

Brad Haywood <brad@geeksware.net>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
