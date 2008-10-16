package autobox::UNIVERSAL::List;

use strict;
use warnings;
use 5.8.8;
our $VERSION = '0.01';

use base qw(autobox);

sub import {
    my ($class) = shift;
    autobox::UNIVERSAL::List::Wrapper->define(@_);
    $class->SUPER::import(ARRAY => 'autobox::UNIVERSAL::List::Wrapper');
}

package # hide from pause
    autobox::UNIVERSAL::List::Wrapper;

use UNIVERSAL::isa;
use UNIVERSAL::require;

sub define {
    my ($class) = shift;
    my %args = @_;
    my $impl_class  = $args{impl_class} || 'List::Rubyish';
       $impl_class->require;
    my $new         = $args{new}  || sub { my ($array) = @_; $impl_class->new($array); };
    my $to_a        = $args{to_a} || sub { my ($self)  = @_; $self->to_a; };

    no strict 'refs';
    no warnings 'redefine';
    for my $method (keys %{"$impl_class\::"}) {
        *{ 'autobox::UNIVERSAL::List::Wrapper::' . $method } = sub {
            my $self = $new->(shift);
            my $result = $self->$method(@_);
            $result = $to_a->($result) if UNIVERSAL::isa($result, $impl_class);
            $result;
        };
    }
}

1;

