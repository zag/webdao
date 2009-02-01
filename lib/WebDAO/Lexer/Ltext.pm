#$Id$

package WebDAO::Lexer::Ltext;
use WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( WebDAO::Lexer::Lbase );
use strict;
sub Init {
    my $self = shift;
    my $res = $self->SUPER::Init(@_);
    my $par = $self->all;
    return if $par->{value}=~/^\s+$/gis;
    $res
}
    
sub value {
    my $self = shift;
    my $par = $self->all;
   $par->{value}
}
1;
