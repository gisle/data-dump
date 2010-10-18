#!perl -w

use strict;
use Test;
plan tests => 9;

use Data::Dump 'dump';

ok(dump(v10), q{v10});
ok(dump(v5.10.1), q{v5.10.1});
ok(dump(5.10.1), q{v5.10.1});
ok(dump(500.400.300.200.100), q{v500.400.300.200.100});

ok(dump(\5.10.1), q{\v5.10.1});
ok(dump(\v10), q{\v10});
ok(dump(\\v10), q{\\\\v10});
ok(dump([v10, v20, v30]), q{[v10, v20, v30]});
ok(dump({ version => v6.0.0 }), q({ version => v6.0.0 }));
