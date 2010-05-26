#!perl -w

use strict;
use Test;
plan tests => 8;

use Data::Dump qw(dump);

my $DOTS = "." x 20;

ok(dump({}), "{}");
ok(dump({ a => 1}), "{ a => 1 }");
ok(dump({ 1 => 1}), "{ 1 => 1 }");
ok(dump({strict => 1, "shift" => 2, abc => 3}),
    "{ abc => 3, \"shift\" => 2, strict => 1 }");
ok(dump({supercalifragilisticexpialidocious => 1, a => 2}),
    "{ a => 2, supercalifragilisticexpialidocious => 1 }");
ok(dump({supercalifragilisticexpialidocious => 1, a => 2, b => $DOTS})."\n", <<EOT);
{
  a => 2,
  b => "$DOTS",
  supercalifragilisticexpialidocious => 1,
}
EOT
ok(dump({aa => 1, B => 2}), "{ B => 2, aa => 1 }");
ok(dump({a => 1, foo => 2, bar => $DOTS, baz => $DOTS})."\n", <<EOT);
{
  a   => 1,
  bar => "$DOTS",
  baz => "$DOTS",
  foo => 2,
}
EOT
