#!perl -w

use Test;
plan tests => 1;

use Data::Dump;

$a = {
   a => qr/Foo/,
   b => qr,abc/,is,
   c => qr/ foo /x,
   d => qr/foo/msix,
   e => qr//,
   f => qr/
     # hi there
     how do this look
   /x,
   g => qr,///////,,
   h => qr*/|,:*,
   i => qr*/|,:#*,
   j => bless(qr/Foo/, "Regexp::Alt"),
   k => \qr/Foo/,
};

ok(Data::Dump::dump($a) . "\n", <<'EOT');
{
  a => qr/Foo/,
  b => qr|abc/|si,
  c => qr/ foo /x,
  d => qr/foo/msix,
  e => qr//,
  f => qr/
            # hi there
            how do this look
          /x,
  g => qr|///////|,
  h => qr#/|,:#,
  i => qr/\/|,:#/,
  j => bless(qr/Foo/, "Regexp::Alt"),
  k => \qr/Foo/,
}
EOT
