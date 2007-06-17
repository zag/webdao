#$Id$

package HTML::WebDAO::Sessiong;
use CGI;
use MIME::Base64;
use HTML::WebDAO::Base;
use base qw( HTML::WebDAO::Session );
#use tbase;
#use usession;
#@ISA="usession";
use strict 'vars';
attributes qw (Cookie_name Realm Db_file Storage_Hash);
use Data::Dumper;
sub Init{
#Parametrs is realm => [string] - for http auth
#		id =>[string] - name of cookie
#		db_file => [string] - path and filename
#
my ($self,$param)=@_;
$self->SUPER::Init($param);
Realm $self $param->{'realm'} ?$param->{realm}:"eng.zone";
#logmsgs $self Dumper($param);
Storage_Hash $self ($param->{'store_hash'} || {});
my $id=$param->{id} ||"stored";
Cookie_name $self ({	-NAME=>"$id",
			-EXPIRES=>"+3M",
			-PATH=>"/",
			-VALUE=>"0"}
		);
set_header $self ("-TYPE","text\/html");
set_header $self ("-EXPIRES","-1d");
}

sub get_id {
my $self=shift;
my $coo=U_id $self;
return $coo if ($coo);
my $uspwd;
if (exists($ENV{"HTTP_AUTHORIZATION"}) && ($ENV{"HTTP_AUTHORIZATION"})) {
$uspwd=decode_base64((split (/\s+/,$ENV{"HTTP_AUTHORIZATION"}))[1]);
} else {
$self->set_header("-status",'401 Authorization Required');
$self->set_header("-WWW_Authenticate",'Basic realm="'.$self->Realm().'"');
print $self->print_header();
exit;
}
my $_cgi=$self->Cgi_obj();
$coo=$_cgi->cookie(($self->Cookie_name())->{-NAME});
unless ($coo) {
	$coo=time();
	U_id $self ($coo.$uspwd);
	}
$self->Cookie_name()->{-VALUE}=$coo;

my $new_coo=$_cgi->cookie($self->Cookie_name());
$self->set_header("-COOKIE",$new_coo);
return $coo.$uspwd;
}


sub load {
my $self=shift;
my $ref_par=shift;
my ($id,$eng_name)=@$ref_par{"id","eng_name"};
my $hash=$self->Storage_Hash();
return $self->Storage_Hash()->{{
		id=>$id,
		eng_name=>$eng_name
	}}
}

sub store{
my $self=shift;
my $ref_par=shift;
my ($id,$tree,$eng_name)=@$ref_par{"id","tree","eng_name"};
$self->Storage_Hash()->{{
		id=>$id,
		eng_name=>$eng_name
	}}=$tree;
return $id;
}

1;
