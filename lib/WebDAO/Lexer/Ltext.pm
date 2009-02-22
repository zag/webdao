package WebDAO::Lexer::Ltext;
#$Id$

=head1 NAME

WebDAO::Lexer::Ltext - Class used by lexer 

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Lexer::Ltext - Class used by lexer 

=cut

use WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( WebDAO::Lexer::Lbase );
use strict;

sub Init {
    my $self = shift;
    my %args = @_;
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
