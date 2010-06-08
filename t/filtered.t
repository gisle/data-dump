#!perl -w

use strict;
use Test qw(plan ok);
plan tests => 2;

use Data::Dump qw(dumpf);

ok(dumpf("foo", sub { return { use_repr => "x" }}), 'x');
ok(dumpf("foo", sub { return }), '"foo"');
