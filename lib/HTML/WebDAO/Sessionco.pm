#$Id$

package HTML::WebDAO::Sessionco;
use HTML::WebDAO::Base;
use CGI;
use MIME::Base64;
use Digest::MD5 qw(md5_hex);

#use usession;
#@ISA="usession";
use base qw( HTML::WebDAO::Session );

use strict 'vars';
__PACKAGE__->attributes qw( Cookie_name Db_file );

sub Init {

    #Parametrs is realm => [string] - for http auth
    #		id =>[string] - name of cookie
    #		db_file => [string] - path and filename
    #
    my ( $self, %param ) = @_;
    my $id = $param{id} || "stored";
    Cookie_name $self (
        {
            -NAME    => "$id",
            -EXPIRES => "+3M",
            -PATH    => "/",
            -VALUE   => "0"
        }
    );
    $self->SUPER::Init(%param);
    set_header $self ( "-TYPE",    "text\/html" );
#    set_header $self ( "-EXPIRES", "-1d" );
}

sub get_id {
    my $self = shift;
    my $coo  = U_id $self;
    return $coo if ($coo);
    my $_cgi = $self->Cgi_obj();
    $coo = $_cgi->get_cookie( ( $self->Cookie_name() )->{-NAME} );
    unless ($coo) {
        $coo = md5_hex(time ^ $$, rand(999)) ;
        U_id $self ( $coo );
    }
    $self->Cookie_name()->{-VALUE} = $coo;

    my $new_coo = $_cgi->get_cookie( $self->Cookie_name() );
    $self->set_header( "-COOKIE", $new_coo );
    return $coo;
}

sub unpack_engine_tree() {
    my ( $self, $par ) = @_;

    sub GetPar {
        my $cim = shift;
        my $Res = {};
        my $name;
        my ( $term, $end, $begin );
        while ( $cim =~ m/(\w*[{=])/g ) {
            $name = $1;
            $term = substr( $name, -1 );
            chop($name);
            for ($term) {
                do {
                    /\=/ && do {
                        $cim =~ m/([\w\!]*)\;/g;    #print $1,"\n";
                        my $tr = $1;
                        $tr =~ tr/\!/\=/;
                        $Res->{$name} = decode_base64($tr);
                      }
                      || /\{/ && do {
                        $begin = pos $cim;
                        my $flag = 1;
                        while ( $cim =~ m/([{}])/g ) {
                            $1 =~ /\{/ ? ++$flag : --$flag;
                            $end = pos $cim, last if ( $flag == 0 );
                        }
                        $Res->{$name} = &GetPar( substr( $cim, $begin, $end - $begin - 1 ) );
                      }
                  }
            }
        }
        return $Res;
    }    #(GetPar)

    #Get tree for _set_vars
    my $ref_tree = &GetPar($$par);
    return $ref_tree;
}    #SetSession

sub _load {
    my $self    = shift;
    my $ref_par = shift;
    my ( $id, $eng_name ) = @$ref_par{ "id", "eng_name" };
    my $temp;
    my ( $rec, $key, $eng, $val );
    if ( open FH, "<" . $self->Db_file ) {
        while ( $rec = <FH> ) {
            ( $rec =~ /^(.*)\.\|\.(.*)\.\|\.(.*)$/ )
              && ( ( $key, $eng, $val ) = ( $1, $2, $3 ) )
              && ( $key =~ /$id/ )
              && ( $eng =~ /$eng_name/ )
              && do {
                $temp = $self->unpack_engine_tree( \$val );
                last;
              }
        }
        close FH;
        return $temp;
    }
    return {};
}

sub pack_engine_tree() {
    my $self    = shift;
    return "";
    my $eng_ref = $self->Engine();

    #Fetch object's state tree
    my $tree = $eng_ref->_get_vars();

    sub test {
        my ( @pars, $res );
        my $par = $_[0];
        foreach my $key ( keys( %{$par} ) ) {
            if ( ref( $par->{$key} ) eq "HASH" ) {
                $res .= $key . "{" . &test( $par->{$key} ) . "}";
            }
            else {
                my $tr = encode_base64( $par->{$key} );
                $tr =~ tr/\=/\!/;
                chomp($tr);
                $res .= "$key=" . $tr . ";";
            }
        }
        return $res;
    }

#return string eq to
#Text3{_info=T2Zm;Val=LQ!!;Par=MA!!;}Panel1{Test=VEVTVElORw!!;Test2=MQ!!;_info=T2Zm;}Par=aGk!;Text1{_info=T2Zm;Val=Kw!!;Par=MA!!;}
    return &test($tree);
}

sub _store {
    my $self    = shift;
    my $ref_par = shift;
    my ( $id, $tree, $eng_name ) = @$ref_par{ "id", "tree", "eng_name" };
    my %reestr;
    my ( $rec, $key, $eng, $val );
    if ( open FH, "<" . $self->Db_file ) {
        while ( $rec = <FH> ) {
            ( $key, $eng, $val ) = $rec =~ /^(.*)\.\|\.(.*)\.\|\.(.*)$/;
            $reestr{$key}{$eng} = $val;
        }
        close FH;
    }
    $reestr{$id}{$eng_name} = $self->pack_engine_tree();
    if ( open FH, ">" . $self->Db_file ) {
        foreach my $key ( keys %reestr ) {
            foreach my $name ( keys %{ $reestr{$key} } ) {
                print FH "$key\.\|\.$name\.\|\.", $reestr{$key}{$name}, "\n";
            }
        }
        close FH;
    }
    return $id;
}

1;
