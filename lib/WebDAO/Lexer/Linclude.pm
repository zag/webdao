package WebDAO::Lexer::Linclude;
#$Id$

=head1 NAME

WebDAO::Lexer::Linclude - Process Linclide tag

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Lexer::Linclude - Process Linclide tag

=cut


use WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( WebDAO::Lexer::Lbase );
use strict;
__PACKAGE__->attributes qw/ ret_obj /;

sub Init {
    my $self   = shift;
    my %par    = @_;
    my ($file) = $par{file};
    unless ($file) {
        _log1 $self "Syntax error: include - not initialized file attribute";
        return;
    }
    unless ( -e $file ) {
        _log2 $self "File $file not found";
        return;
    }
    open FH, "<$file" or die $!;
#    open FH, "<:utf8","$file" or die $!;
    my $str;
    {
        local $/;
        $/   = undef;
        $str = <FH>
    }
    close FH;
    my $context = $par{context};
    $self->ret_obj( [] );
    if ($context) {
        $self->ret_obj( $context->buld_tree($str) );
    }
    $self->SUPER::Init(@_);
}

sub get_self {
    my $self = shift;
    return @{$self->ret_obj}
}

1;
