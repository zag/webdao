#$Id$

package HTML::WebDAO::Lexer::Linclude;
use HTML::WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( HTML::WebDAO::Lexer::Lbase );
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

sub get_values {
    my $self   = shift;
    my $par    = $self->all;
    my ($file) = $par->{file};
    unless ($file) {
        logmsgs $self "Syntax error: include - not initialized file attribute";
        return;
    }
    unless ( -e $file ) {
        logmsgs $self "File $file not found";
        return;
    }
    open FH, "<$file" or die $!;
    my $str;
    {
        local $/;
        $/   = undef;
        $str = <FH>
    }
    close FH;

    unless ( my $eng = $self->engine ) { return \$par }
    else {
        my @objects = @{ $eng->_parse_html($str) };

        #        _log1 $self  "INCLUDE DATA: $str";
        #        _log1 $self "OBJECTS:". join ","=> @objects;
        return @objects;
    }

}

1;
