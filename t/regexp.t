#!perl -w

print "1..1\n";

use Data::Dump;

$a = {
   a => qr/Foo/,
   b => qr,abc/,i,
};

print "not " unless Data::Dump::dump($a) eq '{ a => qr/(?-xism:Foo)/, b => qr/(?i-xsm:abc\/)/ }';
print "ok 1\n";
