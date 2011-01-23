package WebDAO::Element;
#$Id$

=head1 NAME

WebDAO::Element - Base class for simple object

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Element - Base class for simple object

=cut

use Data::Dumper;
use WebDAO::Base;
use base qw/ WebDAO::Base/;
use strict 'vars';
__PACKAGE__->attributes
  qw/ _format_subs __attribute_names __my_name __parent __path2me  __engine  __extra_path /; #deprecated  _format_subs


=head1 NAME

WebDAO::Element - WebDAO::Element.

=head1 SYNOPSIS


=cut

sub _init {
    my $self = shift;
    $self->_sysinit( \@_ );    #For system internal inherites
    $self->init(@_);           # if (@_);
    return 1;
}

sub RegEvent {
    my $self    = shift;
    my $ref_eng = $self->getEngine;
    $ref_eng->RegEvent( $self, @_ );
}

#
sub _sysinit {
    my $self = shift;

    #get init hash reference
    my $ref_init_hash = shift( @{ $_[0] } );

    #_engine - reference to engine
    $self->__engine( $ref_init_hash->{ref_engine} );

    #_my_name - name of this object
    $self->__my_name( $ref_init_hash->{name_obj} );

    #init hash of attribute_names
    my $ref_names_hash = {};
    map { $ref_names_hash->{$_} = 1 } $self->get_attribute_names();

    #        _attribute_names $self $ref_names_hash;
    $self->__attribute_names($ref_names_hash);

}

sub init {

    #Public Init metod for modules;
}

sub _get_vars {
    my $self = shift;
    my $res;
    for my $key ( keys %{ $self->__attribute_names } ) {
        my $val = $self->get_attribute($key);
        no strict 'vars';
        $res->{$key} = $val if ( defined($val) );
        use strict 'vars';
    }
    return $res;
}

=head2 _get_childs_()

Return ref to childs array

=cut
sub _get_childs_ {
    return [];
}

sub _get_childs {
     $_[0]->_deprecated( "_get_childs_");
    return [];
}

=head2  __any_path ($session, @path)

Call for unresolved path.

Return:

    ($resuilt, \@rest_of_the_path)

=cut

sub __any_path {
    my $self = shift;
    my $sess = shift;
    my ( $method, @path ) = @_;
    #first check if Method
    #Check upper case First letter for method
    if ( ucfirst($method) ne $method ) {

        #warn  "Deny method : $method";
        return;    #not found
    }

    #check if $self have method
    if ( UNIVERSAL::can( $self, $method ) ) {

        #now try call method
        #Ok have method
        #check if path have more elements
        my %args = %{ $sess->Params };
        if (@path) {

            #add  special variable
            $args{__extra_path__} = \@path;
        }

        #call method (only one param may be return)
        my ($res, @path1) = $self->$method(%args);
        if ( scalar(@path1) ) {
            #method may return extra path
            return $res, \@path1;
        }
        return $res, \@path;
    }
    undef;

}

#return
#  undef  = not found
#  [ array of object]
#   <$self|| WebDAO::Element> ( ? for isert to parent container ?)
#  "STRING"
#   <WebDAO::Response>
sub _traverse_ {
    my $self = shift;
    my $sess = shift;

    #if empty path return $self
    unless ( scalar(@_) ) { return ( $self, $self ) }
    my ( $next_name, @path ) = @_;

    #try get objects by special methods
    my ( $res, $last_path ) = $self->__any_path( $sess, $next_name, @path );
    return ( $self, undef ) unless defined $res;    #break search
    return ( $self, $res );
}


#deprecated
sub call_path {
    my $self = shift;
    my $path = shift;
    $path = [ grep { $_ } split( /\//, $path ) ];
    return $self->getEngine->_call_method( $path, @_ );
}

#deprecated
sub _call_method {
    my $self = shift;
    my ( $method, @path ) = @{ shift @_ };
    if ( scalar @path ) {

        #_log4 $self "Extra path @path $self";
        return;
    }
    unless ( $self->can($method) ) {
        _log4 $self $self->_obj_name . ": don't have method $method";
        return;
    }
    else {
        $self->$method(@_);
    }
}

sub __get_self_refs {
    return $_[0];
}

sub _set_parent {
    my ( $self, $parent ) = @_;
    $self->__parent($parent);
    $self->_set_path2me();
}

sub _set_path2me {
    my $self   = shift;
    my $parent = $self->__parent;
    if ( $self != $parent ) {
        ( my $parents_path = $parent->__path2me ) ||= "";
        my $extr = $parent->__extra_path;
        $extr = [] unless defined $extr;
        $extr = [$extr] unless ( ref($extr) eq 'ARRAY' );
        my $my_path = join "/", $parents_path, @$extr, $self->__my_name;
        $self->__path2me($my_path);
    }
    else {
        $self->__path2me('');
    }
}

#deprecated -> $obj->__name
sub _obj_name {
    return $_[0]->__my_name;
}

#deprecated  -> self->__engine

sub getEngine {
    my $self = shift;
    return $self->__engine;
}

sub SendEvent {
    my $self   = shift;
    my $parent = __parent $self;
    $self->_log1( "Not def parent $self name:"
          . ( $self->__my_name )
          . Dumper( \@_ )
          . Dumper( [ map { [ caller($_) ] } ( 1 .. 10 ) ] ) )
      unless $parent;
    $parent->SendEvent(@_);
}

#deprecated
sub pre_format {
    my $self = shift;
    return [];
}


#deprecated
sub _format {
    my $self = shift;
    my @res;
    push( @res, @{ $self->pre_format(@_) } );    #for compat
    if ( my $result = $self->fetch(@_) ) {
        push @res, ( ref($result) eq 'ARRAY' ? @{$result} : $result );
    }
    push( @res, @{ $self->post_format(@_) } );    #for compat

    \@res;
}

#deprecated
sub format {
    my $self = shift;
    return shift;
}

#deprecated
sub post_format {
    my $self = shift;
    return [];
}

sub fetch { undef } #return undef

sub _destroy {
    my $self = shift;
    $self->__parent(undef);
    $self->__engine(undef);
    $self->_format_subs(undef); ##deprecated
}

sub _set_vars {
    my ( $self, $ref, $names ) = @_;
    $names = $self->__attribute_names;
    for my $key ( keys %{$ref} ) {
        if ( exists( $names->{$key} ) ) {
            $self ->${key}( $ref->{$key} );
        }
        else {

            # Uknown attribute ???

        }
    }
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

