#$Id$

package HTML::WebDAO::CVcgi;
use HTML::WebDAO::Base;
use CGI;
use Data::Dumper;
use base qw( HTML::WebDAO::Base );
use strict;
#__PACKAGE__->
attributes qw (Cgi_obj);

sub _init {
    my $self = shift;
    my $cgi = new CGI::;
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
    return if $HTML::WebDAO::CVcgi::AUTOLOAD =~ /::DESTROY$/;
    ( my $auto_sub ) = $HTML::WebDAO::CVcgi::AUTOLOAD =~ /.*::(.*)/;
    return $self->Cgi_obj->$auto_sub(@_)
}
1;
