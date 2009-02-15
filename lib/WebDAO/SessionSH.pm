#$Id$

package WebDAO::SessionSH;
use strict;
use warnings;
use WebDAO::Base;
use WebDAO::Session;
use Data::Dumper;
use base qw( WebDAO::Session );

#Need to be forever called from over classes;
sub Init {
    my $self = shift;
    my %args = @_;
    $self->SUPER::Init(@_);
    delete $args{store};
    $self->U_id( rand(100) );
    Params $self ( \%args );
}

sub print_header() {
    return ''
}

sub sess_servise {
    my $self= shift;
    return $self->SUPER::sess_servise(@_)

}

sub ExecEngine() {
    my ( $self, $eng_ref ) = @_;
    $eng_ref->RegEvent( $self, "_sess_servise", \&sess_servise );
}

1;
