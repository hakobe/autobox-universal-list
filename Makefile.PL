use inc::Module::Install;
name 'autobox-UNIVERSAL-List';
all_from 'lib/autobox/UNIVERSAL/List.pm';

requires qw(
    autobox
    UNIVERSAL::isa
    UNIVERSAL::require
    List::Rubyish
);

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
