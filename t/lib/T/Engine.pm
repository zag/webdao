#===============================================================================
#
#  DESCRIPTION:  Test Root element
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package TElem;
use strict;
use warnings;
use Data::Dumper;
use WebDAO;
use base 'WebDAO::Element';

sub String {
    "<STRI/>";
}

sub fetch {
    return "FF";
}
sub Echo {
    my $self = shift;
    my %args= @_;
    return $args{text}
}


1;
package TElemO;
use strict;
use warnings;
use Data::Dumper;
use WebDAO;
use base 'WebDAO::Element';
sub fetch {
    return "O";
}

package TComp;
use strict;
use warnings;
use WebDAO;
use Data::Dumper;
use base ('WebDAO::Container');
1;

package TElemModal;
use warnings;
use strict;
use WebDAO::Modal;
use base qw/TElem WebDAO::Modal/;

sub Method {
    "MMethod";
}

sub fetch {
    "MFetch";
}

package TCompModal;
use warnings;
use strict;
use WebDAO::Modal;
use base qw/ WebDAO::Container WebDAO::Modal/;

sub Method {
    "MMethod";
}

sub pre_fetch { "<M>" }

sub post_fetch {"<M>"}

sub SubElem {
    my $self = shift;
    my $eng = $self->getEngine;
    my @res =();
    for (1..2) {
      push @res, $eng->_createObj("el".$_, "TElem");
    }
    \@res
}

sub GetElement {
    my $self = shift;
    my $eng = $self->getEngine;
    $eng->_createObj("el", "TElemO");
}

sub ModalAnswer {
    my $self = shift;
    my $r    = $self->getEngine->response();
    $r->set_html("Test")->set_modal;
    $r;
}

sub GetArrayRef {
    my $self = shift;
    my $eng = $self->getEngine;
    [ $eng->_createObj("el1", "TElemO"),
    $eng->_createObj("el2", "TElemO"),
    ]
}
1;

package TExtra;
use strict;
use warnings;
use WebDAO;
use Data::Dumper;
use base ('TComp');

sub __any_path {
    my $self = shift;
    my ( $sess, @path ) = @_;
    if ( $path[0] =~ /\.pod/ ) {
        return { poddile => 1 };
    }
    elsif ( $path[2] && ( $path[2] eq 123 ) ) {
        $self->__extra_path( [ splice( @path, 0, 3 ) ] );
        return $self, \@path;
    }
    return $self->SUPER::__any_path( $sess, @path );
}

sub fetch {
    my $self = shift;
    my $sess = shift;
    warn "Fetch !";
    return "<br />";
}

sub String {
    my $self = shift;
    return "<a/>";
}
1;

package TEng;
use strict;
use warnings;
use Test::More;
use Data::Dumper;
use WebDAO;
use base ( 'WebDAO::Engine', 'TComp' );
1;

package T::Engine;
use strict;
use warnings;
use Data::Dumper;
use Test::More;
use base 'Test';

sub setup : Test(setup=>2) {
    my $t = shift;
    ok( ( my $store_ab = new WebDAO::Store::Abstract:: ), "Create store" );
    my $buffer;
    $t->{OUT} = \$buffer;
    my $cv = new TestCV:: \$buffer;
    #don't print headers
    $cv->{SKIP_HEADERS} =1;
    ok(
        ( my $session = new WebDAO::SessionSH:: store => $store_ab, cv => $cv ),
        "Create session"
      );
    $session->U_id("sdsd");
    my $eng = new TEng:: session => $session;
    $t->{tlib} = new WebDAO::Test eng => $eng;
}


sub t01 : Test(1) {
    use_ok 'WebDAO::Engine';
}


sub t01_test_resolve : Test(8) {
    my $t   = shift;
    my $eng = $t->{tlib}->eng;
    my $tlib = $t->{tlib};
    ok my $obj = $eng->_createObj( 'comp', 'TComp' ), 'make TestComp';
    $eng->_add_childs_($obj);

    isa_ok $tlib->resolve_path("/"),     "TEng",  "/";
    isa_ok $tlib->resolve_path("/comp"), "TComp", "/comp";
    ok my $obj1 = $eng->_createObj( 'extra', 'TExtra' ), 'make TestComp extra';
    $eng->_add_childs_($obj1);
    ok !$tlib->resolve_path("/extra/2010/12/1233"),
      "/extra/2010/12/1233 - not exists";

    my $r1 = $tlib->resolve_path("/extra/2010/12/123");
    ok $r1 && ( $r1->_obj_name eq "extra" ),
      "/extra/2010/12/123 fetch obj with extra path";

    my $r1_1 = $tlib->resolve_path("/extra/2010/12/123/test.pod");
    ok ref($r1_1) eq 'HASH', '/extra/2010/12/123/test.pod return hash';
    my $r2 = $tlib->resolve_path("/extra");
    ok $r2 && ( $r2->_obj_name eq "extra" ), "/extra";
}

