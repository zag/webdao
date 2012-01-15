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
__PACKAGE__->mk_attr( Cgi_obj => undef, _headers => undef );

sub _init {
    my $self    = shift;
    my $cgi_obj = shift;
    my $cgi     = $cgi_obj || new CGI::;
    Cgi_obj $self $cgi;
    $self->_headers({});
    return 1;
}

sub get_cookie {
    my $self = shift;
    return $self->Cgi_obj->cookie(@_);
}

=head2 set_cookie

    $sess->Cgi_obj->set_cookie(         {
            -NAME    => "id",
            -EXPIRES => "+3M",
            -PATH    => "/",
            -VALUE   => "2"
        }

=cut

sub set_cookie {
    my $self = shift;
    $self->set_header( "-COOKIE", $self->Cgi_obj->cookie(@_) );
}

sub set_header {
    my ( $self, $name, $par ) = @_;
    $name = uc $name;

    #collect -cookies
    if ( $name eq '-COOKIE' ) {
        push @{ $self->_headers->{$name} }, $par;
    }
    else {
        $self->_headers->{$name} = $par;
    }
}

sub response {
    my $self        = shift;
    my $res         = shift || return;
    my $cgi         = $self->Cgi_obj;
    my %out_headers = %{ $self->_headers };
    if ( $res->{headers} ) {
        while ( my ($key, $val) = each %{ $res->{headers} } ) {
            # aggregate cookies   
            if ( $key eq '-COOKIE' ) {
                push @{ $out_headers{$key} }, $val;
            }
            else {
                $out_headers{$key} = $val;
            }

        }
    }
    $self->print( $cgi->header(%out_headers) );
    $self->print( $res->{data} );
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
    my $cgi  = $self->Cgi_obj;
    return $cgi->referer;
}

#path_info param url header
sub AUTOLOAD {
    my $self = shift;
    return if $WebDAO::CVcgi::AUTOLOAD =~ /::DESTROY$/;
    ( my $auto_sub ) = $WebDAO::CVcgi::AUTOLOAD =~ /.*::(.*)/;
#    warn Dumper([caller()]);
    return $self->Cgi_obj->$auto_sub(@_);
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
