print "1..6\n";

use Data::Dump qw(dump);

print "not " unless dump() eq "()";
print "ok 1\n";

print "not " unless dump("abc") eq qq("abc");
print "ok 2\n";

print "not " unless dump(undef) eq "undef";
print "ok 3\n";

print "not " unless dump(0) eq "0";
print "ok 4\n";

print "not " unless dump(1..5) eq "(1, 2, 3, 4, 5)";
print "ok 5\n";

$a = [1..5];
print "not " unless dump($a) eq "[1, 2, 3, 4, 5]";
print "ok 6\n";
