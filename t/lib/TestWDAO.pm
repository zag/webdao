package TestWDAO;
use WebDAO::Element;
use base 'WebDAO::Element';
__PACKAGE__->attributes(qw/ __test1 _test2/);
__PACKAGE__->mk_sess_attr( _sess1=>1, _sess2=>3, _sess3=>undef, _sess4=>'undef');
__PACKAGE__->mk_attr( _prop1=>1, _prop2=>3, _prop3=>undef, _prop4=>'undef');


sub init {
    my $self = shift;
    _sess2 $self (3)
}
sub Echo {
    my $self = shift;
    return shift||111
}

1;
