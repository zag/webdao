package WebDAO::Lexer::text;
use base 'WebDAO::Lexer::base';
use strict;
=head1 NAME

WebDAO::Lexer::text - Class used by lexer 

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Lexer::text - Class used by lexer 

=cut

sub value {
    my $self = shift;
    return  $self->{value} ;
}
1;
__DATA__

=head1 SEE ALSO

http://sourceforge.net/projects/webdao

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

