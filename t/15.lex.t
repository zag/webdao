#===============================================================================
#
#  DESCRIPTION:  Test lexer
#
#       AUTHOR:  Aliaksandr P. Zahatski, <zahatski@gmail.com>
#===============================================================================
#$Id$

use strict;
use warnings;

use Test::More tests => 1;                      # last test to print
use Regexp::Grammars;
use Data::Dumper;
my $q = qr{
    \A <[File]>+ \Z
    <rule: File> <fetch_start> | <fetch_stop> | <wd> | <raw_text>
    <rule: start_block>\<wd>
    <rule: end_block>\<\/wd>
    <rule: raw_text> .*?
    <rule: wd> <start_block><content=(.*?)><end_block>
    <rule: fetch_start><!-- \<wd:fetch> --> 
    <rule: fetch_stop><!-- \<\/wd:fetch> -->
    <regclass class="ArtPers::Comp::UserAuthorization" alias="login"/>
}xms;

my $txt=<<TXT;

<head/>
<!-- <wd:fetch> --> 
<br> 
<!-- </wd:fetch> --> 
<wd>
    <regclass>
</wd>
<div/>
TXT
if ($txt =~ $q ) {
    warn Dumper({%/})
} else {
    warn "BASD";
}

1;


