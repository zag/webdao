package WebDAO::Fcgi::Writer;
use strict;
use warnings;
sub new {
    my $class = shift;
    my $self = bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}
sub write   { shift; print  STDOUT @_ }
sub close   { }
sub headers { return $_[0]->{headers} }

1;

package WebDAO::CVfcgiutf8;
#$Id$

=head1 NAME

WebDAO::CVfcgiutf8 - Fix output utf8 encoding (FCGI > 0.68)

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::CVfcgiutf8 - Fix output utf8 encoding for FCGI version > 0.68

=cut

my %StatusCode = (
    100 => 'Continue',
    101 => 'Switching Protocols',
    102 => 'Processing',                      # RFC 2518 (WebDAV)
    200 => 'OK',
    201 => 'Created',
    202 => 'Accepted',
    203 => 'Non-Authoritative Information',
    204 => 'No Content',
    205 => 'Reset Content',
    206 => 'Partial Content',
    207 => 'Multi-Status',                    # RFC 2518 (WebDAV)
    300 => 'Multiple Choices',
    301 => 'Moved Permanently',
    302 => 'Found',
    303 => 'See Other',
    304 => 'Not Modified',
    305 => 'Use Proxy',
    307 => 'Temporary Redirect',
    400 => 'Bad Request',
    401 => 'Unauthorized',
    402 => 'Payment Required',
    403 => 'Forbidden',
    404 => 'Not Found',
    405 => 'Method Not Allowed',
    406 => 'Not Acceptable',
    407 => 'Proxy Authentication Required',
    408 => 'Request Timeout',
    409 => 'Conflict',
    410 => 'Gone',
    411 => 'Length Required',
    412 => 'Precondition Failed',
    413 => 'Request Entity Too Large',
    414 => 'Request-URI Too Large',
    415 => 'Unsupported Media Type',
    416 => 'Request Range Not Satisfiable',
    417 => 'Expectation Failed',
    422 => 'Unprocessable Entity',            # RFC 2518 (WebDAV)
    423 => 'Locked',                          # RFC 2518 (WebDAV)
    424 => 'Failed Dependency',               # RFC 2518 (WebDAV)
    425 => 'No code',                         # WebDAV Advanced Collections
    426 => 'Upgrade Required',                # RFC 2817
    449 => 'Retry with',                      # unofficial Microsoft
    500 => 'Internal Server Error',
    501 => 'Not Implemented',
    502 => 'Bad Gateway',
    503 => 'Service Unavailable',
    504 => 'Gateway Timeout',
    505 => 'HTTP Version Not Supported',
    506 => 'Variant Also Negotiates',         # RFC 2295
    507 => 'Insufficient Storage',            # RFC 2518 (WebDAV)
    509 => 'Bandwidth Limit Exceeded',        # unofficial
    510 => 'Not Extended',                    # RFC 2774
);


use WebDAO::CVcgi;
use base qw( WebDAO::CV );
use strict;
sub new {
    my $class = shift;
    return $class->SUPER::new(@_, writer=> sub {
        my $code = $_[0]->[0];
        my $headers_ref  = $_[0]->[1];
        my $fd = new WebDAO::Fcgi::Writer:: headers=>$headers_ref;
        my $header_str= "Status: $code $StatusCode{$code}\015\012";
        while ( my ($header, $value) = splice( @$headers_ref, 0, 2) ) {
            $header_str .= "$header: $value\015\012"
        }
        $header_str .="\015\012";
        $fd->write($header_str);
        return $fd
    } )
}
sub print {
    my $self = shift;
    foreach my $str (@_) {
        utf8::encode( $str) if utf8::is_utf8($str);
        print $str;
   }
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
