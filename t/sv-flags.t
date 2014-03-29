use strict;

use Test qw(plan ok);

plan tests => 2;

use B;
use Data::Dump qw(dump);

my $c = "abc";
my $orig_flags = B::svref_2object(\$c)->FLAGS;
ok(dump($c), qq("abc"));
ok B::svref_2object(\$c)->FLAGS, $orig_flags;

