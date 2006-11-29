#$Id: Container.pm,v 1.4 2006/10/27 08:59:08 zag Exp $

package HTML::WebDAO::Container;
use HTML::WebDAO::Base;
use Data::Dumper;
use base qw(HTML::WebDAO::Element);
@Desc = ( "ucontainer", "", "Container element" );
use strict 'vars';

#no strict 'refs';
__PACKAGE__->attributes qw/ __childs/;

sub _sysinit {
    my $self = shift;

    #First invoke parent _init;
    $self->SUPER::_sysinit(@_);

    #initalize "childs" array for this container
    $self->__childs( [] );

}

sub _get_vars {
    my $self = shift;
    my ( $res, $ref );
    $res = $self->SUPER::_get_vars;
#    for my $tmp ( @{ $self->__childs } ) {
#        $ref = $tmp->_get_vars;
#        next unless ( ref($ref) );
#        my $my_name = $tmp->__my_name;
#        for my $key ( keys %{$ref} ) {
#            $res->{$my_name}->{$key} = $ref->{$key};
#        }
#    }
#    _log1 $self Dumper(\$res);
    return $res;
}

sub _set_vars {
    my ( $self, $ref ) = @_;
    my $chld_name;
    $self->SUPER::_set_vars($ref);
#    for my $tmp ( @{ $self->__childs } ) {
#        $chld_name = $tmp->__my_name;
#        $tmp->_set_vars( $ref->{$chld_name} ) if ( exists( $ref->{$chld_name} ) );
#    }
}

=head3 _get_childs()

Return ref to childs array

=cut

sub _get_childs {
    return $_[0]->__childs
}

=head3 _add_childs($object1[, $object2])

Insert set of objects into container

=cut
sub _add_childs {
    my $self = shift;
    my @childs = 
            grep { ref $_ }
            map {
                ref($_) eq 'ARRAY' ? @$_ : $_
            } 
            map {$_->__get_self_refs}
            grep {
            ref($_) && $_->can('__get_self_refs')
            } @_;
    return unless @childs;
    if ($self->__parent) {
            $_->_set_parent($self) for @childs;
            $self->getEngine->__restore_session_attributes(@childs)
    }
    push( @{ $self->__childs }, @childs );
}


#it for container
sub _set_parent {
    my ( $self, $par ) = @_;
    $self->SUPER::_set_parent($par);
    foreach my $ref ( @{ $self->__childs } ) {
        $ref->_set_parent($self);
    }
}

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
            _log4 $self "Cant find obj for name $name";
            return;
        }
      }
}

sub _get_obj_by_name {
    my $self = shift;
    my $name = shift;
    return unless defined $name;
    my $res;
    foreach my $obj ( $self, @{ $self->__childs } ) {
        if ( $obj->_obj_name eq $name ) {
            return $obj;
        }
    }
    return;
}

sub fetch {
    my $self = shift;
    my $sess = shift;
    my @res;
    for my $a ( @{ $self->__childs } ) {
        push( @res, @{ $a->_format($sess) } );
    }
    return \@res;    # unless $sess;

}

sub _destroy {
    my $self = shift;
    my @res;
    for my $a ( @{ $self->__childs } ) {
        $a->_destroy;
    }
    $self->SUPER::_destroy;
}

1;