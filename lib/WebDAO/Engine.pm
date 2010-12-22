package WebDAO::Engine;

#$Id$

=head1 NAME

=head1 DESCRIPTION

WebDAO::Engine - Class for root object of application model

=cut

use Data::Dumper;
use WebDAO::Container;
use WebDAO::Lex;
use WebDAO::Lib::MethodByPath;
use WebDAO::Lib::RawHTML;
use base qw(WebDAO::Container);
use Carp;
use strict;
__PACKAGE__->attributes qw( _session __obj __events);

sub _sysinit {
    my ( $self, $ref ) = @_;
    my %hash = @$ref;

    # Setup $init_hash;
    my $my_name = $hash{id} || '';    #shift( @{$ref} );
    unshift(
        @{$ref},
        {
            ref_engine => $self,       #! Setup _engine refernce for childs!
            name_obj   => "$my_name"
        }
    );                                 #! Setup _my_name
                                       #Save session
    _session $self $hash{session};

    #	name_obj=>"applic"});	#! Setup _my_name
    $self->SUPER::_sysinit($ref);

    #!init _runtime variables;
    $self->_set_parent($self);

    #hash "function" -"package"
    $self->__obj( {} );

    #init hash of evens names  -> @Array of pointers of sub in objects
    $self->__events( {} );

}

sub init {
    my ( $self, %opt ) = @_;

    #register default clasess
    $self->register_class(
        'WebDAO::Lib::RawHTML'      => '_rawhtml_element',
        'WebDAO::Lib::MethodByPath' => '_method_call'
    );

    #Register by init classes
    if ( ref( my $classes = $opt{register} ) ) {
        $self->register_class(%$classes);
    }
    my $raw_html = $opt{source};
    if ( my $lex = $opt{lexer} ) {
        map { $_->value($self) } @{ $lex->auto };
        my @objs = map { $_->value($self) } @{ $lex->tree };
        $self->_add_childs_(@objs);
    }
    elsif ( my $lex = $opt{lex} ) {
        map { $_->value($self) } @{ $lex->auto };
        my ( $pre, $fetch, $post ) = @{ $lex->__tmpl__ };
        $self->__add_childs__( 0, map { $_->value($self) } @$pre );
        $self->_add_childs_( map { $_->value($self) } @$fetch );
        $self->__add_childs__( 2, map { $_->value($self) } @$post );

    }
    else {

        #Create childs from source
        $self->_add_childs_( @{ $self->_parse_html($raw_html) } );
    }

}

sub _get_obj_by_path {
    my $self = shift;
    my ( $obj_p, @path ) = @_;
    my $id = shift @path;
    my $res;
    if ( my $obj = $obj_p->_get_obj_by_name($id) ) {
        $res = scalar(@path) ? $self->_get_obj_by_path( $obj, @path ) : $obj;
    }
    return $res;
}

sub __restore_session_attributes {
    my $self = shift;

    #collect paths as index
    my %paths;
    foreach my $object (@_) {
        my @collection = ( $object, @{ $object->_get_childs_ } );
        $paths{ $_->__path2me } = $_ for @collection;
    }
    my $sess   = $self->_session;
    my $loaded = $sess->_load_attributes_by_path( keys %paths );
    while ( my ( $key, $ref ) = each %$loaded ) {
        next unless exists $paths{$key};
        $paths{$key}->_set_vars($ref);
    }
}

sub __store_session_attributes {
    my $self = shift;

    #collect paths as index
    my %paths;
    foreach my $object (@_) {
        my @collection = ( $object, @{ $object->_get_childs_ } );
        foreach (@collection) {
            my $attrs = $_->_get_vars;
            next unless $attrs;
            $paths{ $_->__path2me } = $attrs;
        }
    }
    my $sess = $self->_session;
    $sess->_store_attributes_by_path( \%paths );
}

sub response {
    my $self = shift;
    return $self->_session->response_obj;
}

=head2 resolve_path $session , ( $url or \@path )

Resolve path, find object and call method
Can return:

    undef - not found path or object not have method
    $object_ref - if object return $self (????)
    WebDAO::Response - objects

    

=cut

