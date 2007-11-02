
package TestTraverse;
use strict;
use warnings;
use HTML::WebDAO::Component;
use base 'HTML::WebDAO::Component';

sub test {
    my $self = shift;
    return $self;
}

sub index_x {
    my $self = shift;
    return $self;
}

1;

package main;
use strict;
use warnings;

use Data::Dumper;
use Test::More tests => 9;
#use Test::More qw(no_plan);

BEGIN {
    use_ok('HTML::WebDAO::Store::Abstract');
    use_ok('HTML::WebDAO::SessionSH');
    use_ok('HTML::WebDAO::Engine');
    use_ok('HTML::WebDAO::Container');
}

my $ID = "extra";
ok my $store_ab = ( new HTML::WebDAO::Store::Abstract:: ), "Create store";
ok my $session = ( new HTML::WebDAO::SessionSH:: store => $store_ab ),
  "Create session";
$session->U_id($ID);

my $eng = new HTML::WebDAO::Engine:: session => $session;

my $sess = $eng->_session;

$eng->register_class(
    'HTML::WebDAO::Container' => 'testmain',
    'TestTraverse'            => 'traverse'
);

#test traverse

my $main = $eng->_createObj( 'main2', 'testmain' );
$eng->_add_childs($main);
isa_ok my $trav_obj = $eng->_createObj( 'traverse', 'traverse' ),
  'TestTraverse', 'create traverse object';
$main->_add_childs($trav_obj);
$trav_obj->__extra_path( [ 1, 2, 3 ] );
my $traverse_url = $trav_obj->url_method('test');
isa_ok $eng->resolve_path( $sess, $traverse_url ), 'TestTraverse',
  "resolve_path $traverse_url";
my $traverse_url1 = $trav_obj->url_method();
isa_ok $eng->resolve_path( $sess, $traverse_url1 ), 'TestTraverse',
  "resolve_path $traverse_url1";

