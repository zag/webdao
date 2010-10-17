#===============================================================================
#
#  DESCRIPTION:  Test Container object
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package T::WebDAO::Container;
use strict;
use warnings;
use WebDAO::Container;
use Data::Dumper;
use Test::More;
use base 'Test';

sub t01_childs : Test(7) {
    my $t= shift;
    my $tlib = $t->{tlib};
    my $eng= $tlib->eng;
    my $cont = $eng->_create_("id","WebDAO::Container");
    is_deeply $cont->_get_childs_, [], 'check init state';
    my $o1 = $eng->_create_("id","WebDAO::Component");
    $cont->_add_childs_($o1);
    is scalar(@{$cont->_get_childs_} ), 1, '_add_childs';
    #setup pre and post objects
    my ($pr,$po) = map {$eng->_create_($_,"WebDAO::Component") } qw(pre post);
    $cont->__pre_childs([$pr]);
    $cont->__post_childs([$po]);
    is scalar(@{$cont->_get_childs_} ), 3, 'pre and post';
    $cont->_add_childs_( $eng->_create_("id1","WebDAO::Component") );
    is scalar(@{$cont->_get_childs_} ), 4, '_add_childs and pre, post';
    $cont->_set_childs_( $eng->_create_("id2","WebDAO::Component") );
    is scalar(@{$cont->_get_childs_} ), 3, '_set_childs_';
    is_deeply $tlib->tree($cont),{
          'id:WebDAO::Container' => [
                                      {
                                        'pre:WebDAO::Component' => []
                                      },
                                      {
                                        'id2:WebDAO::Component' => []
                                      },
                                      {
                                        'post:WebDAO::Component' => []
                                      }
                                    ]
        }, 'check tree after _set_childs_';
    $cont->_clear_childs_;    
    is_deeply $cont->_get_childs_, [], '_clear_childs_';
}
1;


