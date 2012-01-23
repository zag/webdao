#===============================================================================
#
#  DESCRIPTION:  Test Controller
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

package Test::Writer;
sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}
sub write { ${ $_[0]->{out} } . $_[1] }
sub close { }
sub headers { return { @{ $_[0]->{headers} } } }

1;

use strict;
use warnings;

sub make_cv {
my %args = @_;
my $out;
my $cv = WebDAO::CV->new(
    env => $args{env},
    writer => sub {
        new Test::Writer::
          out     => \$out,
          status  => $_[0]->[0],
          headers => $_[0]->[1];
    }
);
    
}
#use Test::More tests => 1;                      # last test to print
use Test::More 'no_plan';
use_ok('WebDAO::CV');
my $out  = '';
my $fcgi = WebDAO::CV->new(
    env => {
        'FCGI_ROLE'      => 'RESPONDER',
        'REQUEST_URI'    => '/Envs/partsh.sd?23=23',
        'HTTP_HOST'      => 'example.com:82',
        'QUERY_STRING'   => '23=23',
        'REQUEST_METHOD' => 'GET',
        'HTTP_ACCEPT' =>
          'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
        'HTTP_COOKIE' => 'tesrt=val; Yert=Terst',
      
    },
    writer => sub {
        new Test::Writer::
          out     => \$out,
          status  => $_[0]->[0],
          headers => $_[0]->[1];
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
is_deeply {
    map { $_ => $fcgi->param($_) } $fcgi->param()
}, { '23' => '23' }, 'GET params';

$fcgi->set_header( "Content-Type" => 'text/html; charset=utf-8' );
my $wr = $fcgi->print_headers();

is_deeply $wr->{headers},
  [ 'Content-Type' => 'text/html; charset=utf-8' ], "set headers";
is $wr->{status}, 200, 'Status: 200';

use_ok('WebDAO::Response0');
my $cv1 = &make_cv;
my $r = new WebDAO::Response0:: cv=>$cv1;
$r->content_type('text/html; charset=utf-8');
$r->content_length(2345);
$r->set_cookie({name=>'test', value=>1});
use Data::Dumper;

diag Dumper ($r->print_header()->_headers);
is_deeply $r->print_header()->_headers , {
           'Content-Length' => 2345,
           'Content-Type' => 'text/html; charset=utf-8'
         };

exit;



use CGI;
my $c = new CGI;
my $q1 = $c->cookie(        {
            -NAME    => "srote",
            -EXPIRES => "+3M",
            -PATH    => "/Err",
            -VALUE   => { "1"=>"2", "ewe"=>1}
        }
);
my $q2 = $c->cookie(        {
            -NAME    => "olol",
            -EXPIRES => "+3M",
            -PATH    => "/",
            -VALUE   => "oh"
        }
);
my $q3 = $c->cookie(        {
            -NAME    => "olol",
            -EXPIRES => "+3M",
            -PATH    => "/",
            -VALUE   => "ohhhhhh"
        }
);
use Data::Dumper;
diag Dumper $q2;
diag $c->header(-cookie=>[$q1, $q2, $q3]);
diag Dumper  $cv1->{fd}->headers;

package WebDAO::CV;
use Data::Dumper;

=head2 get_cookie 

=cut

sub get_cookie {
    my $self = shift;
}

1;


#use CGI;;
#print CGI->new()->header(-status=>'200 Not Found');

