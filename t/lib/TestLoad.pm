package TestLoad;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use WebDAO::Container;
use WebDAO;
use base ( 'WebDAO::Container','WebDAO' );

sub view {
    return 1
}
1;
