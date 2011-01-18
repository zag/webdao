package WebDAO::Container;

#$Id$

=head1 NAME

WebDAO::Container - Group of objects

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Container - Group of objects

=cut

use WebDAO::Element;
use Data::Dumper;
use base qw(WebDAO::Element);
use strict 'vars';

#no strict 'refs';
__PACKAGE__->mk_attr( __post_childs => '', __pre_childs => '', __childs => '' );

sub _sysinit {
    my $self = shift;

    #First invoke parent _init;
    $self->SUPER::_sysinit(@_);

    #init childs
    $self->_clear_childs_();
}

sub _get_vars {
    my $self = shift;
    my ( $res, $ref );
    $res = $self->SUPER::_get_vars;
    return $res;
}

sub _set_vars {
    my ( $self, $ref ) = @_;
    my $chld_name;
    $self->SUPER::_set_vars($ref);
}

=head1 METHODS (chidls)

=head2 _get_childs_()

Return ref to childs array

=cut

sub _get_childs_ {
    my $self = shift;
    return [
        @{ $self->__pre_childs() },
        @{ $self->__childs() },
        @{ $self->__post_childs() }
    ];
}

#deprecated
sub _get_childs {
    my $self = shift;
    _deprecated $self "_get_childs_";
    return $self->_get_childs_;
}

=head3 _add_childs_($object1[, $object2])

Insert set of objects into container

=cut

sub _add_childs_ {
    my $self = shift;
    $self->__add_childs__( 1, @_ );
}

#deprecated
sub _add_childs {
    my $self = shift;
    _deprecated $self "_add_childs_";
    return $self->_add_childs_(@_);
}

=head2 _clear_childs_

Clear all childs (pre, post also)

=cut

sub _clear_childs_ {
    my $self = shift;
    $self->__post_childs( [] );
    $self->__childs(      [] );
    $self->__pre_childs(  [] );
}

=head2 _set_childs_ @childs_set

Clear all childs (except "pre" and "post" objects), and set  to C<@childs_set>

=cut

# 0 - pre, 1 - fetch , 2 - post
sub __set_childs__ {
    my $self = shift;
    my $type = shift;
    my $dst  = $type == 0
      ? $self->__pre_childs    #0
      : $type == 1 ? $self->__childs()        #1
      :              $self->__post_childs;    #2
    for ( @{$dst} ) {
        $_->_destroy;
    }
    $self->__add_childs__( $type, @_ );
}

# 0 - pre, 1 - fetch , 2 - post
sub __add_childs__ {
    my $self = shift;
    my $type = shift;
    my $dst  = $type == 0
      ? $self->__pre_childs                   #0
      : $type == 1 ? $self->__childs()        #1
      :              $self->__post_childs;    #2
    my @childs =
      grep { ref $_ }
      map { ref($_) eq 'ARRAY' ? @$_ : $_ }
      map { $_->__get_self_refs }
      grep { ref($_) && $_->can('__get_self_refs') }
      map { ref($_) eq 'ARRAY' ? @$_ : $_ } @_;
    return unless @childs;
    if ( $self->__parent ) {
        $_->_set_parent($self) for @childs;
        $self->getEngine->__restore_session_attributes(@childs);
    }
    push( @{$dst}, @childs );
}

sub _set_childs_ {
    my $self = shift;

    #first destoroy
    for ( @{ $self->__childs() } ) {
        $_->_destroy;
    }
    $self->__childs( [] );
    $self->_add_childs_(@_);
}

=head1 OUTPUT_METHODS

=head2 pre_fetch ($session)

Output data precede to fetch method. By default output "pre" objects;

=cut

sub pre_fetch {
    my $self = shift;
    @{ $self->__pre_childs };
}

=head2 post_fetch ($session)

Output data follow to fetch method. By default output "post" objects;

=cut

sub post_fetch {
    my $self = shift;
    @{ $self->__post_childs };
}

=head1 OTHER
=cut

#it for container
sub _set_parent {
    my ( $self, $par ) = @_;
    $self->SUPER::_set_parent($par);
    foreach my $ref ( @{ $self->_get_childs_ } ) {
        $ref->_set_parent($self);
    }
}

sub __any_path {
    my $self = shift;
    my $sess = shift;
    my ( $method, @path ) = @_;
    my ( $res, @path ) = $self->SUPER::__any_path( $sess, @_ );
    return undef unless defined($res);
    if ( ref($res) eq 'ARRAY' ) {

        #make container
        my $cont = $self->__engine->_create_( $method, __PACKAGE__ );
        $cont->_set_childs_(@$res);
        $res = [$cont];
        unshift( @path, $method );
    }
    return ( $res, @path );
}

