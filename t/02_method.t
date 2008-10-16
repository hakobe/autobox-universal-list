# original code is http://github.com/naoya/list-rubylike/tree/master/t/01-methods.t
package autobox::UNIVERSAL::List::Test;
use strict;
use warnings;
use base qw/Test::Class/;

use Test::More;
use autobox::UNIVERSAL::List;

__PACKAGE__->runtests;

sub list (@) {
    my @raw = (ref $_[0] and ref $_[0] eq 'ARRAY') ? @{$_[0]} : @_;
    \@raw;
}

sub test_instantiate : Test(8) {
    my $list = list([qw/foo bar baz/]);
    is @$list, 3;

    $list = list(qw/foo bar baz/);
    is @$list, 3;

    $list = list();
    is @$list, 0;

    $list = list({ foo => 'bar' });
    is_deeply $list->to_a, [ { foo => 'bar' } ];
}

sub test_push_and_pop : Test(7) {
    my $list = list(qw/foo bar baz/);
    $list->push('foo');
    is @$list, 4;
    is $list->[3], 'foo';

    $list->push('foo', 'bar');
    is @$list, 6;
    is $list->[5], 'bar';

    is $list->pop, 'bar';
    is @$list, 5;
}

sub test_unshift_and_shift : Test(7) {
    my $list = list(qw/foo bar baz/);
    $list->unshift('hoge');
    is @$list, 4;
    is $list->[0], 'hoge';

    $list->unshift('moge', 'uge');
    is @$list, 6;
    is $list->[0], 'moge';

    is $list->shift, 'moge';
    is @$list, 5;
}

sub test_first_and_last : Test(3) {
    my @elements = qw/foo bar baz/;
    my $list = list(@elements);
    is $list->first, 'foo';
    is $list->last, 'baz';
    is_deeply $list->to_a, [qw/foo bar baz/];
}

sub dump : Test(1) {
    my $struct = [
        qw /foo bar baz/,
        [0, 1, 2, 3, 4],
    ];

    is_deeply($struct, eval list($struct)->dump);
}

sub join : Test(3) {
    my $list = list(qw/foo bar baz/);
    is $list->join('/'), 'foo/bar/baz';
    is $list->join('.'), 'foo.bar.baz';
    is $list->join(''), 'foobarbaz';
}

sub each : Test(3) {
    my $list =list(qw/foo bar baz/);
    my @resulsts;
    my $ret = $list->each(sub{ s!^ba!!; push @resulsts, $_  });
    is_deeply \@resulsts, [qw/foo r z/];
    is_deeply $ret->to_a, [qw/foo bar baz/];
}

sub each_index : Test(2) {
    my $list = list(qw/foo bar baz/);
    my @indexes;
    my $ret = $list->each_index(sub { push @indexes, $_ });
    is_deeply \@indexes, [0, 1, 2];
}

sub test_concat_and_append : Test(10) {
    for my $method (qw/concat append/) {
        my $list = list(qw/foo bar baz/);
        $list->$method(['foo']);
        is @$list, 4;
        is $list->[3], 'foo';
        $list->$method(['foo', 'bar']);
        is @$list, 6;
        is $list->[5], 'bar';

#         $list->$method('baz');
#         is @$list, 7;
#         is $list->[6], 'baz';
    }
}

sub test_prepend : Test(5) {
    my $list = list(qw/foo bar baz/);
    $list->prepend(['foo']);
    is @$list, 4;
    is $list->[0], 'foo';
    $list->prepend(['foo', 'bar']);
    is @$list, 6;
    is $list->[0], 'foo';
}

