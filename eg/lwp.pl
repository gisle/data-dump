
use strict;
use LWP::UserAgent;

use Data::Dump::Filtered qw(add_dump_filter);
add_dump_filter(sub {
    my($ctx, $obj) = @_;
    if ($ctx->object_isa("LWP::UserAgent")) {
	return {
	    comment => $ctx->class,
	    hide_keys => [qw(handlers)],
	}
    }
    if ($ctx->is_scalar && defined($$obj) && length($$obj) > 32) {
	return {
	    object => substr($$obj, 0, 10) . "..." . substr($$obj, -5),
	    comment => "Truncated; @{[length($$obj) - 15]} chars not shown",
	}
    }
    if ($ctx->object_isa("URI")) {
	return {
	    dump => "q<$$obj>",
	}
    }
    return;
});

use Data::Dump;
my $ua = LWP::UserAgent->new;
dd $ua;

dd $ua->get("http://www.example.com");
