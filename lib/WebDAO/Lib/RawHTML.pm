#$Id$

package WebDAO::Lib::RawHTML;
use WebDAO::Base;
use base qw(WebDAO::Component);
attributes (_raw_html);
sub init {
    my ($self,$ref_raw_html)=@_;
   _raw_html $self $ref_raw_html;
}
sub fetch {
  my $self=shift;
  return ${$self->_raw_html};
}

1;
