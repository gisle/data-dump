use strict;
use warnings;
use Test::More tests => 4;

use Data::Dump qw/dump/;

if ("abc" =~ /(.+)/) {
    is(dump($1), '"abc"');
    is(dump(\$1), '\"abc"');
    is(dump([$1]), '["abc"]');
}

if ("123" =~ /(.+)/) {
    local $TODO = '$1 still modified by dump itself';
    is(dump($1), "123");
}
