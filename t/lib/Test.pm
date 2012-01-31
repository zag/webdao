package Test;

#$Id$

=head1 NAME

Base Class for tests

=head1 SYNOPSIS

    use WebDAO::Test;
    my $eng = t_get_engine( 'contrib/www/index.xhtm');
    my $tlib = t_get_tlib($eng);

=head1 DESCRIPTION

Class for tests

=cut

use Test::Class;
use WebDAO::Test;
use WebDAO::Store::Abstract;
use WebDAO::SessionSH;
use WebDAO::Engine;
use Test::More;
use warnings;
use strict;
use Test::Class;
use base 'Test::Class';

#don't test service class
sub SKIP_CLASS {
    my $t = shift;
    my $class = ref($t) || $t;
    return 1 if $class eq __PACKAGE__;
}

sub setup : Test(setup=>2) {
    my $t = shift;
    ok( ( my $store_ab = new WebDAO::Store::Abstract:: ), "Create store" );
    my $buffer='';
    $t->{OUT}=\$buffer;
    my $cv = new  TestCV:: \$buffer;
    ok( ( my $session = new WebDAO::SessionSH:: store => $store_ab, cv=>$cv ),
        "Create session" );
    $session->U_id("sdsd");
    my $eng = new WebDAO::Engine:: session => $session;
    $t->{tlib} = new WebDAO::Test eng => $eng;
    undef
}

sub teardown : Test(teardown) {
    my $t = shift;
    delete $t->{tlib};
}
1;

