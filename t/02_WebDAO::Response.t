# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More ( tests => 39 );
use Data::Dumper;
use strict;

BEGIN {
    use_ok('WebDAO');
    use_ok('WebDAO::Store::Abstract');
    use_ok('WebDAO::SessionSH');
    use_ok('WebDAO::Response');
    use_ok( 'File::Temp', qw/ tempfile tempdir / );
}
my $ID = "tcontainer";
ok my $store_ab = ( new WebDAO::Store::Abstract:: ), "Create store";
ok my $session = ( new WebDAO::SessionSH:: store => $store_ab ),
  "Create session";
$session->U_id($ID);
isa_ok my $response =
  ( new WebDAO::Response:: session => $session, cv => $session->Cgi_obj ),
  'WebDAO::Response', 'create object';
isa_ok $response->_cv_obj, 'WebDAO::CVcgi', 'check cv class';

isa_ok my $resp1 = $response->set_header( "-status", '403 Forbidden' ),
  'WebDAO::Response', 'check type set_header';
is_deeply { '-STATUS' => '403 Forbidden' }, $response->_headers,
  'check _headers';
isa_ok $resp1->set_header( -type => 'text/html; charset=utf-8' ),
  'WebDAO::Response', 'check type set_header';
is_deeply {
    '-TYPE'   => 'text/html; charset=utf-8',
    '-STATUS' => '403 Forbidden'
  },
  $response->_headers, 'check _headers after set set_header';
ok !$response->_is_headers_printed, 'check flg _is_headers_printed before';
isa_ok $response->print_header, 'WebDAO::Response', 'check type print_header';
ok $response->_is_headers_printed, 'check flg _is_headers_printed before';

isa_ok my $response1 =
  ( new WebDAO::Response:: session => $session, cv => $session->Cgi_obj )
  ->redirect2url('http://test.com'), 'WebDAO::Response',
  'test redirect2url';
is_deeply { '-LOCATION' => 'http://test.com', '-STATUS' => '302 Found' },
  $response1->_headers, 'check redirect2url headers';

isa_ok my $response2 =
  ( new WebDAO::Response:: session => $session, cv => $session->Cgi_obj )
  ->set_cookie(
    -name  => 'name1',
    -value => 'test1',
    -path  => "/path1"
  )->set_cookie(
    -name  => 'name2',
    -value => 'test2',
    -path  => "/path2"
  ),
  'WebDAO::Response', 'test set_cookie';
ok ref $response2->get_header('-cookie'), "check get_header('-cookie')";
ok scalar @{ $response2->get_header('-cookie') } == 2,
  "check count cookie == 2";

#create test files
my ( $fh, $filename ) = tempfile();
print $fh "test\n";
close $fh;
isa_ok my $response3 =
  ( new WebDAO::Response:: session => $session, cv => $session->Cgi_obj )
  ->send_file( $filename, -type => 'image/jpeg' ), 'WebDAO::Response',
  'test send_file';
ok $response3->_is_file_send,     'check $response3->_is_file_send';
ok $response3->_is_need_close_fh, 'check $response3->_is_need_close_fh';
is $response3->get_mime_for_filename('test.jpg'), 'image/jpeg',
  'get_mime_for_filename("test.jpg")';

ok !$response3->_is_flushed, 'check $response3->_is_flushed before flush';
isa_ok $response3->flush, 'WebDAO::Response', '$response3->flush';
ok $response3->_is_flushed, 'check $response3->_is_flushed after flush';

my $test_call_back1 = 1;
my $test_call_back2 = 2;
isa_ok my $response4 =
  ( new WebDAO::Response:: session => $session, cv => $session->Cgi_obj )
  ->set_callback( sub { $test_call_back1++ } )
  ->set_callback( sub { $test_call_back2++ } ), 'WebDAO::Response',
  'test set_callaback';
isa_ok $response4->flush, 'WebDAO::Response', '$response3->flush';
is $test_call_back1, 2, '$test_call_back1';
is $test_call_back2, 3, '$test_call_back2';

isa_ok my $response5 =
  ( new WebDAO::Response:: session => $session, cv => $session->Cgi_obj ),
  'WebDAO::Response', 'get format';

is $response5->wantformat(), 'html', 'check default wantformat';
ok $response5->wantformat('html'), 'check wantformat("html") eq html';
ok !$response5->wantformat('csv'), 'check wantformat("csv") ne csv';

isa_ok my $response6 =
  ( new WebDAO::Response:: session => $session, cv => $session->Cgi_obj )->wantformat(json=>1),
  'WebDAO::Response', 'set force wantformat(json=>1)';
is $response6->wantformat(), 'json', 'check default wantformat for forced json';
ok !$response6->wantformat('html'), 'check wantformat("html") eq html for forced json';


#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

