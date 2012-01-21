#===============================================================================
#
#  DESCRIPTION:  Session0 module. Cleaned api
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package WebDAO::Session0;
use strict;
use warnings;
use Encode qw(encode decode is_utf8);
use WebDAO::Session;
use base qw( WebDAO::Session );
use WebDAO::CV;
use WebDAO::Response0;

#sub new {
#    my $class = shift;
#    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
#}

#Need to be forever called from over classes;
sub Init {

    #Parametrs is realm
    my $self = shift;
    my %args = @_;
    Header $self ( {} );
    U_id $self undef;
    Cgi_obj $self $args{cv}
      || new WebDAO::CV::;    #create default controller
    my $cv = $self->Cgi_obj;           # Store Cgi_obj in local var
                                      #create response object
    $self->_response_obj(
        new WebDAO::Response0::
          session => $self,
        cv => $cv
    );
    _store_obj $self ( $args{store} || new WebDAO::Store::Abstract:: );

    Cgi_env $self (
        {
            url => $cv->url( -base => 1 ),    #http://eng.zag
            path_info         => $cv->url( -absolute => 1, -path_info => 1 ),
            path_info_elments => [],
            file              => "",
            base_url     => $cv->url( -base => 1 ),    #http://base.com
#            query_string => $cv->query_string, #???
#            referer      => $cv->referer(),
            accept       => $cv->accept,
        }
    );

    #fix CGI.pm bug http://rt.cpan.org/Ticket/Display.html?id=25908
    $self->Cgi_env->{path_info} =~ s/\?.*//s;
    $self->get_id;
    Params $self ( $self->_get_params() );
    $self->Cgi_env->{path_info_elments} =
      [ grep { defined $_ } split( /\//, $self->Cgi_env->{path_info} ) ];
    #save request method
    $self->request_method($cv->method);
    #set default header
    $cv->set_header("Content-Type" => 'text/html; charset=utf-8');
}

#Get cgi params;
sub _get_params {
    my $self = shift;
    my $_cgi = $self->Cgi_obj();
    my %params;
    foreach my $i ( $_cgi->param()  ) {
        my @all = $_cgi->param($i);
        foreach my $value (@all) {
            next if ref $value;
            $value = decode( 'utf8', $value ) unless is_utf8($value);
        }
        $params{$i} = scalar @all > 1 ? \@all : $all[0];
    }
    return \%params;
}


1;

