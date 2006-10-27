#$Id: Sessiondb.pm,v 1.2 2006/09/19 10:05:25 zag Exp $

package HTML::WebDAO::Sessiondb;
use Fcntl ":flock";
use IO::File;

#use MLDBM qw (DB_File Storable);
use MLDBM qw (DB_File Data::Dumper);

use HTML::WebDAO::Base;
use base qw( HTML::WebDAO::Sessionco );

#use tbase;
#use usessionco;
#@ISA="usessionco";
use strict 'vars';

sub load__ {
    my ( $self, $param ) = @_;
    my ( $id, $eng_name, $ref_tree ) =
      ( $param->{"id"}, $param->{"eng_name"}, $param->{"tree"} );

    #my $hash=Hash_db $self;
    my %hash;
    my $db_file = $self->Db_file;
    my $db      = tie %hash, "MLDBM", $db_file, O_CREAT | O_RDWR, 0644 or die "$!";
    my $fd      = $db->fd();
    undef $db;
    local *DBM;
    open DBM, "+<&=$fd" or die "$!";
    flock DBM, LOCK_SH;
    my $tmp_hash = $hash{$id}->{$eng_name};
    untie %hash;
    flock DBM, LOCK_UN;
    close DBM;

    return $tmp_hash;
}

sub store__ {
    my ( $self, $param ) = @_;
    my ( $id, $eng_name, $ref_tree ) =
      ( $param->{"id"}, $param->{"eng_name"}, $param->{"tree"} );
    my %hash;
    my $db_file = $self->Db_file;
    my $db      = tie %hash, "MLDBM", $db_file, O_CREAT | O_RDWR, 0644 or die "$!";
    my $fd      = $db->fd();
    undef $db;
    local *DBM;
    open DBM, "+<&=$fd" or die "$!";
    flock DBM, LOCK_EX;
    my $tmp_hash = $hash{$id};
    $tmp_hash->{$eng_name} = $ref_tree;
    $hash{$id} = $tmp_hash;
    untie %hash;
    flock DBM, LOCK_UN;
    close DBM;
    return $id;

    #my $self=shift;
    #my $param=shift;
    #my ($id,$eng_name,$ref_tree)=($param->{"id","eng_name","tree"});
    #local *DBM;
    #my $db=tie %hash,"MLDBM","test.db",O_CREAT|O_RDWR,0644 or die "$!";
    #my $fd=$db->fd();
    #open DBM, "+<&=$fd" or die "$!";
    #flock DBM, LOCK_EX;
    #undef $db;

    #untie %hash;
}
1;
