package Data::Dump;

use strict;
use vars qw(@EXPORT_OK $VERSION $DEBUG);

require Exporter;
*import = \&Exporter::import;
@EXPORT_OK=qw(dump pp);

$VERSION = "0.03";  # $Date$
$DEBUG = 0;

use overload ();
use vars qw(%seen %refcnt @dump @fixup %require);

my %is_perl_keyword = map { $_ => 1 }
qw( __FILE__ __LINE__ __PACKAGE__ __DATA__ __END__ AUTOLOAD BEGIN CORE
DESTROY END EQ GE GT INIT LE LT NE abs accept alarm and atan2 bind
binmode bless caller chdir chmod chomp chop chown chr chroot close
closedir cmp connect continue cos crypt dbmclose dbmopen defined
delete die do dump each else elsif endgrent endhostent endnetent
endprotoent endpwent endservent eof eq eval exec exists exit exp fcntl
fileno flock for foreach fork format formline ge getc getgrent
getgrgid getgrnam gethostbyaddr gethostbyname gethostent getlogin
getnetbyaddr getnetbyname getnetent getpeername getpgrp getppid
getpriority getprotobyname getprotobynumber getprotoent getpwent
getpwnam getpwuid getservbyname getservbyport getservent getsockname
getsockopt glob gmtime goto grep gt hex if index int ioctl join keys
kill last lc lcfirst le length link listen local localtime lock log
lstat lt m map mkdir msgctl msgget msgrcv msgsnd my ne next no not oct
open opendir or ord pack package pipe pop pos print printf prototype
push q qq qr quotemeta qw qx rand read readdir readline readlink
readpipe recv redo ref rename require reset return reverse rewinddir
rindex rmdir s scalar seek seekdir select semctl semget semop send
setgrent sethostent setnetent setpgrp setpriority setprotoent setpwent
setservent setsockopt shift shmctl shmget shmread shmwrite shutdown
sin sleep socket socketpair sort splice split sprintf sqrt srand stat
study sub substr symlink syscall sysopen sysread sysseek system
syswrite tell telldir tie tied time times tr truncate uc ucfirst umask
undef unless unlink unpack unshift untie until use utime values vec
wait waitpid wantarray warn while write x xor y);


sub dump
{
    local %seen;
    local %refcnt;
    local %require;
    local @fixup;

    my $name = "a";
    my @dump;

    for (@_) {
	my $val = _dump($_, $name, []);
	push(@dump, [$name, $val]);
    } continue {
	$name++;
    }

    my $out = "";
    if (%require) {
	for (sort keys %require) {
	    $out .= "require $_;\n";
	}
    }
    if (%refcnt) {
	# output all those with refcounts first
	for (@dump) {
	    my $name = $_->[0];
	    if ($refcnt{$name}) {
		$out .= "my \$$name = $_->[1];\n";
		undef $_->[1];
	    }
	}
	for (@fixup) {
	    $out .= "$_;\n";
	}
    }

    my $paren = (@dump != 1);
    $out .= "(" if $paren;
    $out .= format_list($paren,
			map {defined($_->[1]) ? $_->[1] : "\$".$_->[0]}
			    @dump
		       );
    $out .= ")" if $paren;

    if (%refcnt || %require) {
	$out .= ";\n";
	$out =~ s/^/  /gm;  # indent
	$out = "do {\n$out}";
    }

    #use Data::Dumper;   print Dumper(\%refcnt);
    #use Data::Dumper;   print Dumper(\%seen);

    print STDERR "$out\n" unless defined wantarray;
    $out;
}

*pp = \&dump;

