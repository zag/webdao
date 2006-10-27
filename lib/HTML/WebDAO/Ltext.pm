#$Id: Ltext.pm,v 1.2 2006/09/19 10:05:25 zag Exp $

package HTML::WebDAO::Ltext;
use HTML::WebDAO::Base;
use HTML::WebDAO::Lbase;
use Data::Dumper;
use CGI;
use base qw( HTML::WebDAO::Lbase );
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
