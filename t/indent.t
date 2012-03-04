#!perl -w

use strict;
use Test;
plan tests => 4;

use Data::Dump qw(dump);

my $DOTS = "." x 20;

my $hash = {
    aa   => 1,
    foo  => $DOTS,
    bar  => $DOTS,
    baz  => $DOTS,
    nest => {
	foo => $DOTS,
	bar => $DOTS,
	baz => $DOTS,
    }
};

ok(dump($hash)."\n", <<EOT);
{
  aa   => 1,
  bar  => "$DOTS",
  baz  => "$DOTS",
  foo  => "$DOTS",
  nest => {
            bar => "$DOTS",
            baz => "$DOTS",
            foo => "$DOTS",
          },
}
EOT

$Data::Dump::INDENT = "| ";
ok(dump($hash)."\n", <<EOT);
{
| aa   => 1,
| bar  => "$DOTS",
| baz  => "$DOTS",
| foo  => "$DOTS",
| nest => {
|         | bar => "$DOTS",
|         | baz => "$DOTS",
|         | foo => "$DOTS",
|         },
}
EOT

$Data::Dump::INDENT = "    ";
ok(dump($hash)."\n", <<EOT);
{
    aa   => 1,
    bar  => "$DOTS",
    baz  => "$DOTS",
    foo  => "$DOTS",
    nest => {
                bar => "$DOTS",
                baz => "$DOTS",
                foo => "$DOTS",
            },
}
EOT

$Data::Dump::INDENT = "";
ok(dump($hash)."\n", <<EOT);
{ aa => 1, bar => "$DOTS", baz => "$DOTS", foo => "$DOTS", nest => { bar => "$DOTS", baz => "$DOTS", foo => "$DOTS" } }
EOT
