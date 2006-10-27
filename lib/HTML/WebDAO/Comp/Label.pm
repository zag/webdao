#$Id: Label.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::Comp::Label;
use HTML::WebDAO::Base;
#@ISA="ucomponent";
use base qw(HTML::WebDAO::Component);
attributes qw(Par);
sub init{
my $self=shift;
$self->Par(shift);
}
sub pre_format{
my @out=<<END;
<table><tr><td>&nbsp;</td><td>
END
return \@out;
}


sub post_format{
my @out=<<END;
</td><td>&nbsp;<b>:</b>&nbsp;</td>
</tr><tr><td></td><td bgcolor="#000000" height="1">
</td><td></td></tr></table>
END
return \@out;
}
sub fetch {
my $self=shift;
$self->Par ? return [$self->Par] :return [];
}
1;