sub t02_output : Test(7) {
    my $t    = shift;
    my $eng  = $t->{tlib}->eng;
    my $sess = $eng->_session;
    ok my $obj = $eng->_createObj( 'extra', 'TExtra' ), 'make TestComp';
    $eng->_add_childs_($obj);
    ok my $obj1 = $eng->_createObj( 'extra2', 'TExtra' ), 'make TestComp';
    $eng->_add_childs_($obj1);
    $obj1->_add_childs_( $eng->_createObj( 'elem',  'TElem' ) );
    $obj1->_add_childs_( $eng->_createObj( 'Melem', 'TElemModal' ) );

    #    diag Dumper $t->{tlib}->tree;
    my $out = $t->{OUT};
    $eng->execute2( $sess, "/extra2/elem/String" );
    is $$out, '<STRI/>', "/extra2/elem/String - call method";
    $$out = '';
    $eng->execute2( $sess, "/extra2/elem/" );
    is $$out, 'FF', "/extra2/elem/ - return self";

    $$out = '';
    $eng->execute2( $sess, "/extra2/elem/S" );
    ok $$out =~ /not\s+found/i, "/extra2/elem/S - Not Found";

    $$out = '';
    $eng->execute2( $sess, "/extra2/Melem/Method" );
    is $$out, 'MMethod', "/extra2/Melem/Method - Modal method";

    $$out = '';
    $eng->execute2( $sess, "/extra2/Melem" );
    is $$out, 'MFetch', "/extra2/Melem - Modal fetch";

}

sub t03_modal_comp : Test(10) {
    my $t   = shift;
    my $eng = $t->{tlib}->eng;
    my $tlib = $t->{tlib};
    ok my $obj = $eng->_createObj( 'elem', 'TElem' ), 'make TestComp';
    $eng->_add_childs_($obj);

    ok my $obj1 = $eng->_createObj( 'Mcomp', 'TCompModal' ), 'make TestComp';
    $eng->_add_childs_($obj1);
    $obj1->_add_childs_( $eng->_createObj( 'elem', 'TElem' ) );

    # $VAR1 = {
    #           ':TEng' => [
    #                        {
    #                          'elem:TElem' => []
    #                        },
    #                        {
    #                          'Mcomp:TCompModal' => [
    #                                                  {
    #                                                    'elem:TElem' => []
    #                                                  }
    #                                                ]
    #                        }
    #                      ]
    #         };
    
    my $out  = $t->{OUT};
    my $sess = $eng->_session;
    $eng->execute2( $sess, "/Mcomp/" );
    is $$out, '<M>FF<M>', "/Mcomp/ - modal container";
    $$out = '';
    $eng->execute2( $sess, "/Mcomp/Method" );
    is $$out, '<M>MMethod<M>',
      "/Mcomp/Method - modal container method ( return string - ignored)";
    $$out = '';
    $eng->execute2( $sess, "/Mcomp/ModalAnswer" );
    is $$out, 'Test',
      "/Mcomp/ModalAnswer - modal container method ( return WebDAO::Response )";

    $$out = '';
    $eng->execute2( $sess, "/Mcomp/MethodUnknown" );
    ok $$out =~ /not found/i,
      "/Mcomp/MethodUnknown - modal container method ( unknown method)";

    $$out = '';
    $eng->execute2( $sess, "/Mcomp/SubElem" );
#        diag Dumper $t->{tlib}->tree;
    is $$out, '<M>FFFF<M>',
      "/Mcomp/SubElem - modal container method ( return array of elems)";
    $$out = '';
    $eng->execute2( $sess, "/Mcomp/GetElement" );
    
    is $$out, '<M>O<M>',
      "/Mcomp/getElement - modal container method ( retutn WebDAO::Element - ignored)";

    $$out = '';
    $eng->execute2( $sess, "/Mcomp/GetArrayRef" );
    is $$out, '<M>OO<M>', "/Mcomp/GetArrayRef - Method return array of elements";

    isa_ok $tlib->resolve_path("/Mcomp/GetArrayRef"),'WebDAO::Container',
      "Check container when method return Array ref";
}

sub  t04_buld_scene :Test {
    my $t =shift;
    ok my $eng2 = new WebDAO::Engine:: session=> $t->{tlib}->get_session, ;
#    diag $eng2;
}

1;
