#!/usr/bin/env starman

#===============================================================================
#
#  DESCRIPTION:  PSGI server for WebDAO 
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zag@cpan.org>
#===============================================================================

package main;
use strict;
use warnings;
use WebDAO::Util;
use WebDAO;
use WebDAO::CV;

my $handler = sub {
    my $env = shift;
    die "Only psgi.streaming=1 servers supported !"
      unless $env->{'psgi.streaming'};
    my $coderef = shift;
    $env->{wdEnginePar} = $ENV{wdEnginePar} || $env->{HTTP_WDENGINEPAR} ;
    $env->{wdEngine} = $ENV{wdEngine} || $env->{HTTP_WDENGINE} ;
    $env->{wdSession} = $ENV{wdSession} || $env->{HTTP_WDSESSION} || 'WebDAO::Session0' ;
    my $ini = WebDAO::Util::get_classes(__env => $env, __preload=>1);
    my $store_obj = "$ini->{wdStore}"->new(
            %{ $ini->{wdStorePar} }
    );

    my $cv = WebDAO::CV->new(env=>$env, writer=>$coderef);

    my $sess = "$ini->{wdSession}"->new(
        %{ $ini->{wdSessionPar} },
        store => $store_obj,
        cv    => $cv,
    );
#    warn "use $env->{wdSession}, $ini->{wdEngine}";
    my $eng = "$ini->{wdEngine}"->new(
        %{ $ini->{wdEnginePar} },
        session => $sess,
    );
    #set default header
#    $sess->set_header("content-Type" => 'text/html; charset=utf-8');
    $sess->ExecEngine($eng);
    use Data::Dumper;
    $cv->{fd}->write('<pre>'.Dumper($env).'</pre>');
    #close psgi
    $cv->{fd}->close() if exists $cv->{fd};
    $sess->destroy;
};

my $app = sub {
    my $env = shift;
    sub { $handler->( $env, $_[0])}
};
$app;
