use strict;
use warnings;
use utf8;
use Data::Dumper;
use Perl6::Say;
use URI;
use XML::Feed;
use autobox::UNIVERSAL::List
    impl_class => qw(List::RubyLike);
use Encode qw(encode_utf8);

sub p($) {
    say Dumper @_;
}

my $feed_uri = 'http://d.hatena.ne.jp/hakobe932/rss';

say [XML::Feed->parse(URI->new($feed_uri))->entries]
    ->grep( sub { $_->content->body =~ m/Perl/i })
    ->map ( sub { $_->title.' - '.$_->link })
    ->join("\n");
