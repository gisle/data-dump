use strict;
use Test;

BEGIN { plan tests => 4 }

use Data::Dump qw(dump);
use Data::Dump::Filtered qw(dump_filtered);

# basic

my $a = {
    a  => "123456789012345678901234567890",
    bb => "123456789012345678901234567890",
};
ok(dump($a), qq|{\n  a  => "123456789012345678901234567890",\n  bb => "123456789012345678901234567890",\n}|);
{
    local $Data::Dump::NL = "";
    ok(dump($a), qq|{ a => "123456789012345678901234567890", bb => "123456789012345678901234567890" }|);
}

# comment

my $filter = sub {
    my ($ctx, $oref) = @_;
    return { comment=>"comment" };
};
ok(dump_filtered($a, $filter), qq|# comment\n{\n  a  => # comment\n        "123456789012345678901234567890",\n  bb => # comment\n        "123456789012345678901234567890",\n}|);
{
    local $Data::Dump::NL = "";
    ok(dump_filtered($a, $filter), qq|{ a => "123456789012345678901234567890", bb => "123456789012345678901234567890" }|);
}
