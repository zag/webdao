package WebDAO::Component;
#$Id$

=head1 NAME

WebDAO::Component - Component class

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Component - Component class

=head1 METHODS

=cut

use WebDAO::Base;
use base qw(WebDAO::Element);
use strict 'vars';
use Data::Dumper;


sub url_method {
    my $self   = shift;
    my $method = shift;
    my @upath  = ();
    push @upath, $self->__path2me if $self->__path2me;
    push @upath, $method if defined $method;
    my $sess = $self->_root_->_session;
    if ( $sess->set_absolute_url() ) {
        my $root = $sess->Cgi_env->{base_url};
        unshift @upath, $sess->Cgi_env->{base_url};
    }
    #hack !!! clear / on begin
    #s{^/}{} for @upath;
    my $path = join '/' => @upath;
    my $str = '';
    if (@_) {
        my %args = @_;
        my @pars;
        while ( my ( $key, $val ) = each %args ) {
            push @pars, "$key=$val";
        }
        $str .= "?" . join "&" => @pars;
    }
    return $path . $str;
}

=head2 response

Return response object

    return $self->response->error404('Bad name')

=cut

sub response {
    my $self = shift;
    return $self->_root_->response;
}

=head2 request

Return request object

    $self->request->param('id')

=cut

sub request {
    return $_[0]->response->get_request();
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

