package WebDAO::Lib::MethodByPath;
#$Id$

=head1 NAME

WebDAO::Lib::MethodByPath - Component for method tag

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Lib::MethodByPath - Component for method tag

=cut

use WebDAO::Base;
use Data::Dumper;
use base qw(WebDAO::Component);
__PACKAGE__->attributes qw( _path _args );

sub init {
    my $self = shift;
    my ( $path, @args ) = @_;
    $self->_path($path);
    $self->_args( \@args );
    1;
}

sub fetch {
    my $self = shift;
    my $sess = shift;

    #first get object;
    my @path   = @{ $sess->call_path( $self->_path ) };
    my $method = pop @path;

    #try get object by path
    if ( my $object = $self->getEngine->_get_object_by_path( \@path ) ) {
        unless ($method) {
            _log1 $self "Method not found by path " . $self->_path;
            return;
        }
        else {

            #check and call method
            if ( UNIVERSAL::can( $object, $method ) ) {
                return $object->$method( @{ $self->_args } );
            }
            else {
                _log1 $self "Method: $method not found at class $object";
                return;
            }
        }

    }
    else {
        _log1 $self "ERRR: Not found object for path " . $self->_path;
    }
    return undef;
}

1;
__DATA__

=head1 SEE ALSO

http://sourceforge.net/projects/webdao

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

