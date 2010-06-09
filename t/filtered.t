#!perl -w

use strict;
use Test qw(plan ok);
plan tests => 3;

use Data::Dump qw(dumpf);

ok(dumpf("foo", sub { return { dump => "x" }}), 'x');
ok(dumpf("foo", sub { return }), '"foo"');
ok(dumpf("foo", undef), '"foo"');
