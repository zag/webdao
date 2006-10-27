#$Id: Lex.pm,v 1.5 2006/10/27 08:59:08 zag Exp $

package HTML::WebDAO::Lex;
use XML::LibXML;
use Data::Dumper;
use HTML::WebDAO::Lobject;
use HTML::WebDAO::Lbase;
use HTML::WebDAO::Lregclass;
use HTML::WebDAO::Lobjectref;
use HTML::WebDAO::Ltext;
use HTML::WebDAO::Linclude;
use HTML::WebDAO::Lmethod;
use HTML::WebDAO::Base;
use base qw( HTML::WebDAO::Base );
__PACKAGE__->attributes qw/ engine tree auto / ;
use strict;

sub _init() {
    my $self = shift;
    return $self->Init(@_);
}

sub Init {
    my $self = shift;
    my %par  = @_;
    $self->engine( $par{engine} );
    $self->auto( [] );
    $self->tree( $self->buld_tree( $par{content} ) ) if $par{content};
    return 1;
}

sub buld_tree {
    my $self     = shift;
    my $raw_html = shift;

    #Mac and DOS line endings
    $raw_html =~ s/\r\n?/\n/g;
    my $mass;
    $mass = [ split( /(<WD>.*?<\/WD>)/is, $raw_html ) ];
    my @res;
    foreach my $text (@$mass) {
        my @ref;
        unless ( $text =~ /^<wd/i ) {
            push @ref,
              HTML::WebDAO::Lobject->new(
                class   => "_rawhtml_element",
                id      => "none",
                childs  => [ HTML::WebDAO::Ltext->new( value => \$text ) ],
                context => $self
              )  unless $text =~/^\s*$/;
        }
        else {
            my $parser = new XML::LibXML;
            my $dom    = $parser->parse_string($text);
            push @ref, $self->get_obj_tree( $dom->documentElement->childNodes );

        }
        next unless @ref;
        push @res, @ref;
    }
    return \@res;
}

sub get_obj_tree {
    my $self = shift;
    my %map  = (
        object    => 'HTML::WebDAO::Lobject',
        regclass  => 'HTML::WebDAO::Lregclass',
        objectref => 'HTML::WebDAO::Lobjectref',
        text      => 'HTML::WebDAO::Ltext',
        include   => 'HTML::WebDAO::Linclude',
        default   => 'HTML::WebDAO::Lbase',
        method    => 'HTML::WebDAO::Lmethod'
    );
    my @result;
    foreach my $node (@_) {
        my $node_name = $node->nodeName;
        my %attr      = map { $_->nodeName => $_->value } grep { defined $_ } $node->attributes;
        my $map_key   = $node->nodeName || 'text';
        $attr{name} = $map_key unless exists $attr{name};
        if ( $map_key eq 'text' ) { $attr{value} = $node->nodeValue }
        my $lclass = $map{$map_key} || $map{default};
        my @vals = ();
        if ( my @childs = $node->childNodes ) {
            @vals = grep { defined $_ } $self->get_obj_tree(@childs);
        }
        my $lobject = $lclass->new( %attr, childs => \@vals, context => $self ) || next;
        if ( my @res = grep { ref($_) } ( $lobject->get_self ) ) {
            push @result, @res;
        }
    }
    return @result;

}
1;
