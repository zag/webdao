#!/usr/bin/perl
#===============================================================================
#
#         FILE: wd_shell.pl
#
#  DESCRIPTION:  shell script for WebDAO project
#       AUTHOR:  Aliaksandr P. Zahatski (Mn), <zag@cpan.org>
#===============================================================================
#$Id: wd_shell.pl,v 1.2 2006/10/27 08:59:08 zag Exp $
package WebDAO::Shell::Writer;

sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}
sub write   { print  $_[1] }
sub close   { }
sub headers {  }

package main;
use strict;
use warnings;
use Carp;
use WebDAO;
use WebDAO::SessionSH;
use WebDAO::Store::Abstract;
use WebDAO::CV;
use Data::Dumper;
use WebDAO::Lex;
use Getopt::Long;
use Pod::Usage;
use WebDAO::Util;

my ( $help, $man, $sess_id );
my %opt = ( help => \$help, man => \$man, sid => \$sess_id );   #meta=>\$meta,);
my @urls=();
GetOptions( \%opt, 'help|?', 'man', 'f=s','wdEngine|M=s','wdEnginePar=s', 'sid|s=s','<>'=>sub { push @urls,shift} )
  or pod2usage(2);
pod2usage(1) if $help;
pod2usage( -exitstatus => 0, -verbose => 2 ) if $man;

my $evl_file = shift @urls;
pod2usage( -exitstatus => 2, -message => 'No path give or non exists ' )
  unless $evl_file;

foreach my $sname ('__DIE__') {
    $SIG{$sname} = sub {
        return if (caller(1))[3] =~ /eval/;
        push @_, "STACK:" . Dumper( [ map { [ caller($_) ] } ( 1 .. 3 ) ] );
        print STDERR "PID: $$ $sname: @_";
      }
}

 $ENV{wdEngine} ||= $opt{wdEngine}|| 'WebDAO::Engine';
 $ENV{wdSession} ||= 'WebDAO::SessionSH';
 $ENV{wdShell} = 1;
 my $ini = WebDAO::Util::get_classes(__env => \%ENV, __preload=>1);

    #Make Session object
    my $store_obj = "$ini->{wdStore}"->new(
            %{ $ini->{wdStorePar} }
    );

    my $cv = WebDAO::CV->new(
        env    => \%ENV,
        writer => sub {
            new WebDAO::Shell::Writer::
              status  => $_[0]->[0],
              headers => $_[0]->[1];
        }
    );

    my $sess = "$ini->{wdSession}"->new(
        %{ $ini->{wdSessionPar} },
        store => $store_obj,
        cv    => $cv,
    );

    $sess->U_id($sess_id);

    my $filename  = exists $opt{f} ? $opt{f} : $ENV{wdIndexFile};

    my %engine_args = ();
    if  ( $filename && $filename ne '-' ) {
    unless ( -r $filename && -f $filename ) {
    warn <<TXT;
ERR:: file not found or can't access (wdIndexFile): $filename
check -f option or env variable wdIndexFile;
TXT
        exit 1;
    }

    open FH, "<$filename" or die $!;
    my $content ='';
    { local $/=undef;
        $content = <FH>;
    }
    close FH;
    my $lex = new WebDAO::Lex:: tmpl => $content;
    $engine_args{lex} = $lex;
    }
     my $eng = "$ini->{wdEngine}"->new(
        %{ $ini->{wdEnginePar} },
        session => $sess,
        %engine_args
    );

$sess->ExecEngine($eng, $evl_file);
$sess->destroy;
croak STDERR $@ if $@;
print "\n";

=head1 NAME

  wd_shell.pl  - command line tool for developing and debuging

=head1 SYNOPSIS

  wd_shell.pl [options] /some/url/query

   options:

    -help  - print help message
    -man   - print man page
    -f file    - set root [x]html file 

=head1 OPTIONS

=over 8

=item B<-help>

Print a brief help message and exits

=item B<-man>

Prints manual page and exits

=item B<-f> L<filename>

Set L<filename> set root [x]html file  for load domain

=back

=head1 DESCRIPTION

B<wd_shell.pl>  - tool for debug .

=head1 SEE ALSO

http://sourceforge.net/projects/webdao, WebDAO

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2000-2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

