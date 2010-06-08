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

=head1 NAME

Data::Dump::Filtered - Pretty printing with filtering

=head1 DESCRIPTION

The following functions are provided:

=over

=item add_filter( \&filter )

This registers a filter function to be used by the regular Data::Dump::dump()
function.  By default no filters are active.

Since registering filters has a global effect is might be more appropriate
to use the dump_filtered() function instead.

=item remove_filter( \&filter )

Unregister the given callback function as filter callback.
This undos the effect of L<add_filter>.

=item dump_filtered(...., \&filter )

Works like Data::Dump::dump(), but the last argument should
be a filter callback function.  As objects are visisted the
filter callback is invoked at it might influence how objects are dumped.

Any filters registered with L<add_filter()> are ignored when
this interface is invoked.

=back

=head2 Filter callback

A filter callback is a function that will be invoked with 2 arguments;
a context object and reference to the object currently visited.

    sub filter_callback {
        my($ctx, $object) = @_;

The context object provide methods that can be used to determine what kind of
object is currently visited and where it's located.  The context object has the
following interface:

=over

=item $ctx->object

Alternative way to obtain a reference to the current object

=item $ctx->class

If the object is blessed this return the class.  Returns ""
for objects not blessed.

=item $ctx->reftype

Returns what kind of object this is.  It's a string like "SCALAR",
"ARRAY", "HASH", "CODE",...

=item $ctx->is_ref

Returns true if a reference was provided.

=item $ctx->container_class

Returns the class of the innnermost container that contains this object.
Returns "" if there is no blessed container.

=item $ctx->container_self

Returns an textual expression relative to the container object that names this
object.  The variable C<$self> in this expresion is the container itself.

=item $ctx->object_isa( $class )

Returns TRUE if the current object is of the given class or is of a subclass.

=item $ctx->container_isa( $class )

Returns TRUE if the innermost container is of the given class or is of a
subclass.

=back

The callback return value determine how the visited object is dumped.  If
C<undef> is returned, then the object is dumped in the default way.  Otherwise
the return value should be a hash reference with the following elements:


The following elements can be used in the hash:

replace_with => $value

    dump the given value instead of the one passed in as $rval

use_repr => $string

    incorporate the given string as the representation for the
    current value

comment => $comment

    prefix the value with the given comment string

replace_class => $class

    make it look as if the current object is of the given $class
    instead of the class it really has.  The internals of the object
    is dumped in the regular way.  The $class can be them empty string
    to make Data::Dump pretend the object wasn't blessed at all.

hide_keys => ['key1', 'key2',...]
hide_keys => \&code

    If the $rval is a hash dump is as normal but pretend that the
    listed keys did not exist.  If the argument is a funciton then
    the function is called to determine if the given key should be
    hidden.

=head1 SEE ALSO

L<Data::Dump>
