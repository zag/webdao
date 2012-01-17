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
sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

1;