#Return (  object witch handle req and result )
sub _traverse_ {
    my $self = shift;
    my $sess = shift;

    #if empty path return $self
    unless ( scalar(@_) ) { return ( $self, $self ) }

    #extra path need only then seek object
    #no __extra_path if resolve

=pod
    #first check if exists
    #strip extra path from urls
    if ( my $epath = $self->__extra_path ) {

        # not found if extra path greater when @path
        #hint: /elem (extra_path 2010/123) and path only "2010"
        return undef if ( scalar(@$epath) > scalar(@_) );

        #check if extra eq
        my $not_eq = 0;
        my $pos    = 0;
        for (@$epath) {
            next if $_[ $pos++ ] eq $_;
            $not_eq++;
            last;
        }
        #check if ok with extra path
        return undef if $not_eq;    # not found
        #cut extra path from path
        splice @_, 0, scalar(@$epath);
        #if empty path return $self
        unless ( scalar(@_) ) { return $self }
    }
=cut

    my ( $next_name, @path ) = @_;

    #check if exist object with some name
    if ( my $obj = $self->_get_obj_by_name($next_name) ) {

        #if last in path return him
        return $obj->_traverse_( $sess, @path );

    }
    else {    #try get other ways

        #try get objects by special methods
        my ( $res, $last_path ) = $self->__any_path( $sess, $next_name, @path );
        return ( $self, undef ) unless defined $res;    #break search
        if ( UNIVERSAL::isa( $res, 'WebDAO::Response' ) ) {
            return ( $self, $res );
        }
        elsif ( ref($res) eq 'ARRAY' ) {

            #for objects array attach them into collection
            $self->_set_childs_(@$res);

            #return ref to container if array to self
            $res = $self;
        }

        #analyze $last_path
        my @rest_path = ();
        if ($last_path) {
            if ( ref($last_path) eq 'ARRAY' ) {
                @rest_path = @$last_path;
            }
        }
        if (@rest_path) {
            return $self->_traverse_( $sess, @rest_path );
        }

        #unknown $res
        # <WebDAO::Element>, may be HASH ref, STRING
        return ( $self, $res );
    }

}

#deprecated
sub _call_method {
    my $self = shift;
    my ( $name, @path ) = @{ shift @_ };
    return $self->SUPER::_call_method( [ $name, @path ], @_ ) || do {
        if ( my $obj = $self->_get_obj_by_name($name) ) {
            if ( ref($obj) eq 'HASH' ) {
                LOG $self Dumper( [ map { [ caller($_) ] } ( 1 .. 6 ) ] );
                $self->LOG( " got $obj for $name" . Dumper($obj) );
            }
            $obj->_call_method( \@path, @_ );
        }
        else {
            _log4 $self "Cant find obj for name $name in "
              . $self->__my_name() . ":"
              . Dumper( [ map { $_->__my_name } @{ $self->_get_childs } ] );
            return;
        }
      }
}

sub _get_obj_by_name {
    my $self = shift;
    my $name = shift;
    return unless defined $name;
    my $res;
    foreach my $obj ( $self, @{ $self->_get_childs_ } ) {
        if ( $obj->_obj_name eq $name ) {
            return $obj;
        }
    }
    return;
}

=head2 fetch(@_), default call by webdao: fetch( $session )

Interate call fetch(@_) on childs

=cut

#deprecated
sub fetch {
    my $self = shift;
    my @res;
    for my $a ( @{ $self->_get_childs } ) {
        push( @res, @{ $a->_format(@_) } );
    }
    return \@res;

}

sub _destroy {
    my $self = shift;
    my @res;
    for my $a ( @{ $self->_get_childs_ } ) {
        $a->_destroy;
    }
    $self->_clear_childs_();
    $self->SUPER::_destroy;
}

=head2 _get_object_by_path <$path>, [$session]

Return first Element object for path.
Try to load objects for current object.

=cut

#deprecated
sub _get_object_by_path {
    my $self    = shift;
    my $path    = shift;
    my $session = shift;

    #    _log1 $self Dumper {'$self'=>ref($self), path=>$path};
    my @backup_path = @$path;
    my $next_name   = $path->[0];

    #first try get by name
    if ( my $obj = $self->_get_obj_by_name($next_name) ) {
        shift @$path;    #skip first name
                         #ok got it
                         #check if it container
                         #skip extra path
        if ( UNIVERSAL::can( $obj, '__extra_path' ) ) {
            my $extra_path = $obj->__extra_path;

            #if extra path defined and not ref convert to ref
            if ( defined $extra_path ) {
                $extra_path = [$extra_path] unless ref($extra_path);
            }
            if ( ref($extra_path) ) {
                my @extra = @$extra_path;

                #now skip extra
                for (@extra) {
                    if ( $path->[0] eq $_ ) {
                        shift @$path;
                    }
                    else {
                        _log2 $self "Break __extra_path "
                          . $path->[0] . " <> "
                          . $_
                          . " for : $obj";
                        last;
                    }
                }
            }
        }
        if ( $obj->isa('WebDAO::Container') ) {
            return $obj unless @$path;    # return object if end of path
            return $obj->_get_object_by_path( $path, $session );
        }
        else {

            #if element return point in any way
            return $obj;
        }
    }
    else {

        #try get objects by special methods
        my $dyn = $self->__get_objects_by_path( $path, $session )
          || return;    #break search

        #handle self controlled objects
        if ( $dyn eq $self ) {
            return $self;
        }
        $dyn = [$dyn] unless ref($dyn) eq 'ARRAY';

        #now try find object in returned array
        my $next;
        foreach (@$dyn) {

            #skip non objects
            next unless $_->_obj_name eq $next_name;
            $next = $_;
            last;    #exit from loop loop
        }
        unless ($next) {
            return    # return undef unless find objects
        }
        else {

            # yes, from returned object present traverse continue
            #if defined $session ( load scene)
            if ($session) {
                $self->_add_childs(@$dyn);
                return $self->_get_object_by_path( $path, $session );
            }
            else {

                #if query without session
                #try to find  by name
                #ok got it
                #check if it container
                if ( $next->isa('WebDAO::Container') ) {
                    return $next->_get_object_by_path( $path, $session );
                }
                else {

                    #return object referense in any way
                    return $next;
                }
            }

        }
    }
}

=head2 __get_objects_by_path [path], $session

Return next object for path 

=cut

#deprecateed
sub __get_objects_by_path {
    my $self = shift;
    my ( $path, $session ) = @_;

    # check if path point to method
    return $self if $self->can( $path->[0] );
    return;    # default return undef
}

1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

