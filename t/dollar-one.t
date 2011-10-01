use strict;
use warnings;
use Test::More tests => 3;

use Data::Dump qw/dump/;

if ("abc" =~ /(.+)/) {
    TODO: { local $TODO = '$1 modified by dump itself';
    is(dump($1), '"abc"');
    is(dump(\$1), '\"abc"');
    }
    is(dump([$1]), '["abc"]');
}
