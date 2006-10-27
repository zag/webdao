#$Id: Activator.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::Activator;
use Data::Dumper;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Container);
attributes qw(ActiveItem);
@Desc=("uactivator","","Dynamic content manager");
use strict 'vars';

sub _sysinit{
my $self=shift;
#First invoke parent _init;
$self->SUPER::_sysinit(@_);
#Store subtree of parametrs for use at later when 
#store switch of objects
$self->_runtime("_stored_items",{});

#store map of objects
$self->_runtime("_stored_map",{});
}



#for build scene ivoke with ref to array of arrays
#[[
#{
#   name => label_main1,#Name of object
#   type => label,#Type of object
#   par  =>[qw(Main contents)]
#	},
#{
#   name => label_main1,#Name of object
#   type => label,#Type of object
#   par  =>[qw(Main contents)]
#	},
#]]
# or with ref to hash of arrays
#{item1=>[{
#   name => label_main1,#Name of object
#   type => label,#Type of object
#   par  =>[qw(Main contents)]
#	},{
#   name => label_main1,#Name of object
#   type => label,#Type of object
#   par  =>[qw(Main contents)]
#	}]
#}

sub Init{
my ($self,$items_hash)=@_;
my $hash={
	0=>[{
		name=>"text",
		type=>"_rawhtml_element",
		par=>"<b>None</b>"
		}]
};
#ref($items_hash) && do {
#	for (ref($items_hash)) {
#	/ARRAY/ && do {
#		my $i=0;
#			foreach my $rec (@{$items_hash}) {
#		$$hash{$i++}=$rec;
#			}#foreach
#		} 
#	||
#	/HASH/ && do {
#		$hash=$items_hash;
#		}
#	}#for
#};#do
#Items $self $self->ref2str($hash);
#my $hash_a = $self->ItemsRuntime();
#ActiveItem $self (keys %$hash_a)[0];
$self->InitItems(ref ($items_hash) ?$items_hash :$hash);
my $hash_a = $self->ItemsRuntime();
ActiveItem $self (keys %$hash_a)[0];

}

sub  InitItems {
my ($self,$items_hash)=@_;
my $hash={};
ref($items_hash) && do {
	for (ref($items_hash)) {
	/ARRAY/ && do {
		my $i=0;
			foreach my $rec (@{$items_hash}) {
		$$hash{$i++}=$rec;
			}#foreach
		} 
	||
	/HASH/ && do {
		$hash=$items_hash;
		}
	}#for
};#do
###Items $self $self->ref2str($hash);
Items $self $hash;
}

#set get Items at runtime 	
sub ItemsRuntime {
my ($self,$par)=@_;
if ($par) {$self->_runtime("_stored_items",$par)}
return $self->_runtime("_stored_items")
}

sub MapRuntime{
my ($self,$par)=@_;
if ($par) {$self->_runtime("_stored_map",$par)}
return $self->_runtime("_stored_map")
}

sub Items {
my ($self,$par)=@_;
if ($par) {
###	$self->ItemsChanged($self->str2ref($par));
	$self->ItemsChanged($par);
} else {
die Dumper(caller(1))."!!!!!";}
#return $self->ref2str($self->ItemsRuntime());
}

sub ItemsChanged {
my ($self,$items)=@_;
#now create objects
my $engine_ref=$self->GetEngine();
foreach my $key (keys %$items)  {
		#create container
		my $container=$engine_ref->_createObj($key,'ucontainer');
		#now add him to our
		$self->AddChild($container);
		#store container into our map
		$self->MapRuntime()->{$key}=$container;
	foreach my $rec (@{$$items{$key}}) {
		#next step push into container objects
		my $obj=$engine_ref->_createObj($rec->{name},$rec->{type},@{$rec->{par}});
		$container->AddChild($obj) if ref($obj);
		}
	}
$self->ItemsRuntime($items);
}
sub GetActiveItems {
my ($self)=@_;
return keys %{$self->ItemsRuntime()};
}
sub ActiveItem {
my ($self,$par)=@_;
my $item;
if ($par) {
	$self->set_attribute("ActiveItem",$par)
 } else {
	#check non exists Items
	 $item=$self->get_attribute("ActiveItem");
	 my $hash_ref=$self->MapRuntime();
   	 $item = (keys %$hash_ref)[0] unless exists($hash_ref->{$item});
	 return $item
		}
}
#Fetch only active item
sub Fetch {
my $self=shift;
my $ref=$self->MapRuntime()->{$self->ActiveItem()};
return ref($ref) ? $ref->Fetch() :[];
}

1;
