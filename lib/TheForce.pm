package TheForce;

=head1 NAME

TheForce - Midichlorian-free Perl5 OOP

=head1 DESCRIPTION

TheForce is an extremely limited YAOOPF (Yet Another OOP Framework) to make the code easy to understand without jumping through many different classes and subroutines, 
but still makes OOP in Perl5 extremely easy. Everything is contained in just 3 small modules and runs very fast. 
What's best is you get to B<use TheForce> in every package ;-)
TheForce was B<not> made to replace other OOP frameworks like Mo(o|u)se (or disappoint by being a YAOOPF), but as a learning exercise. And I like Star Wars.

=head1 SYNOPSIS

    # Foo.pm
    package Foo;

    use TheForce;

    has 'x' => ( is => 'rw', isa => 'Int', default => 5 );
    has 'greet' => ( is => 'ro', isa => 'Str', default => 'Hello, World!' );    

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

$TheForce::VERSION = '0.005';

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
    *{$class_name . '::after'} = \&after;
    *{$class_name . '::before'} = \&before;
    *{$class_name . '::force'} = \&force;
    *{$class_name . '::force_pull'} = \&force_pull;
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
    my ($name, %opts) = @_;
    my $pkg = caller();
    my @types = qw/Str Int Def/;
    no strict 'refs';
    no warnings 'redefine', 'prototype';
    my $key = $name;
    my $accessor;
    for my $opt (keys %opts) {
        if ($opt eq 'isa') {
            if (! grep { $_ eq $opts{isa} } @types) {
              die "$opts{isa} is not a valid attribute type\n";
            }
        }
        $TheForce::Jedi::Classes->{$pkg}->{accessors}->{$name}->{$opt} = $opts{$opt};
        if ($opt eq 'default') {
            $TheForce::Jedi::Classes->{$pkg}->{accessors}->{$name}->{value} = $opts{default};
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
    *{$pkg . "::$key"} = \*$key;
}

sub extends {
    my (@classes) = @_;;
    my $pkg = caller();

    die "Cannot extend main!\n"
        if $pkg eq 'main';

    _extends_class( \@classes, $pkg);
}

# FIXME - This is hellishly ugly and not the right way to do this!
sub after {
    my ($name, $code) = @_;
    my $pkg = caller;
   
    my $alter_sub;
    my $new_code;
    my $old_code; 
    die "Could not find $name in the Jedi hierarchy for $pkg\n"
        if ! $pkg->can($name);

    $old_code = \&{$pkg . "::$name"};
    *$name = sub {
        $old_code->(@_);
        $code->(@_);
    };
    *{$pkg . "::$name"} = \*$name;
}


# FIXME - Ditto
sub before {
    my ($name, $code) = @_;
    my $pkg = caller;

    my $alter_sub;
    my $new_code;
    my $old_code;
    die "Could not find $name in the Jedi hierarchy for $pkg\n"
        if ! $pkg->can($name);

    $old_code = \&{$pkg . "::$name"};
    *$name = sub {
        $code->(@_);
        $old_code->(@_);
    };
    *{$pkg . "::$name"} = \*$name;
}

sub force {
    my ($package, %args) = @_;
    my $pkg = scalar $package;
    die "Could not find '$pkg' in the Jedi Order (Did you use or extend this class?)\n" 
        if ! $package->can('force');
    my $key;
    for $key (keys %args) {
        *$key = sub {
            $args{$key}->(@_);
        };
        *{$package . "::$key"} = \*$key;
    }
}

sub force_pull {
    my $class = shift;

    use Module::Finder;
    my $mf = Module::Finder->new(
        dirs  => [@INC],
        paths => {
            $class => '/',
        }
    );
    my @modnames = $mf->modules;
    my $usem = "";
    for(@modnames) {
        $usem .= "use $_;\n";
    }
    eval $usem;
}

=head1 METHODS

=head2 has

Creates an accessor for the particular package. Without arguments will return its value, 
or with arguments will set a new value. You can make the accessor read-only and set a specific type.

    has 'x' => (
        is      => 'ro',   # read only
        isa     => 'Int',  # Integer only
        default => 7,      # default value
    );

=head2 extends

Inherits the specified class.

    package Foo;
    
    extends 'MyPackage';

    1;

=head2 force

Use the Force to push a subroutine into a class.

    package JediPackage;
    
    use TheForce;

    has ( green => { is => 'ro', isa => 'Str', default => 'Yoda is green!' } );

    package SithLord;
    
    use TheForce;
    
    extends 'JediPackage';

    JediPackage->force( yoda => sub {
        my $self = shift;
        
        say $self->green;
    });

    my $jedi = JediPackage->new;
    $jedi->yoda;

=head2 force_pull

Force pulls all the classes within the calling namespace.

    package Jedi::Yoda;
    
    use TheForce;
 
    has 'yoda' => ( isa => 'Str', default => 'Inherited, am I' );

    package Jedi::Obi;

    use TheForce;
    
    package Jedi;

    use TheForce;

    __PACKAGE__->force_pull; # inherits Jedi::Yoda and Jedi::Obi
    
    say Jedi::Yoda->yoda;    

=head2 before

Alters the subroutine to call the specified subroutine _before_ whatever is currently already set.

    sub greet {
        say "Hello!";
    }

    before 'greet' => sub {
        say "I'm going to say hello...";
    }

    # when greet is called it outputs:
    # I'm going to say hello...
    # Hello!

=head2 after

The same as C<before> but runs the new code _after_ the old subroutine code

=head1 AUTHOR

Brad Haywood <brad@geeksware.net>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

1;
