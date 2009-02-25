package WebDAO::Store::Storable;

#$Id$

=head1 NAME

WebDAO::Store::Storable - Implement session store using Storable

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Store::Storable - Implement session store using Storable

=cut


use Storable qw(lock_nstore lock_retrieve);
use WebDAO::Store::Abstract;
use strict 'vars';
use base 'WebDAO::Store::Abstract';

__PACKAGE__->attributes qw/ _dir _cache _is_loaded/;

sub init {
    my $self = shift;
    my %pars = @_;
    die "need param path to dir" unless exists $pars{path};
    my $dir = $pars{path};
    $dir .= "/" unless $dir =~ m%/$%;
    unless ( -d $dir ) {
    eval {
        mkpath( $dir, 0 );
        };
    if ($@) {   
        _log1 $self "error mkdir".$@
    }

    }
    $self->_dir($dir);
    my %hash;
    $self->_cache( \%hash );
    return 1;
}

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
sub _store_attributes {
    my $self  = shift;
    my $id    = shift || return;
    my $ref   = shift || return;
    my $cache = $self->_cache();
    while ( my ( $key, $val ) = each %$ref ) {
        $cache->{$key} = $val;
    }
}

sub _load_attributes {
    my $self = shift;
    my $id = shift || return;
    unless ( $self->_is_loaded ) {
        my $from_storage = $self->load($id);
        my $cache        = $self->_cache;
        while ( my ( $key, $val ) = each %$from_storage ) {
            next if exists $cache->{$key};
            $cache->{$key} = $val;
        }
        $self->_is_loaded(1);
    }
    my $loaded = $self->_cache;
    my %res;
    foreach my $key (@_) {
        $res{$key} = $loaded->{$key} if exists $loaded->{$key};
    }
    return \%res;
}

sub flush {
    my $self = shift;
    $self->store( @_, $self->_cache );
}

1;
