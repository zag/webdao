#===============================================================================
#
#  DESCRIPTION:  Test WebDAO::Util
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print
use Test::More 'no_plan';
use Data::Dumper;
use_ok('WebDAO::Util');


my $h1 = WebDAO::Util::get_classes(
    wdEngine => 'wdTest',
    __env    => { wdEngine => '', wdEnginePar => 'test=t;test2=t2' }
);
is $h1->{'wdEngine'}, 'wdTest', 'defaults get_classes';
is_deeply $h1->{wdEnginePar},
  {
    'test'  => 't',
    'test2' => 't2'
  },
  'parse params';

diag "$h1->{wdSession}"->new;
