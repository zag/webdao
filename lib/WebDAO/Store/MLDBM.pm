package WebDAO::Store::MLDBM;

#$Id$

=head1 NAME

WebDAO::Store::MLDBM - Implement session store using MLDBM

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Store::MLDBM - Implement session store using MLDBM

=cut

use File::Path;
use Fcntl ":flock";
use IO::File;
use MLDBM qw (DB_File Data::Dumper);
use WebDAO::Store::Storable
use Data::Dumper;
use strict 'vars';
use base 'WebDAO::Store::Storable';

sub load {
    my $self = shift;
    my $id = shift || return {};
    my %hash;
    my $db_file = $self->_dir() . "sess_$id.db";
    my $db = tie %hash, "MLDBM", $db_file, O_CREAT | O_RDWR, 0644 or die "$!";
    my $fd = $db->fd();
    undef $db;
    local *DBM;
    open DBM, "+<&=$fd" or die "$!";
    flock DBM, LOCK_SH;
    my $tmp_hash = $hash{$id};
    untie %hash;
    flock DBM, LOCK_UN;
    close DBM;
    return $tmp_hash;
}

sub store {
    my $self     = shift;
    my $id       = shift || return {};
    my $ref_tree = shift;
    return unless $ref_tree && ref($ref_tree);
    my %hash;
    my $db_file = $self->_dir() . "sess_$id.db";
    my $db = tie %hash, "MLDBM", $db_file, O_CREAT | O_RDWR, 0644 or die "$!";
    my $fd = $db->fd();
    undef $db;
    local *DBM;
    open DBM, "+<&=$fd" or die "$!";
    flock DBM, LOCK_EX;
    $hash{$id} = $ref_tree;
    untie %hash;
    flock DBM, LOCK_UN;
    close DBM;
    return $id;

}
1;
