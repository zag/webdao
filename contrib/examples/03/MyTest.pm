package MyTest;
use WebDAO;
use base 'WebDAO::Component';

sub fetch {
    "Hello Web X.0!";
}

sub echo {
    my $self = shift;
    return @_
}
1;
