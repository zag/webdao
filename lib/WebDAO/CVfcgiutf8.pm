package WebDAO::CVfcgiutf8;
#$Id$

=head1 NAME

WebDAO::CVfcgiutf8 - Fix output utf8 encoding (FCGI > 0.68)

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::CVfcgiutf8 - Fix output utf8 encoding for FCGI version > 0.68

=cut


use WebDAO::CVcgi;
use base qw( WebDAO::CVcgi );
use strict;

sub print {
    my $self = shift;
    foreach my $str (@_) {
        utf8::encode( $str) if utf8::is_utf8($str);
        print $str;
   }
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
