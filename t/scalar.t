print "1..1\n";

use Data::Dump qw(dump);

$a = 42;
@a = (\$a);

my $d = dump($a, $a, \$a, \\$a, "$a", $a+0, \@a);

print "$d;\n";

print "not " unless $d eq q(do {
  my $a = 42;
  ($a, $a, \\$a, \\\\$a, 42, 42, [\\$a]);
});
print "ok 1\n";
