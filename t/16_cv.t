#===============================================================================
#
#  DESCRIPTION:  Test Controller
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package WebDAO::CV;
use Data::Dumper;


1;

use strict;
use warnings;

#use Test::More tests => 1;                      # last test to print
use Test::More 'no_plan';
use_ok('WebDAO::CV');
my $fcgi = WebDAO::CV->new(
    env => {
        'FCGI_ROLE'      => 'RESPONDER',
        'REQUEST_URI'    => '/Envs/partsh.sd?23=23',
        'HTTP_HOST'      => 'example.com:82',
        'QUERY_STRING'   => '23=23',
        'REQUEST_METHOD' => 'GET',
        'HTTP_ACCEPT' =>
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    }
);

is $fcgi->url( -path_info => 1 ), '/Envs/partsh.sd',       '-path-info';
is $fcgi->url( -base      => 1 ), 'http://example.com:82', '-base';
is $fcgi->url(), 'http://example.com:82/Envs/partsh.sd?23=23', 'url()';
is $fcgi->method(), 'GET', 'method()';
is_deeply $fcgi->accept,
  {
    'application/xhtml+xml' => undef,
    'application/xml'       => undef,
    'text/html'             => undef
  },
  'accept';

is_deeply $fcgi->param(), { '23' => '23' }, 'GET params';
print Dumper $fcgi->set_header("Content_Type" => 'text/html; charset=utf-8')
