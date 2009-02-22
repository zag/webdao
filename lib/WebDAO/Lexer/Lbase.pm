package WebDAO::Lexer::Lbase;
#$Id$

=head1 NAME

WebDAO::Lexer::Lbase - Base class for lexems 

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Lexer::Lbase - Base class for lexems

=cut

use WebDAO::Base;
use Data::Dumper;
use base qw( WebDAO::Base );
use strict;
__PACKAGE__->attributes qw/ all  /;

sub _init() {
    my $self = shift;
    return $self->Init(@_);
}

sub Init {
    #Parametrs is realm
    my $self = shift;
    my %par  = @_;
    delete $par{context};
    $self->all( \%par );
    return %par;
}

sub get_self {
    return $_[0];
}

sub childs {
    my $self = shift;
    return $self->all->{childs} || [];
}

sub value {
    my $self = shift;
    my $eng  = shift;
    my $par  = $self->all;
    my $res;
    if ( exists $par->{value} ) {
        $res = $par->{value};
    }
    else {
        my @val = @{ $self->childs }
          ? do {
            map { $_->value($eng) } @{ $self->childs };
          }
          : ();
        $res = @val > 1 ? \@val : $val[0];
    }
    return ( $par->{name}, $res );
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
