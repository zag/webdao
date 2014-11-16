# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

#use Test::More tests => 28;
use Test::More skip_all => "deprecated";;

#use Test::More (no_plan);
use Data::Dumper;
use File::Temp qw/tempdir/;
use strict;

BEGIN {
    use_ok('WebDAO');
    use_ok('WebDAO::Engine');
    use_ok('WebDAO::Store::Storable');
    use_ok('WebDAO::Container');
    use_ok('WebDAO::SessionSH');
    use lib 't/lib';
    use_ok('TestWDAO');
}

my $dir      = tempdir( CLEANUP => 1 );
my $ID       = "tcontainer";
my $store_ml = new WebDAO::Store::Storable:: path => $dir;
my $session  = new WebDAO::SessionSH:: store => $store_ml;
$session->U_id($ID);
my $test_class = 'TestWDAO';
my $test_alias = "testclass";
my $eng        = new WebDAO::Engine::
  session  => $session,
  register => { $test_class => $test_alias, 'WebDAO::Container' => 'contaner' };
my $telement = $eng->_createObj( "t1", $test_alias );
ok( $telement, "Create test1 object" );
ok( $telement->_obj_name eq 't1', " test obj name" );
$eng->_add_childs_($telement);
is $telement->_sess1, 1, 'check defaults mk_sess_attr ';
is $telement->_sess3, undef, 'undef default for _sess3 ';
is $telement->_sess4, 'undef', 'undef default for _sess4 ';
$telement->_sess2(6);
#test mk_attr
is $telement->_prop2, 3, 'mk_attr: check defaults';
is $telement->_prop3, undef, 'mk_attr: check undef defaults';
is $telement->_prop4, 'undef', 'mk_attr: check "undef" defaults';

is $telement->_prop2(2), 3, 'mk_attr: check return prev default value';
is $telement->_prop2(4), 2, 'mk_attr: check return prev value';
is $telement->_prop2(), 4, 'mk_attr: check return value';
ok exists $telement->{_prop2}, 'mk_attr: \$telement->{_prop2}';
delete $telement->{_prop2};
is $telement->_prop2(2), 3, 'mk_attr: check return prev default value after delete \$telement->{_prop2}';

my $obj_by_name = $eng->_get_obj_by_name('t1');
ok( $obj_by_name, "test get obj by name" );
ok( $telement->_obj_name eq $obj_by_name->_obj_name, " test eq obj name" );
my $tcontainer = $eng->_createObj( 'c1', 'contaner' );
ok( $tcontainer, "test create container" );
my $t2 = $eng->_createObj( "t2", $test_alias );
ok( $t2, "Create test2 object" );
$tcontainer->_add_childs_($t2);
$eng->_add_childs_($tcontainer);
ok( @{ $eng->_get_childs_ } == 2, 'Test count of inserted' );
my $t3 = $eng->_createObj( "t3", $test_alias );
ok( $t3, "Create test3 object" );
$tcontainer->_add_childs_($t3);
$eng->_destroy;
$session->flush_session;

my $store_ml1 = new WebDAO::Store::Storable:: path => $dir;
my $session1  = new WebDAO::SessionSH:: store      => $store_ml1;
$session1->U_id($ID);
my $eng1 = new WebDAO::Engine::
  session  => $session1,
  register => { $test_class => $test_alias, 'WebDAO::Container' => 'contaner' };
my $telement_ = $eng1->_createObj( "t1", $test_alias );
ok( $telement_, "Create test1 object" );
ok( $telement_->_obj_name eq 't1', " test obj name" );
$eng1->_add_childs_($telement_);
ok( $telement_->_sess2 == 6, "test restore attr" );

#print Dumper($eng->__obj);

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

