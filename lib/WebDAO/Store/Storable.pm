package WebDAO::Store::Storable;

#$Id$

=head1 NAME

WebDAO::Store::Storable - Implement session store using Storable

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Store::Storable - Implement session store using Storable

=cut


use Storable qw(lock_nstore lock_retrieve);
use WebDAO::Store::MLDBM;
use strict 'vars';
use base 'WebDAO::Store::MLDBM';

sub load {
    my $self =shift;
    my $id = shift || return {};
    my $db_file = $self->_dir()."sess_$id.sdb";
    return {} unless -e $db_file;
    return lock_retrieve($db_file);
}

sub store {
    my $self =shift;
    my $id = shift || return {};
    my $ref_tree = shift;
    return unless $ref_tree && ref($ref_tree);
    my $db_file = $self->_dir()."sess_$id.sdb";
    lock_nstore($ref_tree,$db_file);
    return $id;
}
1;
