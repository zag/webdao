#$Id: Component.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::Component;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Element);
use strict 'vars';
use Data::Dumper;

sub url_method {
    my $self   = shift;
    my $method = shift;
    my $ref;
    $ref->{path} = join '/' => $self->__path2me, $method;
    my %args = @_;
    $ref->{pars} = \%args if @_;
    my $res;
    $self->SendEvent(
        "_sess_servise",
        {
            funct  => 'geturl',
            par    => $ref,
            result => \$res
        }
    );
    return $res;

}
1;
