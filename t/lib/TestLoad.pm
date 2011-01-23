package TestLoad;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use WebDAO::Container;
use WebDAO::Component;
use base ( 'WebDAO::Container','WebDAO::Component' );

sub view {
    return 1
}
1;
