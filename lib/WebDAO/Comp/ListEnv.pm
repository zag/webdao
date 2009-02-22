package WebDAO::Comp::ListEnv;
#$Id$

=head1 NAME

WebDAO::Comp::ListEnv - Output %ENV hash

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Comp::ListEnv - Output %ENV hash

=cut

use base qw(WebDAO::Component);

sub pre_format {
    my $self = shift;
    my @Out  = <<END;
<table border="1" align="center">
END
    return \@Out;
}

sub format {
    my $self = shift;
    my ( $p1, $p2 ) = split( /\|/, shift );
    return "<tr><td>$p1</td><td><b>$p2</b></td></tr>";
}

sub post_format {
    my $self = shift;
    return ["</table>"];
}

sub fetch {
    my $self = shift;
    foreach $var ( sort( keys(%ENV) ) ) {
        $val = $ENV{$var};
        $val =~ s|\n|\\n|g;
        $val =~ s|"|\\"|g;
        push( @Out, "${var}|${val}" );
    }
    return \@Out;
}
1;
__DATA__

=head1 SEE ALSO

http://sourceforge.net/projects/webdao

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2009 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
