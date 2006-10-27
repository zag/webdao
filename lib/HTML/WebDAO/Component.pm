#$Id: Component.pm,v 1.1.1.1 2006/05/09 11:49:16 zag Exp $

package HTML::WebDAO::Component;
use HTML::WebDAO::Base;
use base qw(HTML::WebDAO::Element);
use strict 'vars';
use Data::Dumper;

sub url_method {
    my $self   = shift;
    my $method = shift;
    my $ref;
    $ref->{path} = join '/' => $self->__path2me, $method;
    my %args = @_;
    $ref->{pars} = \%args if @_;
    my $res;
    $self->SendEvent(
        "_sess_servise",
        {
            funct  => 'geturl',
            par    => $ref,
            result => \$res
        }
    );
    return $res;

}

sub GetURL {
    my ( $self, $ref ) = @_;
    my $res;
    if ( exists( $ref->{variable} ) ) {
        $ref->{variable}->{name} = $self->__path2me . "." . $ref->{variable}->{name}
          unless ( !exists( $ref->{variable} )
            && $ref->{variable}->{name} =~ /^\./
            && $ref->{variable}->{name} =~ s/^\.// );
    }
    $self->SendEvent(
        "_sess_servise",
        {
            funct  => 'geturl',
            par    => $ref,
            result => \$res
        }
    );
    return $res;
}

#??????
sub SetEvent {
    my ( $self, $event_name, $subaddr ) = @_;
    $event_name = $self->__path2me . "." . $event_name;

    #logmsgs $self "reg event name :".$event_name;
    $self->RegEvent( $event_name, $subaddr );
    return { name => $event_name, value => 1 };
}

#PrepareForm (\%hash,\%hash,"<br>,$string,\%hash)
sub PrepareForm {
    my ( $self, @par ) = @_;
    my @test;
    foreach my $par (@par) {
        unless ( ref($par) ) {
            push @test, $par;
            next;
        }
        if ( $par->{type} =~ /select/ ) {
            my ( $ref_val, $sel ) = @$par{ 'ref_values', 'selected' };
            my %hash = ();
            @hash{@$ref_val} = (0) x @$ref_val;
            $hash{$sel}      = 1;
            delete( $par->{ref_values} );
            delete( $par->{selected} );
            delete( $par->{type} );
            push @test, join " ",
              (
                "<select ",
                ( map { "$_=\"" . $par->{$_} . "\"" } keys %{$par} ),
                ">",
                join( "",
                    map { "<option " . ( $hash{$_} ? "selected" : "" ) . ">$_</option>" }
                      @$ref_val ),
                "</select >"
              );
            next;
        }
        push @test, join " ",
          ( "<input", ( map { "$_=\"" . $par->{$_} . "\"" } keys %{$par} ), ">" );
    }
    return @test if ( wantarray() );
    return join "", @test;
}

#Compile Form
sub CompileForm {
    my ( $self, $ref_to_params ) = @_;

    #my $ref_to_params = shift;
    #my ($par,$url,$res);
    my $res;
    $self->SendEvent(
        "_sess_servise",
        {
            funct  => 'getform',
            par    => $ref_to_params,
            result => \$res
        }
    );
    return $$res;
}

1;
