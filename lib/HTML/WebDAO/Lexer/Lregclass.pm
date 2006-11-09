#$Id: Lregclass.pm,v 1.2 2006/09/19 10:05:25 zag Exp $

package HTML::WebDAO::Lexer::Lregclass;
use HTML::WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( HTML::WebDAO::Lexer::Lobject );
use strict;

sub Init {
    my $self = shift;
    my %par  = @_;
    if ( my $context = $par{context} ) {
        push @{ $context->auto }, $self;
    }
    $self->SUPER::Init(@_);
}

sub get_self {
    return undef;
}

sub value {
    my $self = shift;
    my $eng  = shift;
    my $par  = $self->all;
    my ( $class, $alias ) = @$par{qw/class alias/};
    unless ( $class && $alias ) {
        _log1 $self "Syntax error: regclass - not initialized class or alias";
        return;
    }
    if ( my $error_str = $eng->register_class( $class => $alias ) ) {
        _log1 $self $error_str;
    }

}

sub get_values {
    my $self = shift;
    my $par  = $self->all;
    my ( $class, $alias ) = @$par{qw/class alias/};
    unless ( $class && $alias ) {
        logmsgs $self "Syntax error: regclass - not initialized class or alias";
        return;
    }
    unless ( my $eng = $self->engine ) { return \$par }

    else {
        if ( my $error_str = $eng->register_class( $class => $alias ) ) {
            logmsgs $self $error_str;
        }
    }
}

1;
