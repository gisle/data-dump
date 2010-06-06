package Data::Dump::Filtered;

use Data::Dump;

sub add_filter {
    my $filter = shift;
    die unless ref($filter) eq "CODE";
    push(@Data::Dump::FILTERS, $filter);
    return $filter;
}

sub remove_filter {
    my $filter = shift;
    @Data::Dump::FILTERS = grep $_ ne $filter, @Data::Dump::FILTERS;
}

sub dump_filtered {
    my $filter = pop;
    die unless ref($filter) eq "CODE";

    local @Data::Dump::FILTERS = ($filter);
    return &Data::Dump::dump;
}

1;
