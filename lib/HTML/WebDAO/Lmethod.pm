#$Id: Lmethod.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::Lmethod;
use HTML::WebDAO::Base;
use HTML::WebDAO::Lbase;
use Data::Dumper;
use CGI;
use base qw( HTML::WebDAO::Lbase );
use strict;
sub get_values {
    my $self = shift;
    my $par = $self->all;
    my @val = @_;
#    print 'get_values:'.ref($self).Dumper(\@val).Dumper($par);
    return ;
#    my %hashed = map {%$_} @{$par};
#    if (my $eng = $self->engine) {
#    return $eng->_createObj($par->{id},$par->{class},@val)
#    }
#    return {"Object ( ".( join ",",map {"$_ => ".$par->{$_}}  keys %{$par}).")"=>\@val}
#    return {object=>[init=>$par,val=>\@val]}
}
1;

