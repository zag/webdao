#!/usr/bin/perl
use Test::More (no_plan);
use MyTest;
use Data::Dumper;
use WebDAO::Test;
#Создание root element 
my $eng = WebDAO::Test::t_get_engine( 't/index.xhtml');
#Объект с полезными методами
my $tlib = WebDAO::Test::t_get_tlib($eng);
isa_ok my $test = $tlib->get_by_path('/page'), 'MyTest';
is $test->echo(1), 1 , 'test method';
#diag $eng;


