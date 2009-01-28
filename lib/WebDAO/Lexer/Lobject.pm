#$Id$

package HTML::WebDAO::Lexer::Lobject;
use HTML::WebDAO::Lexer::Lbase;
use Data::Dumper;
use base qw( HTML::WebDAO::Lexer::Lbase );
use strict;

sub value {
    my $self = shift;
    my $eng  = shift;
    my $par  = $self->all;
    my @val  = map { $_->value($eng) } @{ $self->childs };
    if ($eng) {
        my $error;

        #check if alias
        unless ( $eng->_pack4name( $par->{class} ) ) {

            #try class as perl modulename
            $error = $eng->register_class( $par->{class} );

        }
        if ($error) {
            _log1 $self "use module $par->{class}, id: $par->{id} fail. $error";
            return
        }
        else {
            my $object = $eng->_createObj( $par->{id}, $par->{class}, @val );
            _log1 $self "create_obj fail for class: "
              . $par->{class}
              . " ,id: "
              . $par->{id}
              unless $object;

            return $object;
        }
    }
    return {"Object ( "
          . ( join ",", map { "$_ => " . $par->{$_} } keys %{$par} )
          . ")" => \@val };
}
1;