sub _dump
{
    my $ref  = ref $_[0];
    my $rval = $ref ? $_[0] : \$_[0];
    shift;

    my($name, $idx) = @_;

    my($class, $type, $id);
    if (overload::StrVal($rval) =~ /^(?:([^=]+)=)?([A-Z]+)\(0x([^\)]+)\)$/) {
	$class = $1;
	$type  = $2;
	$id    = $3;
    } else {
	die "Can't parse " . overload::StrVal($rval);
    }
    warn "$name-(@$idx) $class $type $id ($ref)" if $DEBUG;
    
    if (my $s = $seen{$id}) {
	my($sname, $sidx) = @$s;
	$refcnt{$sname}++;
	my $sref = fullname($sname, $sidx);
	warn "SEEN: [$name/@$idx] => [$sname/@$sidx] ($ref,$sref)" if $DEBUG;
	$sref = "\\$sref" if $ref && $type eq "SCALAR";
	return $sref unless $sname eq $name;
	$refcnt{$name}++;
	push(@fixup, fullname($name,$idx)." = $sref");
	return "'fix'";
    }
    $seen{$id} = [$name, $idx];

    my $out;
    if ($type eq "SCALAR") {
	if ($ref) {
	    delete $seen{$id};  # will be seen again shortly
	    my $val = _dump($$rval, $name, [@$idx, "\$"]);
	    $out = $class ? "do{\\(my \$o = $val)}" : "\\$val";
	} else {
	    if (!defined $$rval) {
		$out = "undef";
	    }
	    elsif ($$rval =~ /^-?[1-9]\d{0,8}$/ || $$rval eq "0") {
		$out = $$rval;
	    }
	    else {
		$out = quote($$rval);
	    }
	    if ($class && !@$idx) {
		# Top is an object, not a reference to one as perl needs
		$refcnt{$name}++;
		my $obj = fullname($name, $idx);
		my $cl  = quote($class);
		push(@fixup, "bless \\$obj, $cl");
	    }
	}
    }
    elsif ($type eq "GLOB") {
	if ($ref) {
	    delete $seen{$id};
	    my $val = _dump($$rval, $name, [@$idx, "*"]);
	    $out = "\\$val";
	    if ($out =~ /^\\\*Symbol::/) {
		$require{Symbol}++;
		$out = "Symbol::gensym()";
	    }
	} else {
	    my $val = "$$rval";
	    $out = "$$rval";

	    for my $k (qw(SCALAR ARRAY HASH)) {
		my $gval = *$$rval{$k};
		next unless defined $gval;
		next if $k eq "SCALAR" && ! defined $$gval;  # always there
		my $f = scalar @fixup;
		push(@fixup, "RESERVED");  # filled out after _dump()
		$gval = _dump($gval, $name, [@$idx, "*{$k}"]);
		$refcnt{$name}++;
		my $gname = fullname($name, $idx);
		$fixup[$f] = "$gname = $gval";  #XXX indent $gval
	    }
	}
    }
    elsif ($type eq "ARRAY") {
	my @vals;
	my $i = 0;
	for (@$rval) {
	    push(@vals, _dump($_, $name, [@$idx, "[$i]"]));
	    $i++;
	}
	$out = "[" . format_list(1, @vals) . "]";
    }
    elsif ($type eq "HASH") {
	my(@keys, @vals);
	my $max_klen = 0;
	for my $key (sort keys %$rval) {
	    my $val = \$rval->{$key};
	    $key = quote($key) if $key !~ /^[a-zA-Z_]\w*$/ ||
#		                  length($key) > 20        ||
		                  $is_perl_keyword{$key};
	    my $klen = length $key;
	    $max_klen = $klen if $max_klen < $klen;
	    push(@keys, $key);
	    push(@vals, _dump($$val, $name, [@$idx, "{$key}"]));
	}
	$max_klen = 15 if $max_klen > 15;
	my $nl = "";
	my $tmp = "@keys @vals";
	$nl = "\n" if length($tmp) > 70 || $tmp =~ /\n/;
	$out = "{$nl";
	while (@keys) {
	    my $key = shift @keys;
	    my $val = shift @vals;
	    my $pad = " " x ($max_klen + 6);
	    $val =~ s/\n/\n$pad/gm;
	    $key = " $key" . " " x ($max_klen - length($key)) if $nl;
	    $out .= " $key => $val,$nl";
	}
	$out =~ s/,$/ / unless $nl;
	$out .= "}";
    }
    elsif ($type eq "CODE") {
	$out = 'sub { "???" }';
    }
    else {
	warn "Can't handle $type data";
	$out = "'#$type#'";
    }

    if ($class && $ref) {
	$out = "bless($out, " . quote($class) . ")";
    }
    return $out;
}

sub fullname
{
    my($name, $idx) = @_;
    substr($name, 0, 0) = "\$";

    my @i = @$idx;  # need copy in order to not modify @$idx
    while (@i && $i[0] eq "\$") {
	shift @i;
	$name = "\$$name";
    }
    
    my $last_was_index;
    for my $i (@i) {
	if ($i eq "*" || $i eq "\$") {
	    $last_was_index = 0;
	    $name = "$i\{$name}";
	} elsif ($i =~ s/^\*//) {
	    $name .= $i;
	    $last_was_index++;
	} else {
	    $name .= "->" unless $last_was_index++;
	    $name .= $i;
	}
    }
    $name;
}

