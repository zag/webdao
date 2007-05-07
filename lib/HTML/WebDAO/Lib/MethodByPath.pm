#$Id: RawHTML.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::Lib::MethodByPath;
use HTML::WebDAO::Base;
use Data::Dumper;
use base qw(HTML::WebDAO::Component);
__PACKAGE__->attributes qw( _path _args );

sub init {
    my $self = shift;
    my ( $path, @args ) = @_;
    $self->_path($path);
    $self->_args(\@args);
    1;
}

sub fetch {
    my $self = shift;
    return  $self->call_path($self->_path, @{$self->_args})
}

1;
