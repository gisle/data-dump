package Data::Dump::Trace;

use strict;

use base 'Exporter';
our @EXPORT_OK = qw(call mcall wrap);

use Data::Dump qw(dump);
use Term::ANSIColor qw(YELLOW CYAN RESET);
use Carp qw(croak);

my %obj_name;

sub dumpav {
    return "(" . dump(@_) . ")" if @_ == 1;
    return dump(@_);
}

sub dumpkv {
    return dumpav(@_) if @_ % 2;
    my %h = @_;
    my $str = dump(\%h);
    $str =~ s/^\{/(/ && $str =~ s/\}\z/)/;
    return $str;
}

sub wrap {
    my %arg = @_;
    my $name = $arg{name} || "func";
    my $func = $arg{func};

    return sub {
        call($name, $func, @_);
    } if $func;

    my $obj = $arg{obj};
    return bless { name => $name, obj => $obj }, "Data::Dump::Trace::Wrapper" if $obj;

    croak("Either the 'func' or 'obj' option must be given");
}

sub call {
    my $name = shift;
    my $func = shift;
    print YELLOW, $name, dumpav(@_), RESET;
    if (!defined wantarray) {
        print "\n";
        $func->(@_);
    }
    elsif (wantarray) {
        my @s = $func->(@_);
        print " ==> ", CYAN, dumpav(@s), RESET, "\n";
        return @s;
    }
    else {
        my $s = $func->(@_);
        print " ==> ", CYAN, dump($s), RESET, "\n";
        return $s;
    }
}

sub mcall {
    my $o = shift;
    my $method = shift;
    my $oname = ref($o) ? "\$o" : $o;
    print YELLOW, $oname, "->", $method, dumpav(@_), RESET;
    if (!defined wantarray) {
        print "\n";
        $o->$method(@_);
    }
    elsif (wantarray) {
        my @s = $o->$method(@_);
        print " ==> ", CYAN, dumpav(@s), RESET, "\n";
        return @s;
    }
    else {
        my $s = $o->$method(@_);
        print " ==> ", CYAN, dump($s), RESET, "\n";
        return $s;
    }
}

package Data::Dump::Trace::Wrapper;

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    my $method = substr($AUTOLOAD, rindex($AUTOLOAD, '::')+2);
    Data::Dump::Trace::mcall($self->{obj}, $method, @_);
}

1;