sub resolve_path {
    my $self = shift;
    my $sess = shift;
    my $url  = shift;
    my @path = ();
    if ( ref($url) eq 'ARRAY' ) {
        @path = @$url;
    }
    else {
        @path = @{ $sess->call_path($url) };
    }
    my $result;

    #return $self for / pathes
    return $self unless @path;

    #try to get object by path

    if ( my $object = $self->_get_object_by_path( \@path, $sess ) ) {

        #if object have index_x then stop traverse and call them
        my $method = shift @path;

        #call __any_method unless exists defined method
        if (    defined($method)
            and !UNIVERSAL::can( $object, $method )
            and UNIVERSAL::can( $object, '__any_method' ) )
        {
            unshift @path, $method;
            return $object->__any_method( \@path, %{ $sess->Params } );

        }

        $method = 'Index_x' unless defined $method;

        #Check upper case First letter for method
        if ( ucfirst($method) ne $method ) {
            _log2 $self "Deny method : $method";
            return;
        }

        #check if $object have method
        if ( UNIVERSAL::can( $object, $method ) ) {

            #Ok have method
            #check if path have more elements
            my %args = %{ $sess->Params };
            if (@path) {

                #add  special variable
                $args{__extra_path__} = \@path;
            }

            #call method
            $result = $object->$method(%args);
            return unless defined $result;    #return undef if empty result

            #if object return $self ?
            return $result if $object eq $result;    #return then
                  #if method return non response object
                  #then create them
            unless ( UNIVERSAL::isa( $result, 'WebDAO::Response' ) ) {
                my $response = $self->response;
                for ($response) {

                    #set default format : html
                    html $_= $result;
                }
                $result = $response;
            }
        }
        else {

           #don't have method
           #error404 - not found
           #            $result = $self->response->error404("Not Found : $url");
        }
    }
    else {

        #not found objects by path !
        #        $result = $self->response->error404("Not Found : $url");
    }
    return $result;
}

=head2  __handle_out__ ($sess, @output)

Process output by fetch methods

=cut

sub __handle_out__ {
    my $self = shift;
    my $sess = shift;
    for (@_) {
        if ( UNIVERSAL::isa( $_, 'WebDAO::Element' ) ) {
            $self->__handle_out__( $sess, $_->pre_fetch($sess) )
              if UNIVERSAL::can( $_, 'pre_fetch' );

            $self->__handle_out__( $sess, $_->fetch($sess) );
            $self->__handle_out__( $sess, $_->post_fetch($sess) )
              if UNIVERSAL::can( $_, 'post_fetch' );

        }
        elsif ( ref($_) eq 'CODE' ) {
            return $self->__handle_out__( $sess, $_->($sess) );
        }
        elsif ( UNIVERSAL::isa( $_, 'WebDAO::Response' ) ) {
            $_->_is_headers_printed(1);
            $_->_print_dep_on_context($sess) unless $_->_is_file_send;
            $_->flush;
            $_->_destroy;

        }
        else {
            $sess->print($_);
        }
    }
}

sub __events__ {
    my $self         = shift;
    my $root         = shift;
    my $inject_fetch = shift;
    my $path         = $root->__path2me;
    my @childs       = ();

    #make inject event for objects
    if ( my $res = $inject_fetch->{$path} ) {
        @childs = (
            {
                fetch => $root->__path2me,
                pme   => $path,
                ,
                event => 'inject',
                obj   => $root,
                res   => $res
            }
        );

    }
    else {

        if ( UNIVERSAL::isa( $root, 'WebDAO::Container' ) ) {

            #skip modal
            for ( @{ $root->__childs() } ) {
                push @childs, $self->__events__( $_, $inject_fetch )
                  unless UNIVERSAL::isa( $_, 'WebDAO::Modal' );
            }
        }
        else {
            @childs = (
                {
                    fetch => $root->__path2me,
                    pme   => $path,
                    ,
                    event => 'fetch',
                    obj   => $root
                }
            );
        }
    }
    my @res = (
        {
            st_ev => $root->__path2me,
            pme   => $path,
            event => 'start',
            obj   => $root
        },
        @childs,
        {
            end_ev => $root->__path2me,
            pme    => $path,
            event  => 'end',
            obj    => $root
        }
    );
}

