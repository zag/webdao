#$Id: Session.pm,v 1.6 2006/10/27 08:59:08 zag Exp $

package HTML::WebDAO::Session;
use HTML::WebDAO::Base;
use CGI;
use HTML::WebDAO::Store::Abstract;
use Data::Dumper;
use base qw( HTML::WebDAO::Base );
__PACKAGE__->attributes
  qw( Cgi_obj Cgi_env U_id Header Params  Events Switch_sos_id Switch_sos_flag _store_obj );

sub _init() {
    my $self = shift;
    $self->Init(@_);
    return 1;
}

#Need to be forever called from over classes;
sub Init {

    #Parametrs is realm
    $self = shift;
    Header $self ( {} );
    Events $self ( {} );
    U_id $self undef;
    Cgi_obj $self $_[0]->{cv}
      || do { $self->_log1("ERR: USE cv when init Session!"); CGI::new() };
    _store_obj $self $_[0]->{store} || new HTML::WebDAO::Store::Abstract::;
    Cgi_env $self (
        {
            url               => $self->Cgi_obj->url(),         #http://eng.zag
            path_info         => $self->Cgi_obj->path_info(),
            path_info_elments => [],
            file              => "",
        }
    );
    $self->get_id;
    Params $self ( $self->_get_params() );
    $self->Cgi_env->{path_info_elments} =
      [ grep { $_ && defined $_ } split( /\//, $self->Cgi_env->{path_info} ) ];

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

#this method first need overlapped;
#see store_session() and load_session()
#{		id		=>$id, 		session ID
#		eng_name	=>$eng_name,	request name of Engine
#		tree		=>$tree		refer to tree fo this Engine
#}
#note: if for load()  parametr "tree" is string (always !) eq this: .applic.container1.text1
#load() mast return value for this request
# if tree not reference to hash for store() it equ to parametr for load(), but
#must save this  path into requested Engine name .applic.container1.text1.rewd=[parametr]
sub load  { (shift)->_store_obj->load(@_) }
sub store { (shift)->_store_obj->store(@_) }

#--------------------------------------------------
sub set_engine_state() {
    my ( $self, $eng_ref, $object_state_tree ) = @_;

    #Store object's state tree
    $eng_ref->_set_vars($object_state_tree);
    return 1;
}

sub get_engine_state() {
    my ( $self, $eng_ref ) = @_;

    #Fetch object's state tree
    my $object_state_tree = $eng_ref->_get_vars();
    return $object_state_tree;
}

#--------------------------------------------------

#Method for store enigine_state
#these method need to overlap for convert tree Engine
#format store state to database store data format
#
sub store_session() {
    my ( $self, $eng_ref ) = @_;
    $eng_ref->SendEvent("_sess_ended");
    my $id                = $self->get_id();
    my $object_state_tree = $self->get_engine_state($eng_ref);
    my $stored_hash       = $self->load($id);
    $object_state_tree =
      $self->merge_stored_and_new_tree( $stored_hash, $object_state_tree );
    $self->store( $id, $object_state_tree );
    return 1;
}

#Method for load engine_state
#these method need to overlap for convert database
#store data format to tree Engine format store state
#
sub load_session() {
    my ( $self, $eng_ref ) = @_;
    my $id                = $self->get_id();
    my $object_state_tree = $self->load($id);
    $self->set_engine_state( $eng_ref, $object_state_tree );
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

sub LoadSession {
    my ( $self, $eng_ref ) = @_;

    #register special event
    #for switch to single object state
    $eng_ref->RegEvent( $self, "_switch_sos",   \&switch2sos );
    $eng_ref->RegEvent( $self, "_sess_servise", \&sess_servise );
    $self->load_session($eng_ref);

    #send Event after load all parametrs
    $eng_ref->SendEvent("_sess_loaded");
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

    #Load session
    $self->LoadSession($eng_ref);

    #send events from urls;
    map { $eng_ref->SendEvent( $_, $self->Events->{$_} ) }
      keys %{ $self->Events };

    #print $self->print_header();
    $eng_ref->Work($self);

    #print @{$eng_ref->Fetch()};
    $self->store_session($eng_ref);
    $eng_ref->_destroy;
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
        $params{$i} = $_cgi->param($i);
    }
    return \%params;
}

#Stored tree MUST BE MERGED with exists tree !
#this is need for store param for ucontainer with
#dynamic content
#If !correct overlaped this method - feacher is lost
#parametrs is \%stored_hash, \%new_hashe
#return recurcive merged tree
sub merge_stored_and_new_tree {
    my ( $self, $h1, $h2 ) = @_;

#logmsgs $self Dumper({'$h1'=>$h1}).Dumper([ map {caller($_)} (1..4)]);
#print STDERR "Do merge\n".Dumper([ map {caller($_)} (1..4)]) unless ref $h2 eq 'HASH';
    return $h1 unless ref $h2 eq 'HASH';
    while ( my ( $key, $val ) = each(%$h2) ) {
        unless ( ref($val) ) {
            $h1->{$key} = $val;
        }
        else {
            $h1->{$key} =
              $self->merge_stored_and_new_tree( $h1->{$key}, $h2->{$key} );
        }
    }
    return $h1;
}

sub print_header() {
    my ($self) = @_;
    my $_cgi   = $self->Cgi_obj();
    my $ref    = $self->Header();
    return $self->response( { data => '', } );
    return $_cgi->header( map { $_ => $ref->{$_} } keys %{ $self->Header() } );
}

1;
