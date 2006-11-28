#$Id: SessionSH.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::SessionSH;
use HTML::WebDAO::Base;
use HTML::WebDAO::Session;
use Data::Dumper;
use base qw( HTML::WebDAO::Session );

#Need to be forever called from over classes;
sub Init {
    $self = shift;
    %args = @_;
    $self->SUPER::Init(@_);
    Params $self ( \%args );
}

#Can be overlap if you choose another
#alghoritm generate unique session ID (i.e cookie,http_auth)
sub ___get_id {
    die "aaa";
    return rand(100);
}

sub print_header() {
    return ''
}

sub ExecEngine() {
    my ( $self, $eng_ref ) = @_;

    #print $self->print_header();
#    $eng_ref->Work($self);

    #print @{$eng_ref->Fetch()};
#    $self->store_session($eng_ref);
#    $eng_ref->_destroy;
}

1;
