#$Id: MLDBM.pm,v 1.2 2006/09/19 10:05:25 zag Exp $

package HTML::WebDAO::Store::MLDBM;
use File::Path;
use Fcntl ":flock";
use IO::File;
use MLDBM qw (DB_File Data::Dumper);
use HTML::WebDAO::Store::Abstract;
use Data::Dumper;
use strict 'vars';
use base 'HTML::WebDAO::Store::Abstract';
__PACKAGE__->attributes qw/ _dir _cache /;

sub init {
    my $self = shift;
    my %pars = @_;
    die "need param path to dir" unless exists $pars{path};
    my $dir = $pars{path};
    $dir .= "/" unless $dir =~ m%/$%;
    unless (-d $dir) {
        _log4 $self "create dir for store";
        mkpath($dir,0)
    }
    $self->_dir($dir);
    my %hash;
    $self->_cache(\%hash);
    return 1
}

sub load {
    my $self =shift;
    my $id = shift || return {};
    my %hash;
    my $db_file = $self->_dir()."sess_$id.db";
    my $db      = tie %hash, "MLDBM", $db_file, O_CREAT | O_RDWR, 0644 or die "$!";
    my $fd      = $db->fd();
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
    my $self =shift;
    my $id = shift || return {};
    my $ref_tree = shift;
    return unless $ref_tree && ref($ref_tree);
    my %hash;
    my $db_file = $self->_dir()."sess_$id.db";
    my $db      = tie %hash, "MLDBM", $db_file, O_CREAT | O_RDWR, 0644 or die "$!";
    my $fd      = $db->fd();
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
sub _store_attributes {
    my $self = shift;
    my $id = shift || return;
    my $ref = shift || return;
    my $cache = $self->_cache();
    while ( my ($key,$val) = each %$ref ) {
        $cache->{$key} = $val
    }
}
sub _load_attributes {
    my $self  = shift;
    my $id = shift || return;
    my $loaded = $self->load($id);
    my %res;
    foreach my $key ( @_ ) {
        $res{$key} = $loaded->{$key} if exists $loaded->{$key};
    }
    return \%res
}
sub flush {
    my $self = shift;
    $self->store(@_,$self->_cache)
}
1;
