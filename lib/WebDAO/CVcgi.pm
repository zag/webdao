package WebDAO::CVcgi;
#$Id$

=head1 NAME

WebDAO::CVcgi - CGI controller

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::CVcgi - CGI controller

=cut


use WebDAO::Base;
use CGI;
use Data::Dumper;
use base qw( WebDAO::Base );
use strict;

__PACKAGE__->attributes qw (Cgi_obj);

sub _init {
    my $self = shift;
    my $cgi_obj = shift;
    my $cgi = $cgi_obj || new CGI::;
    Cgi_obj $self  $cgi;
    return 1;
}
sub get_cookie {
    my $self = shift;
    return $self->Cgi_obj->cookie(@_)
}
sub response {
    my $self = shift;
    my $res = shift || return;
#    $self->_log1(Dumper(\$res));
#    my $r = $self->_req;
#    my $headers_out = $r->headers_out;
    my $cgi = $self->Cgi_obj;
    print $cgi->header( map { $_ => $res->{headers}->{$_} } keys %{$res->{headers}} );
#    $r->content_type($res->{type});
    print $res->{data};
}

sub print {
    my $self = shift;
    print @_;
}
=head2 referer

Get current referer

=cut

sub referer {
    my $self = shift;
    my $cgi = $self->Cgi_obj;
    return $cgi->referer
}
#path_info param url header
sub AUTOLOAD { 
    my $self = shift;
    return if $WebDAO::CVcgi::AUTOLOAD =~ /::DESTROY$/;
    ( my $auto_sub ) = $WebDAO::CVcgi::AUTOLOAD =~ /.*::(.*)/;
    return $self->Cgi_obj->$auto_sub(@_)
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
