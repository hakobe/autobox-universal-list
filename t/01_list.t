use strict;
use warnings;

package Hatena;

sub new {
    my($class, %args) = @_;
    bless {%args}, $class;
}

sub name { shift->{name} };

package autobox::UNIVERSAL::List::Test;
use base qw/Test::Class/;

use Test::More;
use autobox::UNIVERSAL::List;

__PACKAGE__->runtests;

sub use_test : Tests(1) {
    use_ok 'List::Rubyish';
}

sub new_test : Tests(6) {
    my $list = [1,2];
    ok $list;
    is $list->size, 2;
    is $list->first, 1;
    is $list->last, 2;
}

sub index_of : Tests(7) {
    my $list = [0,1,2,3];
    ok ($list, 'list');
    is ($list->index_of(0), 0, 'index of 0');
    is ($list->index_of(1), 1, 'index of 1');
    is ($list->index_of(2), 2, 'index of 2');
    is ($list->index_of(3), 3, 'index of 3');
    ok (!$list->index_of(4), 'index of 4');
    is ($list->index_of(sub { shift == 2 }), 2, 'index of sub(2)');
}

sub grep_hash : Tests(1) {
    my $list = [
        { name => 0 },
        { name => 1 },
        { name => '' },
        { name => 'lopnor' },
    ]->grep('name');
    is ($list->size, 2, 'grep hash');
}

sub grep_class : Tests(1) {
    my $list = [
        Hatena->new( name => 0 ),
        Hatena->new( name => 1 ),
        Hatena->new( name => '' ),
        Hatena->new( name => 'lopnor' ),
    ]->grep('name');
    is ($list->size, 2, 'grep object');
}

1;
