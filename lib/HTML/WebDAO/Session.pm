#$Id: Session.pm,v 1.6 2006/10/27 08:59:08 zag Exp $

package HTML::WebDAO::Session;
use HTML::WebDAO::Base;
use CGI;
use HTML::WebDAO::Store::Abstract;
use Data::Dumper;
use base qw( HTML::WebDAO::Base );
__PACKAGE__->attributes
  qw( Cgi_obj Cgi_env U_id Header Params  Switch_sos_id Switch_sos_flag _store_obj );

sub _init() {
    my $self = shift;
    $self->Init(@_);
    return 1;
}

#Need to be forever called from over classes;
sub Init {

    #Parametrs is realm
    $self = shift;
    my %args = @_;
    Header $self ( {} );
    U_id $self undef;
    Cgi_obj $self $args{cv}
      || do { $self->_log1("ERR: USE cv when init Session!"); CGI::new() };
    _store_obj $self ( $args{store} || new HTML::WebDAO::Store::Abstract:: );
    Cgi_env $self (
        {
            url => $self->Cgi_obj->url( -base => 1 ),    #http://eng.zag
            path_info => $self->Cgi_obj->url( -absolute => 1, -path_info => 1 ),
            path_info_elments => [],
            file              => "",
            base_url     => $self->Cgi_obj->url( -base => 1 ),  #http://base.com
            query_string => $self->Cgi_obj->query_string,
            referer      =>$self->Cgi_obj->referer()
        }
    );
    #fix CGI.pm bug http://rt.cpan.org/Ticket/Display.html?id=25908
    $self->Cgi_env->{path_info} =~ s/\?.*//s;
    $self->get_id;
    Params $self ( $self->_get_params() );
    $self->Cgi_env->{path_info_elments} =
      [ grep { defined $_ } split( /\//, $self->Cgi_env->{path_info} ) ];

    #init hash of describe content
    # single object state
    Switch_sos_id $self   ( {} );
    Switch_sos_flag $self ("0");

}

#Can be overlap if you choose another
#alghoritm generate unique session ID (i.e cookie,http_auth)
sub get_id {
    my $self = shift;
    my $coo  = U_id $self;
    return $coo if ($coo);
    return rand(100);
}

sub call_path {
    my $self = shift;
    $self->Cgi_env->{path_info_elments};
}


sub _load_attributes_by_path  { (shift)->_store_obj->_load_attributes($self->get_id(),@_) }
sub _store_attributes_by_path { (shift)->_store_obj->_store_attributes($self->get_id(),@_) }



sub flush_session {
    my $self = shift;
    $self->_store_obj->flush($self->get_id());
}


#--------------------------------------------------
#$ref_sos={	data_type=>"text\/html",
#	raw_data=>\@,
#	obj_ref=>$self,
#	obj_method=>\&read_image
#	store_session=>0}
sub switch2sos {
    my ( $self, $name, $ref_sos ) = @_;
    Switch_sos_id $self   ($ref_sos);
    Switch_sos_flag $self ("1");
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
        geturl  => sub { $self->sess_servise_geturl(@_) },
        getform => sub { $self->sess_servise_getform(@_) },
        getenv  => sub { $self->sess_servise_getenv(@_) },
        getsess => sub { return $self },
    );
    if ( exists( $service{ $par->{funct} } ) ) {
        ${ $par->{result} } = $service{ $par->{funct} }->( $par->{par} );
    }
    else {
        logmsgs $self "not exist request funct !" . $par->{funct};
    }
}

#
#{variable=>{
#			name=>Par,
#			value=>"10"},
#event	=>{
#			name=>"_info_on",
#			value=>"10"
#			}})
sub sess_servise_geturl {
    my ( $self, $par ) = @_;
    my $str;
    $str = $par->{path} || '';
    if ( exists( $par->{event} ) ) {
        $str .= "ev/evn_"
          . $par->{event}->{name} . "/"
          . $par->{event}->{value} . "/";
    }
    if ( exists( $par->{variable} ) ) {
        $par->{variable}->{name} =~ s/\./\//g;
        $str .= "par/"
          . $par->{variable}->{name} . "/"
          . $par->{variable}->{value} . "/";
    }
    $str .= ( exists( $par->{file} ) ) ? $par->{file} : $self->Cgi_env->{file};
    if ( ref( $par->{pars} ) eq 'HASH' ) {
        my @pars;
        while ( my ( $key, $val ) = each %{ $par->{pars} } ) {
            push @pars, "$key=$val";
        }
        $str .= "?" . join "&" => @pars;
    }
    return $str;
}

#sess_servise_getform({data =>\@,url=>"root for form")
sub sess_servise_getform {
    my ( $self, $par ) = @_;
    my ( $data, $ref, $enctype ) = @{$par}{ "data", "sendto", "enctype" };
    my $root_url =
      ($ref) ? $ref : $self->Cgi_env->{path_info} . $self->Cgi_env->{file};
    return \eval '<<END;
<form action="$root_url" method="post" name="tester" id="test" enctype="$enctype">@{$data}</form>
END';
}

#get current session enviro-ent
sub sess_servise_getenv {
    my ($self) = @_;
    return $self->Cgi_env;
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
    $eng_ref->Work($self);
    $eng_ref->SendEvent("_sess_ended");
    #print @{$eng_ref->Fetch()};
    $eng_ref->_destroy;
    $self->flush_session($eng_ref);

}

#for setup Output headers
sub set_header() {
    my ( $self, $name, $par ) = @_;
    $self->_log2( Dumper( [ map { [ caller($_) ] } ( 1 .. 5 ) ] ) )
      unless ref( $self->Header() );
    $self->Header()->{ uc $name } = $par;
}

#Get cgi params;
sub _get_params {
    my $self = shift;
    my $_cgi = $self->Cgi_obj();
    my %params;
    foreach my $i ( $_cgi->param() ) {
        my @all = $_cgi->param($i);
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

1;
