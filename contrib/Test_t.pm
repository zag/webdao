package Test_t;
use HTML::WebDAO::Component;
use base 'HTML::WebDAO::Component';

sub ___my_name {
    return "aaraer/aaa"
}

sub test_echo {
    my $self = shift;
    return @_
}

sub index_html {
    my $self = shift;
    return "aaaa"
}
1;
