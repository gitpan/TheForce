package TheForce::Object;

=head1 NAME

TheForce::Object - The "mother" class for all classes in L<TheForce>

=head1 DESCRIPTION

It's in the NAME

=cut

$TheForce::Object::VERSION = '0.007';

sub new {
    my ($class, %args) = @_;
    # welcome to the world, my pretties
    my $self = {};
    bless $self, $class;
    $self->_build_arguments( %args );
    return $self;
}

sub _build_arguments {
    my ($self, %args) = @_;

    my $pkg = ref($self);
    for my $key (keys %args) {
        if ($pkg->can($key)) {
            $pkg->$key( $args{$key} );
        }
        else {
            $pkg->has( $key => ( default => $args{$key} ) );
        }
    }
}

=head1 AUTHOR

Brad Haywood <brad@geeksware.net>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
