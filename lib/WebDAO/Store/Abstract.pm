#$Id$

package WebDAO::Store::Abstract;
use WebDAO::Base;
use Data::Dumper;
use strict;
@WebDAO::Store::Abstract::ISA = ('WebDAO::Base');
sub _init {
    my $self = shift;
    return $self->init(@_);
}
sub init {
    return 1
}
sub load { {} }
sub store { {} }
sub _load_attributes {
    my $self = shift;
    return {}
}
sub _store_attributes {
    my $self = shift;
    return {}
}
sub flush { #$_[0]->_log1("flush")
}

1;
