#$Id$

package WebDAO;

use strict;
use warnings;
use WebDAO::Base;
use WebDAO::Element;
use WebDAO::Component;
use WebDAO::Container;
use WebDAO::Engine;
use WebDAO::Session;
use WebDAO::Sessionco;
use WebDAO::Lib::RawHTML;
our @ISA = qw();

our $VERSION = '2.15';



1;
__END__

=head1 NAME

WebDAO - platform for easy creation of high-performance and scalable web applications

=head1 SYNOPSIS

  use WebDAO;

=head1 DESCRIPTION

There are many environments in which the web applications work: 

    ---------------------------------------------
    |                         PSGI              |
    | FastCGI                                   |
    |           ------------------------        |
    |     nginx |                      |        |
    |           |     Your code        | isapi  |
    |           |                      |        |
    |            ----------------------         |
    |  Shell            Test::More      IIS     |
    |        lighttpd                           |
    ---------------------------------------------

WebDAO designed to save developers from the details of the application environment, reduce costs with a change of environment, and to simplify debugging and testing applications. An important goal is to simplify and increase the speed of web development.

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2012 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
