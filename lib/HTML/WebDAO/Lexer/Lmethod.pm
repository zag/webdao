#$Id: Lmethod.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::Lexer::Lmethod;
use HTML::WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( HTML::WebDAO::Lexer::Lbase );
use strict;
sub get_values {
    my $self = shift;
    my $par = $self->all;
    my @val = @_;
    return ;
}
1;

