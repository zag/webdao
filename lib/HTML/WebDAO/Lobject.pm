#$Id: Lobject.pm,v 1.4 2006/09/19 10:05:25 zag Exp $

package HTML::WebDAO::Lobject;
use HTML::WebDAO::Base;
use HTML::WebDAO::Lbase;
use Data::Dumper;
use CGI;
use base qw( HTML::WebDAO::Lbase );
use strict;

sub value {
    my $self = shift;
    my $eng = shift;
    my $par = $self->all;
    my @val = map { $_->value($eng) } @{ $self->childs } ;
    if ( $eng ) {
        my $object =  $eng->_createObj($par->{id},$par->{class}, @val);
        _log1 $self "create_obj fail for class: ".$par->{class}." ,id: ".$par->{id} unless $object;
#        _log3 $self "return object  $object for class: ".$par->{class}." from ".Dumper($par) if  $object;

    return $object
    }
    return {"Object ( ".( join ",",map {"$_ => ".$par->{$_}}  keys %{$par}).")"=>\@val}
}
1;

