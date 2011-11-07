package TheForce;

=head1 NAME

TheForce - Midichlorian-free Perl5 OOP

=head1 DESCRIPTION

L<Moose> and L<Mouse> are great. But how do they work? Normally people don't really care - they just work. 
TheForce is an extremely limited version which only supports C<has> and C<extends> at the moment, but still 
makes OOP in Perl5 extremely easy. What's best is everything is containing in just 3 small modules so you can 
see what is happening in the background, if you're interested. What's best is you get to B<use TheForce> in every 
package ;-)

=head1 SYNOPSIS

    # Foo.pm
    package Foo;

    use TheForce;

    has ( x => { is => 'rw', isa => 'Int', default => 5 } );
    has ( greet => { is => 'ro', isa => 'Str', default => 'Hello, World!' } );    

    sub sayHello {
        my $self = shift;
        say $self->greet;
    }
    
    1;

    # Fooness.pm
    package Fooness;
    
    use TheForce;
    
    extends 'Foo';

    say Foo->x; # prints 5
    Foo->x(7);
    say Foo->x; # prints 7

    my $foo = Foo->new;
    $foo->sayHello(); # prints Hello, World!

=cut

$TheForce::VERSION = '0.002';

use strict;
use warnings;

use TheForce::Jedi;

use mro ();
use feature ();
sub import {
    my $class_name = caller;
    warnings->import();
    strict->import();
    TheForce::Jedi->class( $class_name );
    feature->import( ':5.10' );
    mro::set_mro( scalar caller(), 'c3' );
    _extends_class( ['TheForce::Object'], $class_name );
    no strict 'refs';
    no warnings 'once', 'redefine';
    use warnings FATAL => 'uninitialized';
    *{$class_name . '::has'} = \&has;
    *{$class_name . '::extends'} = \&extends;
}


sub _extends_class {
    my ($mothers, $class) = @_;

    foreach my $mother (@$mothers) {
        # if class is unknown to us, import it (FIXME)
        unless (TheForce::Jedi->exists($mother)) {
            eval "use $mother";
            warn "Could not load $mother: $@"
                if $@;
        
            $mother->import;
        }
        TheForce::Jedi->extends($class, $mother);
    }

    {
        no strict 'refs';
        @{"${class}::ISA"} = @$mothers;
    }
}

sub has {
    my %args = @_;
    my $pkg = caller();
    my @types = qw/Str Int Def/;
    no strict 'refs';
    no warnings 'redefine', 'prototype';
    my $key;
    my $accessor;
    for (keys %args) {
        $key = $_;
        for my $opt (keys %{$args{$key}}) {
            if ($opt eq 'isa') {
                if (! grep { $_ eq $args{$key}->{isa} } @types) {
                  die "$args{$key}->{isa} is not a valid attribute type\n";
                }
            }
            $TheForce::Jedi::Classes->{$pkg}->{accessors}->{$key} = $args{$key};
            if ($opt eq 'default') {
                $TheForce::Jedi::Classes->{$pkg}->{accessors}->{$key}->{value} = $args{$key}->{default};
            }
        }
        *$key = sub {
            my ($self, $val) = @_;
            
            $accessor = $TheForce::Jedi::Classes->{$pkg}->{accessors}->{$key};
            return $TheForce::Jedi::Classes->{$pkg}->{accessors}->{$key}->{value}
                if ! $val;

            my $warn = 0;
            if (exists $accessor->{is}) {
                if ($accessor->{is} eq 'ro') {
                    $warn = 1;
                    warn "Cannot alter a Read-Only attribute";
                }
            }
            if (exists $accessor->{isa}) {
                if ($accessor->{isa} eq 'Int') {
                    if ($val !~ /^\d+$/) {
                        $warn = 1;
                        warn "$key(): Attribute type is 'Int', but value is not an integer";
                    }
                }
                # FIXME
                elsif ($accessor->{isa} eq 'Str') {
                    if ($val =~ /^\d+$/) {
                        $warn = 1;
                        warn "$key(): Attribute type is 'Str', but value is not a string";
                    }
                }
            }
            $TheForce::Jedi::Classes->{$pkg}->{accessors}->{$key}->{value} = $val
                unless $warn > 0;
        };
        #bless \*$key, "$pkg";
        *{$pkg . "::$key"} = \*$key;
    }
}

sub extends {
    my (@classes) = @_;;
    my $pkg = caller();

    die "Cannot extend main!\n"
        if $pkg eq 'main';

    _extends_class( \@classes, $pkg);
}

=head1 METHODS

=head2 has

Creates an accessor for the particular package. Without arguments will return its value, 
or with arguments will set a new value. You can make the accessor read-only and set a specific type.

    has (x => {
        is      => 'ro',   # read only
        isa     => 'Int',  # Integer only
        default => 7,      # default value
    });

=head2 extends

Inherits the specified class.

    package Foo;
    
    extends 'MyPackage';

    1;

=head1 AUTHOR

Brad Haywood <brad@geeksware.net>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

=cut

1;