sub format_list
{
    my $paren = shift;
    my $indent_lim = $paren ? 0 : 1;
    my $tmp = "@_";
    if (@_ > $indent_lim && (length($tmp) > 60 || $tmp =~ /\n/)) {
	my @elem = @_;
	for (@elem) { s/^/  /gm; }   # indent
	return "\n" . join(",\n", @elem, "");
    } else {
	return join(", ", @_) 
    }
}

my %esc = (
    "\a" => "\\a",
    "\b" => "\\b",
    "\t" => "\\t",
    "\n" => "\\n",
    "\f" => "\\f",
    "\r" => "\\r",
    "\e" => "\\e",
);

# put a string value in double quotes
sub quote {
  local($_) = $_[0];
  if (length($_) > 20) {
      # Check for repeated string
      if (/^(.{1,5}?)(\1*)$/s) {
	  my $base   = quote($1);
	  my $repeat = length($2)/length($1) + 1;
	  return "($base x $repeat)";
      }
  }
  # If there are many '"' we might want to use qq() instead
  s/([\\\"\@\$])/\\$1/g;
  return qq("$_") unless /[^\040-\176]/;  # fast exit

  my $high = $_[1];
  s/([\a\b\t\n\f\r\e])/$esc{$1}/g;

  # no need for 3 digits in escape for these
  s/([\0-\037])(?!\d)/'\\'.sprintf('%o',ord($1))/eg;

  if ($high) {
      s/([\0-\037\177])/'\\'.sprintf('%03o',ord($1))/eg;
      if ($high eq "iso8859") {
          s/[\200-\240]/'\\'.sprintf('%o',ord($1))/eg;
      } elsif ($high eq "utf8") {
#         use utf8;
#         $str =~ s/([^\040-\176])/sprintf "\\x{%04x}", ord($1)/ge;
      }
  } else {
      s/([\0-\037\177-\377])/'\\'.sprintf('%03o',ord($1))/eg;
  }

  if (length($_) > 40  && length($_) > (length($_[0]) * 2)) {
      # too much binary data, better to represent as a hex string?

      # Base64 is more compact than hex when string is longer than
      # 17 bytes (not counting any require statement needed).
      # But on the other hand, hex is much more readable.
      if (length($_[0]) > 50 && eval { require MIME::Base64 }) {
	  # XXX Perhaps we should just use unpack("u",...) instead.
	  $require{"MIME::Base64"}++;
	  return "MIME::Base64::decode(\"" .
	             MIME::Base64::encode($_[0],"") .
		 "\")";
      }
      return "pack(\"H*\",\"" . unpack("H*", $_[0]) . "\")";
  }

  return qq("$_");
}

1;

__END__

=head1 NAME

Data::Dump - Pretty printing of data structures

=head1 SYNOPSIS

 use Data::Dump qw(dump);

 $str = dump(@list)
 @copy_of_list = eval $str;

=head1 DESCRIPTION

This module provide a single function called dump() that takes a list
of values as argument and produce a string as result.  The string
contains perl code that when C<eval>ed will produce a deep copy of the
original arguments.  The string is formatted for easy reading.

If dump() is called in void context, then the dump will be printed on
STDERR instead of being returned.

If you don't like to import a function that overrides Perl's
not-so-useful builtin, then you can also import the same function as
pp(), mnemonic for "pretty-print".

=head1 HISTORY

The C<Data::Dump> module grew out of frustration with Sarathy's
in-most-cases-excellent C<Data::Dumper>.  Basic ideas and some code is shared
with Sarathy's module.

The C<Data::Dump> module provide a much simpler interface than
C<Data::Dumper>.  No OO interface is available and there are no
configuration options to worry about (yet :-).  The other benefit is
that the dump produced does not try to set any variables.  It only
returns what is needed to produce a copy of the arguments.  It means
that C<dump("foo")> simply returns C<"foo">, and C<dump(1..5)> simply
returns C<(1, 2, 3, 4, 5)>.

=head1 SEE ALSO

L<Data::Dumper>, L<Storable>

=head1 AUTHORS

The C<Data::Dump> module is written by Gisle Aas <gisle@aas.no>, based
on C<Data::Dumper> by Gurusamy Sarathy <gsar@umich.edu>.

 Copyright 1998-1999 Gisle Aas.
 Copyright 1996-1998 Gurusamy Sarathy.

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
