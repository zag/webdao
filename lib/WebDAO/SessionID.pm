package WebDAO::SessionID;
#$Id$

=head1 NAME

WebDAO::SessionID - Session with session id in URL

=head1 DESCRIPTION

WebDAO::SessionID - Session with session id in URL

=cut


use WebDAO::Base;
use CGI;
use Data::Dumper;
use MIME::Base64;
use base qw( WebDAO::Sessionco);

use strict 'vars';

sub sess_servise_geturl{
    my $self = shift;
    my $str = $self->SUPER::sess_servise_geturl(@_);
    return "/sess_".$self->get_id.$str
}

sub get_id {
my $self=shift;
my $coo=U_id $self;
return $coo if ($coo);
($coo)=$self->Cgi_env->{path_info}=~m/sess_(\d{7})/;
$self->Cgi_env->{path_info}=~s/sess_(\d{7})//;
$coo ||= do {
	my $tmp=substr(time(),-7,7);
#	$self->Cgi_env->{path_info}.="sess_$tmp/";
	$tmp
	};
U_id $self $coo;
return $coo;
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

