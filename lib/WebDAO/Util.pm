#===============================================================================
#
#  DESCRIPTION:  Set of  service subs
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package WebDAO::Util;
use strict;
use warnings;
use Carp;
use WebDAO::Engine;
use WebDAO::Session;
use WebDAO::Store::Abstract;

=head2  load_module <package>

Check if already loaded package and preload else

return :  0  - fail load class
          1  - suss loaded
          -1 - already loaded

=cut

sub load_module {
    my $class = shift || return;

    #check non loaded mods
    my ( $main, $module ) = $class =~ m/(.*\:\:)?(\S+)$/;
    $main ||= 'main::';
    $module .= '::';
    no strict 'refs';
    unless ( exists $$main{$module} ) {
        eval "use $class";
        if ($@) {
            croak "Error register class :$class with $@ ";
            return 0;
        }
        return 1;
    } 
    use strict 'refs';
    -1;
}

=head2 _parse_str_to_hash <str>

convert string like:

    config=/tmp/tests.ini;host=test.local

to hash:

    {
      config=>'/tmp/tests.ini',
      host=>'test.local'
    }

=cut 

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

=head2 get_classes <hash with defaults>

Get classes by check ENV variables

    get_classes( wdEngine=> $def_eng_class) 

return ref to hash

=cut

sub get_classes {

    my %defaults = (
        wdEngine     => 'WebDAO::Engine',
        wdSession    => 'WebDAO::Session',
        wdStore      => 'WebDAO::Store::Abstract',
        wdStorePar   => undef,
        wdSessionPar => undef,
        wdEnginePar  => undef,
        @_
    );
    my $env          = delete $defaults{__env}     || \%ENV;
    my $need_preload = delete $defaults{__preload} || 0;

    $defaults{wdStore} =
         $env->{WD_STORE}
      || $env->{wdStore}
      || $defaults{wdStore};
    $defaults{wdSession} =
         $env->{WD_SESSION}
      || $env->{wdSession}
      || $defaults{wdSession};
    $defaults{wdEngine} =
         $env->{WD_ENGINE}
      || $env->{wdEngine}
      || $defaults{wdEngine};

    #init params
    $defaults{wdEnginePar} =
      WebDAO::Util::_parse_str_to_hash( $env->{WD_ENGINE_PAR}
          || $env->{wdEnginePar} )
      || {};
    $defaults{wdStorePar} =
      WebDAO::Util::_parse_str_to_hash( $env->{WD_STORE_PAR}
          || $env->{wdStorePar} )
      || {};
    $defaults{wdSessionPar} =
      WebDAO::Util::_parse_str_to_hash( $env->{WD_SESSION_PAR}
          || $env->{wdSessionPar} )
      || {};

    if ($need_preload) {
        for (qw/wdStore  wdSession  wdEngine /) {
            WebDAO::Util::load_module( $defaults{$_} );
        }
    }

    \%defaults;
   
}

1;