sub execute2 {
    my $self = shift;
    my $sess = shift;
    my $url  = shift;
    my @path = @{ $sess->call_path($url) };
    my ( $src, $res ) = $self->_traverse_( $sess, @path );

    #    use WebDAO::Test;
    #    my $tlib = new WebDAO::Test:: eng=>$self->getEngine;
    #    warn Dumper $tlib->tree;
    #    exit;
    my $response = $self->response; #$sess->response_obj;

    #now analyze answers
    # undef -> not Found
    unless ( defined($res) ) {
        $response->error404( "Url not found:" . join "/", @path );
        $response->flush;
        $response->_destroy;
        return;    #end
    }

    #convert string and ref(scalar) to resonse with html
    #special handle strings
    if ( !ref($res) or ( ref($res) eq 'SCALAR' ) ) {
        $res = $response->set_html( ref($res) ? $$res : $res );
    }
    #special handle HASH refs ( interpret as json)
    if ( ( ref($res) eq 'HASH' )  and $response->wantformat('json') ) {
        $res = $response->set_json( $res );
    }
    #check if  response modal
    if ( UNIVERSAL::isa( $res, 'WebDAO::Response' ) and $res->_is_modal() ) {

        #handle response
        $res->_print_dep_on_context($sess) unless $res->_is_file_send;
        $res->flush;
        $res->_destroy;
        return;

    }

    #extract all objects to evenets
    my $root = $self;

    #if object modal ?
    if ( UNIVERSAL::isa( $src, 'WebDAO::Modal' ) ) {

        #warn "GO MODSAD". $src;
        #set him as root of putput
        $root = $src;
    }
    my $need_inject_result = 1;

    #special handle strings
    if ( !ref($res) or ( ref($res) eq 'SCALAR' ) ) {

        #    warn "GOT STRING";

        #now walk
    }
    elsif

      #if result ref to object and it eq $src run flow
      ( $res == $src ) {

        $need_inject_result = 0;
    }
    if ( UNIVERSAL::isa( $res, 'WebDAO::Element' ) ) {

        # warn " Got $src, $res  \$need_inject_result $need_inject_result" ;
        #nothing  to do
    }
    my %injects = ();

    #if need inject check flow by path
    if ($need_inject_result) {
        $injects{ $src->__path2me } = $res;
    }
    #start out
    $response->print_header;

    my @ev_flow = $self->__events__( $root, \%injects );
    foreach my $ev (@ev_flow) {
        my $obj = $ev->{obj};

        #_log1 $self "DO " . $ev->{event}. " for $obj";
        if ( $ev->{event} eq 'start' ) {

            $self->__handle_out__( $sess, $obj->pre_fetch($sess) )
              if UNIVERSAL::can( $obj, 'pre_fetch' );

        }
        elsif ( $ev->{event} eq 'inject' ) {
            $self->__handle_out__( $sess, $ev->{res} )

        }
        elsif ( $ev->{event} eq 'fetch' ) {

            #skip fetch method for container

            $self->__handle_out__( $sess, $obj->fetch($sess) )
              if UNIVERSAL::can( $obj, 'fetch' );

        }
        elsif ( $ev->{event} eq 'end' ) {

            $self->__handle_out__( $sess, $obj->post_fetch($sess) )
              if UNIVERSAL::can( $obj, 'post_fetch' );
        }

    }
    $response->flush;
    $response->_destroy;
}

sub execute {
    my $self = shift;
    my $sess = shift;
    my $url  = shift;
    my @path = grep { $_ ne '' } @{ $sess->call_path($url) };
    my $ans  = $self->resolve_path( $sess, \@path );

    #got reference
    #unless defined then return not found
    unless ($ans) {
        my $response = $sess->response_obj;
        $response->error404( "Url not found:" . join "/", @path );
        $response->flush;
        $response->_destroy;
        return;    #end
    }
    unless ( ref $ans ) {
        _log1 $self "got non referense answer $ans";
        my $response = $sess->response_obj;
        $response->error404(
            "Unknown response path: " . join( "/", @path ) . " ans: $ans" );
        $response->flush;
        $response->_destroy;
        return;    #end
    }

    #check referense or not
    if ( UNIVERSAL::isa( $ans, 'WebDAO::Response' ) ) {

        $ans->_print_dep_on_context($sess) unless $ans->_is_file_send;
        $ans->flush;
        $ans->_destroy;
        return;
        my $res = $ans->html;
        $ans->print( ref($res) eq 'CODE' ? $res->() : $res );
        $ans->flush;
        $ans->_destroy;
        return;    #end
    }
    elsif ( UNIVERSAL::isa( $ans, 'WebDAO::Element' ) ) {

        #got Element object
        #do walk over objects
        my $response = $sess->response_obj;
        $response->print($_) for @{ $self->fetch($sess) };
        $response->flush;
        $response->_destroy;
        return;    #end
    }
    else {

        #not reference or not definde
        _log1 $self "Not supported response object. path: "
          . join( "/", @path )
          . " ans: $ans";
        my $response = $sess->response_obj;
        $response->error404(
            "Unknown response path: " . join( "/", @path ) . " ans: $ans" );
        $response->flush;
        $response->_destroy;
        return;    #end

    }
}

