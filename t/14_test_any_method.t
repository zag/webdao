#===============================================================================
#
#  DESCRIPTION:
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package TestElement;
use warnings;
use strict;
use WebDAO;
use base 'WebDAO::Component';

sub Exist {
    my $self = shift;
    return 1;
}

package TestElement_any;
use warnings;
use strict;
use Data::Dumper;
use base 'TestElement';

sub __any_method {
    my $self = shift;
    my ( $path, %params ) = @_;
    return \@_;
}

package Test1;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use lib 't/lib';
use base "Test";
use WebDAO;
use WebDAO::Test;
use WebDAO::Engine;
use WebDAO::SessionSH;

sub engine_class { 'WebDAO::Engine' }

=head2 make_eng [class=><CLASS>, index_file=><file_path>, ]

Return engine object. Used params:
    
  class - Class of engine or $test->engine_class (default -"WebDAO::Kernel"), 
  index_file - path to index file


=cut

sub make_engine {
    my $t        = shift;
    my %eng_pars = @_;
    my $class    = delete $eng_pars{class} || $t->engine_class;
    return &WebDAO::Test::make_engine( class => $class, %eng_pars );
}

=head2 make_test_lib <engine_object> [, <class_of_testlib>]

Return object of test class B<class_of_testlib> (default "WebDAO::Test::Lib")

=cut

sub make_test_lib {
    my $t = shift;
    return &WebDAO::Test::make_test_lib(@_);
}

sub startup : Test(startup) {
    my $t   = shift;
    my $eng = $t->make_engine;
    $t->{tlib} = $t->make_test_lib( $eng, 'WebDAO::Test' );
}

sub setup : Test(setup) {
    my $t   = shift;
    my $eng = $t->make_engine;
    $t->{tlib} = $t->make_test_lib( $eng, 'WebDAO::Test' );
}

sub teardown : Test(teardown) {
    my $t = shift;
    delete $t->{tlib};
}

sub t01_eng_tlib : Test(2) {
    my $t = shift;
    ok $t->{tlib}, 'created tlib';
    ok $t->{tlib}->eng, 'engine object';
}

sub t02_make_test_component : Test(no_plan) {
    my $t    = shift;
    my $eng  = $t->{tlib}->eng;
    my $tlib = $t->{tlib};
    ok my $obj = $eng->_createObj( 't', 'TestElement' ), 'make TestElement';
    $eng->_add_childs($obj);
    is_deeply { ':WebDAO::Engine' => [ { 't:TestElement' => [] } ] },
      $t->{tlib}->tree($eng), 'add test element';
    ok my $path1 = $obj->url_method("non_exists/test.ext"), 'make path1';
    ok my $path2 = $obj->url_method("Exist"), 'make path2';
    ok !$tlib->xget($path1), "resolve $path1";
    ok $tlib->xget($path2), "resolve $path2";
}

sub t03_make_test_component : Test(no_plan) {
    my $t    = shift;
    my $eng  = $t->{tlib}->eng;
    my $tlib = $t->{tlib};
    ok my $obj = $eng->_createObj( 't2', 'TestElement_any' ),
      'make TestElement_any';
    $eng->_add_childs($obj);
    is_deeply { ':WebDAO::Engine' => [ { 't2:TestElement_any' => [] } ] },
      $t->{tlib}->tree($eng), 'add test element';
    ok my $path1 = $obj->url_method("non_exists/test.ext"), 'make path1';
    is_deeply $tlib->xget($path1), [ [ 'non_exists', 'test.ext' ] ],
      "resolve empty $path1";

    ok my $path11 = $obj->url_method( "non_exists/test.ext", var => 1 ),
      'make path11';

    is_deeply $tlib->xget($path11),
      [ [ 'non_exists', 'test.ext' ], 'var', '1' ],
      "resolve with params $path11";
    ok my $path2 = $obj->url_method("Exist"), 'make path2';

#    diag $tlib->xget($path2);#, "resolve $path2";
}

package main;
use strict;
use warnings;
use lib 't/lib';
use Test;

Test::Class->runtests;

