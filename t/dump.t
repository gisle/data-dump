#!perl -w

use strict;
use Test qw(plan ok);
plan tests => 14;

use Data::Dump qw(dump);

ok(dump(), "()");
ok(dump("abc"), qq("abc"));
ok(dump(undef), "undef");
ok(dump(0), "0");
ok(dump(1234), "1234");
ok(dump(12345), "12_345");
ok(dump(12345678), "12_345_678");
ok(dump(-33), "-33");
ok(dump(-123456), "-123_456");
ok(dump("0123"), qq("0123"));
ok(dump(1..5), "(1, 2, 3, 4, 5)");
ok(dump([1..5]), "[1, 2, 3, 4, 5]");
ok(dump({ a => 1, b => 2 }), "{ a => 1, b => 2 }");
ok(dump({ 1 => 1, 2 => 1, 10 => 1 }), "{ 1 => 1, 2 => 1, 10 => 1 }");