#fill $self->__events hash event - method
sub RegEvent {
    my ( $self, $ref_obj, $event_name, $ref_sub ) = @_;
    my $ev_hash = $self->__events;
    $ev_hash->{$event_name}->{ scalar($ref_obj) } = {
        ref_obj => $ref_obj,
        ref_sub => $ref_sub
      }
      if ( ref($ref_sub) );
    return 1;
}

sub SendEvent {
    my ( $self, $event_name, @Par ) = @_;
    my $ev_hash = $self->__events;
    unless ( exists( $ev_hash->{$event_name} ) ) {
        _log2 $self "WARN: Event $event_name not exists.";
        return 0;
    }
    foreach my $ref_rec ( keys %{ $ev_hash->{$event_name} } ) {
        my $ref_sub = $ev_hash->{$event_name}->{$ref_rec}->{ref_sub};
        my $ref_obj = $ev_hash->{$event_name}->{$ref_rec}->{ref_obj};
        $ref_obj->$ref_sub( $event_name, @Par );
    }
}

=head3 _createObj(<name>,<class or alias>,@parameters)

create object by <class or alias>.

=cut

sub _create_ {
    my ( $self, $name_obj, $name_func, @par ) = @_;
    my $pack = $self->_pack4name($name_func) || $name_func;
    my $ref_init_hash = {
        ref_engine => $self->getEngine(),  #! Setup _engine refernce for childs!
        name_obj   => $name_obj
    };    #! Setup _my_name
    my $obj_ref =
      $pack->isa('WebDAO::Element')
      ? eval "'$pack'\-\>new(\$ref_init_hash,\@par)"
      : eval "'$pack'\-\>new(\@par)";
    $self->_log1("Error in eval:  _createObj $@") if $@;
    return $obj_ref;
}

sub _createObj {
    my $self = shift;

    #    _deprecated $self "_create_";
    return $self->_create_(@_);
}

#sub _parse_html(\@html)
#return \@Objects
sub _parse_html {
    my ( $self, $raw_html ) = @_;
    return [] unless $raw_html;

    #Mac and DOS line endings
    $raw_html =~ s/\r\n?/\n/g;
    my $mass;
    $mass = [ split( /(<WD>.*?<\/WD>)/is, $raw_html ) ];
    my @res;
    foreach my $text (@$mass) {
        my @ref;
        unless ( $text =~ /^<wd/i ) {
            push @ref,
              $self->_createObj( "none", "_rawhtml_element", \$text )
              ;    #if $text =~ /\s+/;
        }
        else {
            my $lex = new WebDAO::Lex:: engine => $self;
            @ref = $lex->lex_data($text);    #clean 'empty'

          #        _log3 $self "LEXED:".Dumper([ map {"$_"} @ref])."from $text";

        }
        next unless @ref;
        push @res, @ref;
    }
    return \@res;
}

#Get package for functions name
sub _pack4name {
    my ( $self, $name ) = @_;
    my $ref = $self->__obj;
    return $$ref{$name} if ( exists $$ref{$name} );
}

sub register_class {
    my ( $self, %register ) = @_;
    my $_obj = $self->__obj;
    while ( my ( $class, $alias ) = each %register ) {

        #check non loaded mods
        my ( $main, $module ) = $class =~ m/(.*\:\:)?(\S+)$/;
        $main ||= 'main::';
        $module .= '::';
        no strict 'refs';
        unless ( exists $$main{$module} ) {
            _log1 $self "Try use $class";
            eval "use $class";
            if ($@) {
                _log1 $self "Error register class :$class with $@ ";
                return "Error register class :$class with $@ ";
                next;
            }
        }
        use strict 'refs';

        #check if register_class used for eval ( see Lobject )
        $$_obj{$alias} = $class if defined $alias;
    }
    return;
}

sub _destroy {
    my $self = shift;
    $self->__store_session_attributes( @{ $self->_get_childs_ } );
    $self->SUPER::_destroy;
    $self->_session(undef);
    $self->__obj(undef);
    $self->__events(undef);
}
1;
__DATA__

=head1 SEE ALSO

http://webdao.sourceforge.net

=head1 AUTHOR

Zahatski Aliaksandr, E<lt>zag@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002-2010 by Zahatski Aliaksandr

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut

