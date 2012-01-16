#===============================================================================
#
#  DESCRIPTION:  Test Controller
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package WebDAO::CV;
sub new {
 my $class = shift;
  bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}
1;

use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print
use Test::More 'no_plan';
use_ok ('WebDAO::CV')


