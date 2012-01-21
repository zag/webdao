#===============================================================================
#
#  DESCRIPTION:  Refacred Response object
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package WebDAO::Response0;
use strict;
use warnings;
use base 'WebDAO::Response';

__PACKAGE__->mk_attr( status => 200 );

=head2 set_header NAME, VALUE

Set out header:

        $response->set_header('Location', $redirect_url);
        $response->set_header( -type => 'text/html; charset=utf-8' );

return $self reference

=cut

sub set_header {
    my ( $self, $name, $par ) = @_;
    #translate CGI headers
    if ( $name =~ /^-/) {
            my $UKey = uc $name;
            
            if ( $UKey eq '-STATUS' ) {
                my ($status) = $par =~ m/(\d+)/;
                $self->status($status);
                return; #don't save status
            }

            use CGI;
            my $h = CGI->new->header( $UKey, $par );
            $h =~ s/\015\012//g;
            ( $name, $par ) = split( /\s*:\s*/, $h );
    }
        
    $self->_headers->{ $name } = $par;
    $self;
}

=head2 print_header

print header.return $self reference

=cut

sub print_header {
    my $self  = shift;
    my $pnted = $self->_is_headers_printed;
    return $self if $pnted;
    my $cv      = $self->_cv_obj;
    $cv->status($self->status);
    $cv->print_headers(%{ $self->_headers });
    $self->_is_headers_printed(1);
    $self;
}
1;

