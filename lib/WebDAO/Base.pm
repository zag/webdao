package WebDAO::Base;
our $VERSION = '0.01';

=head1 NAME

WebDAO::Base - Base class

=head1 SYNOPSIS

=head1 DESCRIPTION

WebDAO::Base - Base class

=cut

use Data::Dumper;
use Carp;
@WebDAO::Base::ISA    = qw(Exporter);
@WebDAO::Base::EXPORT = qw(mk_attr mk_route);
$DEBUG = 0;    # assign 1 to it to see code generated on the fly

=head2 mk_attr ( _attr1=>'default value', __attr2=>undef, __attr2=>1)

Make accessor for class attribute

 use WebDAO;
 mk_attr( _session=>undef, __obj=>undef, __events=>undef);


=cut

sub mk_attr {
    my ($pkg) = caller;
    shift if $_[0] =~ /\:\:/ or $_[0] eq $pkg;
    my %attrs = @_;
    %{"${pkg}::_WEBDAO_ATTRIBUTES_"} = %attrs;
    my $code = "";
    foreach my $attr ( keys %attrs ) {

        # If the accessor is already present, give a warning
        if ( UNIVERSAL::can( $pkg, "$attr" ) ) {
            carp "$pkg already has method: $attr";
            next;
        }
        $code .= _define_attr_accessor( $pkg, $attr, $attrs{$attr} );
    }
    eval $code;
    if ($@) {
        die "ERROR defining and attributes for '$pkg':"
          . "\n\t$@\n"
          . "-----------------------------------------------------"
          . $code;
    }
}

=head2 mk_route ( 'route1'=> 'Class::Name', 'route2'=> sub { return new My::Class() })

Make route table for object

 use WebDAO;
 mk_route( 
    user=>'MyClass::User', 
    test=>sub { return  MyClass->new( param1=>1 ) }
   );

=cut

sub mk_route {
    my ($pkg) = caller;
    shift if $_[0] =~ /\:\:/ or $_[0] eq $pkg;
    my %attrs = @_;
    no strict 'refs';
    while ( my ( $route, $class  ) = each %attrs ) {

        #check non loaded mods
        my ( $main, $module ) = $class =~ m/(.*\:\:)?(\S+)$/;
        $main ||= 'main::';
        $module .= '::';
        unless ( exists $$main{$module} ) {
            eval "use $class";
            if ($@) {
                carp "Error make route for for class :$class with $@ ";
            }
        }
    }
    %{"${pkg}::_WEBDAO_ROUTE_"} = %attrs;
    use strict 'refs';
}

sub _define_attr_accessor {
    my ( $pkg, $attr, $default ) = @_;

    # qq makes this block behave like a double-quoted string
    my $code = qq{
    package $pkg;
    sub $attr {                                      # Accessor ...
      my \$self=shift;
      if (\@_) {
      my \$prev = exists \$self->{"$attr"} ? \$self->{"$attr"} : \${"${pkg}::_WEBDAO_ATTRIBUTES_"}{"$attr"};
      \$self->{"$attr"} = shift ;
      return \$prev
      }
      return \${"${pkg}::_WEBDAO_ATTRIBUTES_"}{"$attr"} unless exists \$self->{"$attr"};
      \$self->{"$attr"}
    }
  };
    $code;
}

#deprecated

=pod
sub _define_constructor {
    my $pkg  = shift;
    my $code = qq {
    package $pkg;
    sub new {
	my \$class =shift;
	my \$self={};
	my \$stat;
	bless (\$self,\$class);
	return (\$stat=\$self->_init(\@_)) ? \$self: \$stat;
#	return \$self if (\$self->_init(\@_));
#	return (\$stat=\$self->Error) ? \$stat : "Error initialize";
    }
  };
    $code;
}
=cut

sub new {
    my $class = shift;
    my $self  = {};
    my $stat;
    bless( $self, $class );
    return $self;
    return ( $stat = $self->_init(@_) ) ? $self : $stat;
}

sub _init {
    my $self = shift;
    return 1;
}

#put message into syslog
sub _deprecated {
    my $self       = shift;
    my $new_method = shift;
    my ( $old_method, $called_from_str, $called_from_method ) =
      ( ( caller(1) )[3], ( caller(1) )[2], ( caller(2) )[3] );
    $called_from_method ||= $0;
    $self->_log3(
"called deprecated method $old_method from $called_from_method at line $called_from_str. Use method $new_method instead."
    );
}

sub logmsgs {
    my $self = shift;
    $self->_deprecated("_log1,_log2");
    $self->_log1(@_);
}
sub _log1 { my $self = shift; $self->_log( level => 1, par => \@_ ) }
sub _log2 { my $self = shift; $self->_log( level => 2, par => \@_ ) }
sub _log3 { my $self = shift; $self->_log( level => 3, par => \@_ ) }
sub _log4 { my $self = shift; $self->_log( level => 4, par => \@_ ) }
sub _log5 { my $self = shift; $self->_log( level => 5, par => \@_ ) }

sub _log {
    my $self = shift;
    my $dbg_level = $ENV{wdDebug} || $ENV{WD_DEBUG} || 0;
    return 0 unless $dbg_level;
    return $dbg_level unless ( scalar @_ );
    my %args = @_;
    return $dbg_level if $dbg_level < $args{level};
    my ( $mod_sub, $str ) = ( caller(2) )[ 3, 2 ];
    ($str) = ( caller(1) )[2];
    print STDERR "$$ [$args{level}] $mod_sub:$str  @{$args{par}} \n";
}

#TODO: remove LOG
sub LOG {
    my $self = shift;
    $self->_deprecated("_log1,_log2");
    return $self->logmsgs(@_);
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2015 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
