package Data::Dump::FilterContext;

sub new {
    my($class, $obj, $oclass, $type, $ref, $pclass, $pidx, $idx) = @_;
    return bless {
	object => $obj,
	class => $ref && $oclass,
	reftype => $type,
	is_ref => $ref,
	pclass => $pclass,
	pidx => $pidx,
	idx => $idx,
    }, $class;
}

sub object {
    my $self = shift;
    return $self->{object};
}

sub class {
    my $self = shift;
    return $self->{class} || "";
}

sub reftype {
    my $self = shift;
    return $self->{reftype} || "";
}

sub is_ref {
    my $self = shift;
    return $self->{is_ref};
}

sub parent_class {
    my $self = shift;
    return $self->{pclass} || "";
}

sub parent_self {
    my $self = shift;
    return "" unless $self->{pclass};
    my $idx = $self->{idx};
    my $pidx = $self->{pidx};
    return Data::Dump::fullname("self", [@$idx[$pidx..(@$idx - 1)]]);
}

sub isa {
    my($self, $class) = @_;
    return $self->{class} && $self->{class}->isa($class);
}

sub parent_isa {
    my($self, $class) = @_;
    return $self->{pclass} && $self->{pclass}->isa($class);
}

1;
