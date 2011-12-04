#!/usr/bin/perl
#===============================================================================
#
#         FILE: wd_cgi.pl
#
#  DESCRIPTION:  CGI script for WebDAO project
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zag@cpan.org>
#===============================================================================

use WebDAO;
use WebDAO::CVcgi;
use WebDAO::Session;
use WebDAO::Lex;

use Data::Dumper;
use strict;

sub _parse_str_to_hash {
    my $str = shift;
    return unless $str;
    my %hash = map { split( /=/, $_ ) } split( /;/, $str );
    foreach ( values %hash ) {
        s/^\s+//;
        s/\s+^//;
    }
    \%hash;
}

my ( $store_class, $session_class, $eng_class ) = map {
    eval "require $_"
      or die $@;
    $_
  } (
    $ENV{wdStore}   || 'WebDAO::Store::Abstract',
    $ENV{wdSession} || 'WebDAO::Session',
    $ENV{wdEngine}  || 'WebDAO::Engine'
  );

my $store_obj =
  $store_class->new( %{ &_parse_str_to_hash( $ENV{wdStorePar} ) || {} } );
my $sess = $session_class->new(
    %{ &_parse_str_to_hash( $ENV{wdSessionPar} ) || {} },
    store => $store_obj,
    cv    => new WebDAO::CVcgi::,

);
$sess->set_header( -type => 'text/html; charset=utf-8' );
my ($filename) = grep { -r $_ && -f $_ } $ENV{wdIndexFile},
  "$ENV{DOCUMENT_ROOT}/$ENV{wdIndexFile}", "$ENV{DOCUMENT_ROOT}/index.xhtml";
die "$0 ERR:: file not found or can't access (wdIndexFile): $ENV{wdIndexFile}"
  unless $filename;

        open FH, "<$filename" or die $!;
        my $content ='';
        { local $/=undef;
        $content = <FH>;
        }
        close FH;

my $lex     = new WebDAO::Lex:: tmpl => $content;

my $eng = $eng_class->new(
    %{ &_parse_str_to_hash( $ENV{wdEnginePar} ) || {} },
    lex    => $lex,
    session  => $sess,
);
$sess->ExecEngine($eng);
$sess->destroy;

__END__

=head1 NAME

wd_cgi.pl - CGI script for WebDAO project

=head1 SETUP

    SetEnv wdIndexFile index.xhtm


=head1 SEE ALSO

http://sourceforge.net/projects/webdao, WebDAO

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2003-2011 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
