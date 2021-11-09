#!/usr/bin/perl -w
use warnings;
# make sure to include the right 
# path https://stackoverflow.com/questions/841785/how-do-i-include-a-perl-module-thats-in-a-different-directory
# undecided yet if I go for /usr1/www/cgi-bin/private/DocDB (using "production" locatio)
# for .. or ../.. (assumes test directory in production location, simpler but with implication on deployment)
# or for $GIT_ROOT/cgi-bin/private (assumes I know GIT_ROOT, and structure is the same) 
# or externally manage PERL5LIB and trust it blindly
#

# make sure to add the dcc code directory to the LIB
#use lib '/usr1/www/cgi-bin/private/DocDB';
use lib '../www/cgi-bin/private/DocDB';
use lib '.';

# do I smell setup() ?
{
  system("cp SiteConfig.pm.org SiteConfig.pm");
}


# reminesce of teardown() ? 
END {
  unlink 'SiteConfig.pm';  
}

# How many tests need to run ?
use Test::Simple tests => 2;
use  Capture::Tiny qw(capture);

# need at least one test for each 
# sub PrintDocTree ($) {
# sub FetchLinkFromNode($) {
# sub PrintInfoForm($){

# require the file/module whose functions you're about to test
require ProjectGlobals;
use CGI;
$query = new CGI;

# hmmm, resorting that probably means DocumentTree is a module and the filename should be DocumentTree.pm 
#require SiteConfig ;
require "DocumentTree";


# copied from CallDocumentTree, obviously there is some implicit context that is needed 
#    PrintInfoForm($Depth, "");
#    PrintDocTree($RevID, $Depth, "");

my ($output, $err, $exit)= capture { &PrintInfoForm(3, "") };
# print "OUT: $output\n";
print "ERR: $err\n";

ok($exit eq 0 , 'PrintInfoForm did not return an error');

# # ok( &FetchLinkFromNode(), "FetchLinkFromNode");
# # assuming the functions "just print"
$out, $err, $exit = capture {  &PrintDocTree() };
print "ERR: $err\n";
ok( $exit eq 0 , "PrintDocTree did not return and error"); 



