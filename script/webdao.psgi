#!/usr/bin/env starman

#===============================================================================
#
#  DESCRIPTION:  PSGI server for WebDAO 
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zag@cpan.org>
#===============================================================================

package WebDAO::CVpsgi;
use strict;
use warnings;
use CGI::Simple;
use WebDAO::CVcgi;
use base qw/WebDAO::CVcgi/;
__PACKAGE__->mk_attr( _cb =>undef, _env => undef);
sub _init {
    my $self = shift;
    my ($env, $cb) = @_;
    $self->_cb($cb);
    $self->_env($env);
    $self->SUPER::_init(CGI::Simple->new($env->{QUERY_STRING}));
    1;
}
sub http {return}
sub url {
    my $self = shift;

    my $env = $self->_env;

    my $uri = #($env->{'psgi.url_scheme'} || "http") .
        #"://" .
#        ($env->{HTTP_HOST} || (($env->{SERVER_NAME} || "") . ":" . ($env->{SERVER_PORT} || 80))) .
        ($env->{SCRIPT_NAME} || $env->{PATH_INFO} || '/');

    return $uri;
}
sub query_string{ $_[0]->{env}->{QUERY_STRING} };
sub referer{""}
sub param {{}};

sub response {
    my $self        = shift;
    my $res         = shift || return;
    if ( my $headers = delete $res->{headers} ) {
        my $cgi         = $self->Cgi_obj;
        my %out_headers = %{ $self->_headers };
        my $status = $res->{'headers'}->{'-STATUS'} || "200" ; 
        while ( my ($key, $val) = each %{ $headers } ) {
            # aggregate cookies   
            if ( $key eq '-COOKIE' ) {
                push @{ $out_headers{$key} }, $val;
            }
            else {
                $out_headers{$key} = $val;
            }

        }
    my @headers  = split(/[\n\r]+/, $cgi->header(%out_headers));
    my $fd = $self->_cb->([$status,\@headers,undef]);
#    $fd->write("ok");
#    $fd->close();
#    warn "out geader";
    $self->{fd} = $fd;
    }
#    use Data::Dumper;
#    warn "Resr" . Dumper($res) ;
    $self->print ($res->{data})
#    $self->SUPER::response($res);
}

sub print {
    my $self = shift;
    if (exists $self->{fd}) {
        $self->{fd}->write(@_);
    } else {
    print @_;
    }

}
1;
package main;
use strict;
use warnings;
use WebDAO::Util;
use WebDAO;


my $handler = sub {
    my $env = shift;
    my $coderef = shift;
    $env->{wdEngine} = $env->{HTTP_WDENGINE};
    $env->{wdSession} = $env->{HTTP_WDSESSION};
    my $ini = WebDAO::Util::get_classes(__env => $env, __preload=>1);
#    use Data::Dumper;
#    warn Dumper $ini;
    my $store_obj = "$ini->{wdStore}"->new(
            %{ $ini->{wdStorePar} }
    );
    my $cv = WebDAO::CVpsgi->new($env, $coderef);
    my $sess = "$ini->{wdSession}"->new(
        %{ $ini->{wdSessionPar} },
        store => $store_obj,
        cv    => $cv,
    );
    my $eng = "$ini->{wdEngine}"->new(
        %{ $ini->{wdEnginePar} },
        session => $sess,
    );
    $sess->set_header( -type => 'text/html; charset=utf-8' );
    $sess->ExecEngine($eng);
#    my $fd = $coderef->([ 200, ['Content-Type' => 'text/plain'], undef]);
#    $fd->write("Hello ");

    #close psgi
    $cv->{fd}->close() if exists $cv->{fd};
    $sess->destroy;
};

my $app = sub {
    my $env = shift;
    sub { $handler->( $env, $_[0])}
};
$app;
