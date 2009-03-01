package WebDAO::Session;
#$Id$

=head1 NAME

WebDAO::Session - Session interface to protocol specific function

=head1 DESCRIPTION

Session interface to device(HTTP protocol) specific function

=cut


use WebDAO::Base;
use WebDAO::CVcgi;
use WebDAO::Store::Abstract;
use WebDAO::Response;
use Data::Dumper;
use base qw( WebDAO::Base );
use Encode qw(encode decode is_utf8);
use strict;
__PACKAGE__->attributes
  qw( Cgi_obj Cgi_env U_id Header Params  _store_obj _response_obj _is_absolute_url);

sub _init() {
    my $self = shift;
    $self->Init(@_);
    return 1;
}

#Need to be forever called from over classes;
sub Init {

    #Parametrs is realm
    my $self = shift;
    my %args = @_;
    Header $self ( {} );
    U_id $self undef;
    Cgi_obj $self $args{cv}
      || new WebDAO::CVcgi::;    #create default controller
    my $cv = $self->Cgi_obj;           # Store Cgi_obj in local var
                                       #create response object
    $self->_response_obj(
        new WebDAO::Response::
          session => $self,
        cv => $cv
    );
    _store_obj $self ( $args{store} || new WebDAO::Store::Abstract:: );

    #workaround for CGI.pm: http://rt.cpan.org/Ticket/Display.html?id=36435
    my %accept = ();
    if ( $cv->http('accept') ) {
        %accept = map { $_ => $cv->Accept($_) } $cv->Accept();
    }
    Cgi_env $self (
        {
            url => $cv->url( -base => 1 ),    #http://eng.zag
            path_info         => $cv->url( -absolute => 1, -path_info => 1 ),
            path_info_elments => [],
            file              => "",
            base_url     => $cv->url( -base => 1 ),    #http://base.com
            query_string => $cv->query_string,
            referer      => $cv->referer(),
            accept       => \%accept
        }
    );

    #fix CGI.pm bug http://rt.cpan.org/Ticket/Display.html?id=25908
    $self->Cgi_env->{path_info} =~ s/\?.*//s;
    $self->get_id;
    Params $self ( $self->_get_params() );
    $self->Cgi_env->{path_info_elments} =
      [ grep { defined $_ } split( /\//, $self->Cgi_env->{path_info} ) ];

}

#Can be overlap if you choose another
#alghoritm generate unique session ID (i.e cookie,http_auth)
sub get_id {
    my $self = shift;
    my $coo  = U_id $self;
    return $coo if ($coo);
    return rand(100);
}

=head2 call_path [$url]

Return ref to array of element from $url or from CGI ENV

=cut

sub call_path {
    my $self = shift;
    my $url = shift || return $self->Cgi_env->{path_info_elments};
    $url =~ s%^/%%;
    $url =~ s%/$%%;
    return [ grep { defined $_ } split( /\//, $url ) ];

}

=head2  set_absolute_url 1|0

Set flag for build absolute pathes. Return previus value.

=cut

sub set_absolute_url {
    my $self       = shift;
    my $value      = shift;
    my $prev_value = $self->_is_absolute_url;
    $self->_is_absolute_url($value) if defined $value;
    return $prev_value;
}

sub _load_attributes_by_path {
    my $self = shift;
    $self->_store_obj->_load_attributes( $self->get_id(), @_ );
}

sub _store_attributes_by_path {
    my $self = shift;
    $self->_store_obj->_store_attributes( $self->get_id(), @_ );
}

sub flush_session {
    my $self = shift;
    $self->_store_obj->flush( $self->get_id() );
}

sub response_obj {
    my $self = shift;
    return $self->_response_obj;
}

#Session interface to device(HTTP protocol) specific function
#$self->SendEvent("_sess_servise",{
#		funct 	=> geturl,
#		par	=> $ref,
#		result	=> \$res
#});

sub sess_servise {
    my ( $self, $event_name, $par ) = @_;
    my %service = (
        getsess => sub { return $self },
    );
    if ( exists( $service{ $par->{funct} } ) ) {
        ${ $par->{result} } = $service{ $par->{funct} }->( $par->{par} );
    }
    else {
        logmsgs $self "not exist request funct !" . $par->{funct};
    }
}

sub response {
    my $self = shift;
    my $res  = shift;

    #    unless $res->type
    return if $res->{cleared};
    my $headers = $self->Header();
    $headers->{-TYPE} = $res->{type} if $res->{type};
    while ( my ( $key, $val ) = each %$headers ) {
        my $UKey = uc $key;
        $res->{headers}->{$UKey} = $headers->{$UKey}
          unless exists $res->{headers}->{$UKey};
    }

    #    $res->{headers} = $headers;
    $self->Cgi_obj->response($res);
}

sub print {
    my $self = shift;
    $self->Cgi_obj->print(@_);
}

sub ExecEngine() {
    my ( $self, $eng_ref ) = @_;

    #print $self->print_header();
    $eng_ref->RegEvent( $self, "_sess_servise", \&sess_servise );
    $eng_ref->execute($self);
    $eng_ref->SendEvent("_sess_ended");

    #print @{$eng_ref->Fetch()};
    $eng_ref->_destroy;
    $self->flush_session();

}

#for setup Output headers
sub set_header {
    my $self     = shift;
    my $response = $self->response_obj;
    return $self->response_obj->set_header(@_)

}

#Get cgi params;
sub _get_params {
    my $self = shift;
    my $_cgi = $self->Cgi_obj();
    my %params;
    foreach my $i ( $_cgi->param() ) {
        my @all = $_cgi->param($i);
        foreach my $value (@all) {
            next if ref $value;
            $value = decode( 'utf8', $value ) unless is_utf8($value);
        }
        $params{$i} = scalar @all > 1 ? \@all : $all[0];
    }
    return \%params;
}

sub print_header() {
    my ($self) = @_;
    my $_cgi   = $self->Cgi_obj();
    my $ref    = $self->Header();
    return $self->response( { data => '', } );
    return $_cgi->header( map { $_ => $ref->{$_} } keys %{ $self->Header() } );
}

sub destroy {
    my $self = shift;
    $self->_response_obj(undef);
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

