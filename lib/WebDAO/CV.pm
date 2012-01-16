#===============================================================================
#
#  DESCRIPTION:  CGI controller
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$
package WebDAO::CV;
use URI;

use strict;
use warnings;

#deprecated 
sub query_string {};
sub referer {}


sub new {
    my $class = shift;
    bless( ( $#_ == 0 ) ? shift : {@_}, ref($class) || $class );
}

=head2 url (-options1=>1)

from url: http://testwd.zag:82/Envs/partsh.sd?23=23
where options:
    
    -path_info  -> /Envs/partsh.sd
    -base       -> http://example.com:82 

defaul http://testwd.zag:82/Envs/partsh.sd?23=23
    
=cut

sub url {
    my $self = shift;
    my %args = @_;
    my $env  = $self->{env};

    if ( exists $env->{FCGI_ROLE} ) {
        ( $env->{PATH_INFO}, $env->{QUERY_STRING} ) =
          $env->{REQUEST_URI} =~ /([^?]*)(?:\?(.*)$)?/s;

        #warn Dumper( [ $env->{PATH_INFO}, $env->{QUERY_STRING} ] );
    }
    my $path  = $env->{PATH_INFO};       # 'PATH_INFO' => '/Env'
    my $host  = $env->{HTTP_HOST};       # 'HTTP_HOST' => '127.0.0.1:5000'
    my $query = $env->{QUERY_STRING};    # 'QUERY_STRING' => '434=34&erer=2'
    my $proto     = $env->{'psgi.url_scheme'} || 'http';
    my $full_path = "$proto://${host}${path}?$query";

    #clear / at end
    $full_path =~ s!/$!! if $path =~ m!^/!;
    my $uri = URI->new($full_path);

    #    return "$full_path";
    if ( exists $args{-path_info} ) {
        return $uri->path();
    }
    elsif ( exists $args{-base} ) {
        return "$proto://$host";
    }
    return URI->new($full_path)->canonical;
}

=head2 method

retrun HTTP method

=cut

sub method {
    my $self = shift;
    $self->{env}->{REQUEST_METHOD} || "GET";
}

=head2

return hashref

    {
           'application/xhtml+xml' => undef,
           'application/xml' => undef,
           'text/html' => undef
      };


=cut
sub accept {
    my $self = shift;
    my $accept = $self->{env}->{HTTP_ACCEPT} || return {};
    my ($types) = split( ';', $accept );
    my %res;
    @res{ split( ',', $types ) } = ();
    \%res;
}

1;


