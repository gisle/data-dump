package Data::Dump::Trace;

use strict;

use base 'Exporter';
our @EXPORT_OK = qw(call mcall wrap autowrap);

use Data::Dump qw(dump);
use Term::ANSIColor qw(YELLOW CYAN RESET);
use Carp qw(croak);
use overload ();

my %obj_name;
my %autowrap_class;
my %name_count;

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

sub autowrap {
    while (@_) {
        my $class = shift;
        my $name = shift;
        unless ($name) {
            $name = lc($class);
            $name =~ s/.*:://;
        }
        $name = '$' . $name unless $name =~ /^\$/;
        $autowrap_class{$class} = $name;
    }
}

sub wrap {
    my %arg = @_;
    my $name = $arg{name} || "func";
    my $func = $arg{func};

    return sub {
        call($name, $func, undef, @_);
    } if $func;

    if (my $obj = $arg{obj}) {
        $obj_name{overload::StrVal($obj)} = $name;
        return bless {
            name => $name,
            obj => $obj,
        }, "Data::Dump::Trace::Wrapper";
    }

    croak("Either the 'func' or 'obj' option must be given");
}

sub call {
    my $name = shift;
    my $func = shift;
    my $proto = shift;
    print YELLOW, $name, dumpav(@_), RESET;
    if (!defined wantarray) {
        print "\n";
        $func->(@_);
    }
    elsif (wantarray) {
        return _ret_list($func->(@_));
    }
    else {
        return _ret_scalar($func->(@_));
    }
}

sub mcall {
    my $o = shift;
    my $method = shift;
    my $proto = shift;
    my $oname = ref($o) ? $obj_name{overload::StrVal($o)} || "\$o" : $o;
    print YELLOW, $oname, "->", $method, @_ ? dumpav(@_) : "", RESET;
    if (!defined wantarray) {
        print "\n";
        $o->$method(@_);
    }
    elsif (wantarray) {
        return _ret_list($o->$method(@_));
    }
    else {
        return _ret_scalar($o->$method(@_));
    }
}

sub _ret_list {
    print " ==> ", CYAN, dumpav(@_), RESET, "\n";
    return @_;
}

sub _ret_scalar {
    my $s = shift;
    if (my $name = $autowrap_class{ref($s)}) {
        $name .= $name_count{$name} if $name_count{$name}++;
        print " ==> ", CYAN, $name, RESET, "\n";
        $s = wrap(name => $name, obj => $s);
    }
    else {
        print " ==> ", CYAN, dump($s), RESET, "\n";
    }
    return $s;
}

package Data::Dump::Trace::Wrapper;

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    my $method = substr($AUTOLOAD, rindex($AUTOLOAD, '::')+2);
    Data::Dump::Trace::mcall($self->{obj}, $method, undef, @_);
}

1;
