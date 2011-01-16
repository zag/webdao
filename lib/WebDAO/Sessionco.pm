package WebDAO::Sessionco;
#$Id$

=head1 NAME

WebDAO::Sessionco - Session with store session id in cookie

=head1 DESCRIPTION

WebDAO::Sessionco - Session with store session id in cookie

=cut

use WebDAO::Base;
use CGI;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);

use base qw( WebDAO::Session );

use strict 'vars';
__PACKAGE__->attributes qw( Cookie_name Db_file );

sub Init {

    #Parametrs is realm => [string] - for http auth
    #		id =>[string] - name of cookie
    #		db_file => [string] - path and filename
    #
    my ( $self, %param ) = @_;
    my $id = $param{id} || "stored";
    Cookie_name $self (
        {
            -NAME    => "$id",
            -EXPIRES => "+3M",
            -PATH    => "/",
            -VALUE   => "0"
        }
    );
    $self->SUPER::Init(%param);
}

sub get_id {
    my $self = shift;
    my $coo  = U_id $self;
    return $coo if ($coo);
    my $_cgi = $self->Cgi_obj();
    $coo = $_cgi->get_cookie( ( $self->Cookie_name() )->{-NAME} );
    unless ($coo) {
        $coo = md5_hex(time ^ $$, rand(999)) ;
        U_id $self ( $coo );
    }
    $self->Cookie_name()->{-VALUE} = $coo;
    $_cgi->set_cookie($self->Cookie_name() );
    return $coo;
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

