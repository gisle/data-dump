print "1..14\n";

use Data::Dump qw(dump);

print "not " unless dump() eq "()";
print "ok 1\n";

print "not " unless dump("abc") eq qq("abc");
print "ok 2\n";

print "not " unless dump(undef) eq "undef";
print "ok 3\n";

print "not " unless dump(0) eq "0";
print "ok 4\n";

print "not " unless dump(1234) eq "1234";
print "ok 5\n";

print "not " unless dump(12345) eq "12_345";
print "ok 6\n";

print "not " unless dump(12345678) eq "12_345_678";
print "ok 7\n";

print "not " unless dump(-33) eq "-33";
print "ok 8\n";

print "not " unless dump(-123456) eq "-123_456";
print "ok 9\n";

print "not " unless dump("0123") eq qq("0123");
print "ok 10\n";

print "not " unless dump(1..5) eq "(1, 2, 3, 4, 5)";
print "ok 11\n";

$a = [1..5];
print "not " unless dump($a) eq "[1, 2, 3, 4, 5]";
print "ok 12\n";

$h = { a => 1, b => 2 };
print "not " unless dump($h) eq "{ a => 1, b => 2 }";
print "ok 13\n";

$h = { 1 => 1, 2 => 1, 10 => 1 };
print "not " unless dump($h) eq "{ 1 => 1, 2 => 1, 10 => 1 }";
print "ok 14\n";