sub test_collect_and_map : Test(10) {
    for my $method (qw/collect map/) {
        my $list = list(qw/foo bar baz/);

        my $new = $list->$method(sub { s/^ba//; $_ });
        is_deeply $new->to_a, [qw/foo r z/];
        is_deeply $list->to_a, [qw/foo bar baz/];

        my @new = $list->$method(sub { s/^ba//; $_ });
        is_deeply \@new, [qw/foo r z/];
        is_deeply $list->to_a, [qw/foo bar baz/];
    }
}

sub test_zip : Tests(4) {
    my $list = list([1,2,3]);
    is_deeply(
        $list->zip([1,2,3], [1,2,3])->to_a,
        [[1,1,1],[2,2,2],[3,3,3]]
    );
    is_deeply(
        $list->zip(list([1,2,3]), [1,2,3])->to_a,
        [[1,1,1],[2,2,2],[3,3,3]]
    );
    is_deeply(
        $list->zip(list([1,2,3]), [1,2])->to_a,
        [[1,1,1],[2,2,2],[3,3,undef]]
    );
    is_deeply(
        $list->zip(list([1,2,3]), [1,2,3,4])->to_a,
        [[1,1,1],[2,2,2],[3,3,3]]
    );
}

sub test_delete :  Tests(8) {
    my $list = list([1,2,3,2,1,5]);

    my $code = sub { $_ == 5 };
    is( $list->delete($code), $code);
    is_deeply( $list->to_a, [1,2,3,2,1]);
    is( $list->delete(2), 2);
    is_deeply( $list->to_a, [1,3,1]);
    is( $list->delete(2), undef);
    is( $list->delete(2, +{}), undef);
    is( $list->delete(2, sub { return $_ * $_}), 4);
    is_deeply( $list->to_a, [1,3,1]);
}

sub test_delete_str :  Tests(3) {
    my $list = list([qw/ foo bar baz /]);

    is_deeply( $list->to_a, [qw/ foo bar baz /]);
    is( $list->delete('bar'), 'bar');
    is_deeply( $list->to_a, [qw/ foo baz /]);
}

sub test_delete_at : Tests(6) {
    my $ary = [1,2,3,4,5];
    my $list = list($ary);
    ok not $list->delete_at(5);
    is_deeply( $list->to_a, $ary);
    is_deeply( $list->delete_at(2), 3);
    is_deeply( $list->to_a, [1,2,4,5]);
    is_deeply( $list->delete_at(0), 1);
    is_deeply( $list->to_a, [2,4,5]);
}

sub test_delete_if: Tests(2) {
    my $list = list([1,2,3,4,5]);
    is_deeply( $list->delete_if( sub { $_ < 3 ? 1 : 0 } )->to_a, [1,2]);
    is_deeply( $list->to_a, [1,2] );
}

sub test_inject: Tests(3) {
    my $list = list([1,2,3,4,5]);
    is_deeply( $list->inject(10, sub { $_[0] + $_[1] }), 25);
    is_deeply( $list->inject(10, sub { $_[0] - $_[1] }), -5);
    is_deeply( $list->inject('a', sub { $_[0] . $_[1] }), 'a12345');
}

sub test_grep : Tests(3) {
    my $list = list(qw/foo bar baz/);
    is_deeply $list->grep(sub { m/^b/ })->to_a, [qw/bar baz/];

    my @ret = $list->grep(sub { m/^b/ });
    is_deeply \@ret, [qw/bar baz/];
}

sub test_sort : Tests(5) {
    my $list = list(3, 1, 2);
    is_deeply $list->sort->to_a, [1, 2, 3];
    is_deeply $list->sort(sub { $_[1] <=> $_[0] })->to_a, [3, 2, 1];
    is_deeply $list->to_a, [3, 1, 2];

    my @ret = $list->sort(sub { $_[1] <=> $_[0] });
    is_deeply \@ret, [3, 2, 1];
}

sub test_compact : Tests {
    my $list = list(1, 2, undef, 4);

    is $list->compact->size, 3;
    is_deeply $list->compact->to_a, [1, 2, 4];

    is $list->size, 4;
    is_deeply $list->to_a, [1, 2, undef, 4];
}

sub test_length_and_size : Test(4) {
    for my $method (qw/length size/) {
        is list(1, 2, 3, 4)->size, 4;
        is list()->size, 0;
    }
}

sub test_flatten : Tests(3) {
    my $list = list([1, 2, 3, [4, 5, 6, [7, 8, 9, {10 => '11'} ]]]);

    is_deeply $list->flatten->to_a, [1, 2, 3, 4, 5, 6, 7, 8, 9, { 10 => '11' }];
    is_deeply $list->to_a, [1, 2, 3, [4, 5, 6, [7, 8, 9, { 10 => '11' } ]]];
}

sub test_is_empty : Test(2) {
    ok list()->is_empty;
    ok not list(1, 2, 3)->is_empty;
}

sub test_uniq : Test(3) {
    my $list = list(1, 2, 3, 3, 4);
    is_deeply $list->uniq, [1, 2, 3, 4];
    is_deeply $list->to_a, [1, 2, 3, 3, 4];
}

sub test_reduce : Test(1) {
    my $list = list(1, 2, 10, 5, 9);
    is $list->reduce(sub { $_[0] > $_[1] ? $_[0] : $_[1] }), 10;
}

sub test_dup : Test(3) {
    my $list = list(1, 2, 3);
    isnt $list, $list->dup;
    is_deeply $list->to_a, $list->dup->to_a;
}

sub test_slice : Test(12) {
    my $list = list(0, 1, 2);

    is_deeply $list->slice(0, 0)->to_a, [0];
    is_deeply $list->slice(0, 1)->to_a, [0, 1];
    is_deeply $list->slice(0, 2)->to_a, [0, 1, 2];
    is_deeply $list->slice(0, 3)->to_a, [0, 1, 2];

    is_deeply $list->slice(1, 1)->to_a, [1];
    is_deeply $list->slice(1, 2)->to_a, [1, 2];
    is_deeply $list->slice(1, 3)->to_a, [1, 2];

    is_deeply $list->slice(0)->to_a, [0, 1, 2];
    is_deeply $list->slice(1)->to_a, [0, 1, 2];
    is_deeply $list->slice(2)->to_a, [];

    is_deeply $list->slice(3)->to_a, [];
    is_deeply $list->slice->to_a, [0, 1, 2];
}

sub test_find : Test(12) {
    my $list = list(1, 2, 3);

    is $list->find(sub { $_ == 1 }), 1;
    is $list->find(sub { $_ == 2 }), 2;
    is $list->find(sub { $_ == 3 }), 3;
    is $list->find(sub { $_ == 4 }), undef;

    is $list->find(1), 1;
    is $list->find(2), 2;
    is $list->find(3), 3;
    is $list->find(4), undef;

    is $list->find(+{ kyururi => 1 }), undef;
    is $list->find(+{ kyururi => 2 }), undef;
    is $list->find(+{ kyururi => 3 }), undef;
    is $list->find(+{ kyururi => 4 }), undef;
}

sub test_index_of : Test(7) {
    my $list = list(0, 1, 2, 3);

    is $list->index_of(0), 0;
    is $list->index_of(1), 1;
    is $list->index_of(2), 2;
    is $list->index_of(3), 3;
    is $list->index_of(4), undef;

    is $list->index_of(sub { shift == 2 }), 2;
    is $list->index_of(sub { shift == 5 }), undef;
}

sub test_reverse : Test(1) {
    my $list = list(0, 1, 2, 3);
    is_deeply [3, 2, 1, 0], $list->reverse->to_a;
}

sub test_sum : Test(2) {
    is list(0, 1, 2, 3)->sum, 0 + 1 + 2 + 3;
    is list(1, 1, 1, 1)->sum, 1 + 1 + 1 + 1;
}

sub test_some_method_argument_in_not_a_code : Test(5) {
    my $obj = [];

    for my $method (qw/ delete_if inject each collect reduce /) {
        local $@;
        eval { $obj->$method( +{} ) };
        like $@, qr/Argument must be a code/, $method;
    }
}

sub test_grep_argment_error : Test(2) {
    my $obj = [];

    ok !$obj->grep;
    local $@;
    eval { $obj->grep(+{}) };
    like $@, qr/Invalid code/;
}

1;
