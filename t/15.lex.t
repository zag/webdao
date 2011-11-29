#===============================================================================
#
#  DESCRIPTION:  Test lexer
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

use strict;
use warnings;

use Test::More tests => 1;    # last test to print
use Regexp::Grammars;
use Data::Dumper;
my $q = qr{
#        <debug:step>
<context:>
    \A <[File]>+ \Z
    <rule: File> <start_block> <[childs]>+ <end_block>
    <rule: start_block>\<wd>
    <rule: end_block>\<\/wd>
    <rule: raw_text>    
        <matchpos>
        <matchline>
        (\S+) 
        (?{die "Text not allowed inside tags ".
            "Pos: $MATCH{matchpos} ".
            " line: ". 
            $MATCH{matchline} .
            " text: $CONTEXT" }) 
    <token: childs>           
#                     <MATCH=cdata> | 
                     <MATCH=object> |
                     <MATCH=any_tag>|
                     <raw_text>
    <rule: attribute> <name=([_\w]+)>=['"]<value=(?: ([^'"]+) )>['"]
    
    #argument :tagname
    <rule: default_tag> 
    # ![CDATA[...]]>  (?:<!\[CDATA\[)(.*?)(?:\]\]>)
    <objrule: cdata>(?: \<\!\[CDATA\[([^\]]+)\]\]\> )

    <rule: tag2>
        (?: < <tagname=\:tagname> <[attribute]>* /> )
        |
        (?:
        < <tagname=\:tagname> <[attribute]>* >
                    <[childs]>*
           </ <\:tagname> >
        )
    <rule: tag>
        <matchpos>
        <matchline>
        (?{  
            $ARG{'tagname'} = 
                defined ($ARG{'tagname'}) 
                    ? quotemeta $ARG{'tagname'}
                    : '(\w+)';
            # setup defaults
                $MATCH{childs} //=[];
                $MATCH{attribute} //=[];
         })
        (?:         
         < <tagname=:tagname> 
               <[attribute]>* />
        )
        |
        (?:
        < <tagname=:tagname> <[attribute]>* >
                    <[childs]>*
           </ <:tagname> >
        )

    <objrule: object> <tag( tagname=>'object' )>
    <objrule: TAG::any_tag> <tag>

}xms;

my $txt = <<'TXT';
<wd>
    <regclass class="ArtPers::Comp::LinkAuth" alias="link_auth"/>
    <object class="registr" id="reg" />
    <method path="/page/menu"/>
    <object class="isauth" id="auth_switch">

      <auth> asdasdf
        <object class="comp_unauth" id="ExitCP"/>
      </auth>
    </object>
</wd>
TXT

$txt = <<'TXT';
<wd>
    <object class="isauth" id="auth_switch">
      <auth>
      </auth>
    </object>
</wd>
TXT

$txt = <<'TXT';
<wd>
      <auth>
       <object class="isauth" id="auth_switch"/>
       <object class="isauth" id="auth_switch"/>
      </auth>
</wd>
TXT

if ( $txt =~ $q ) {
    warn Dumper( {%/} );
}
else {
    warn "BASD";
}

1;

