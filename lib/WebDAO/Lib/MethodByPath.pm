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
__PACKAGE__->mk_attr( _path=>undef, _args=>undef);

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
    my @path   = @{ $sess->call_path( $self->_path ) };
    my ( $src, $res ) = $self->getEngine->_traverse_( $sess, @path );
    return $res;
}

1;
__DATA__

=head1 SEE ALSO

http://sourceforge.net/projects/webdao

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

