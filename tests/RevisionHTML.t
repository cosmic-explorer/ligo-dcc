#!/usr/bin/perl -w
use strict;
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

# do I smell setup() ?
BEGIN {
  system("cp SiteConfig.pm.org SiteConfig.pm");
}



# How many tests need to run ?
use Test::Simple tests => 1;


# require the file/module whose functions you're about to test
use ProjectGlobals; 
require  RevisionHTML;
require  MiscSQL;
require  FormElements;


# get context from MiscSQL::GetDocTypes
&GetDocTypes();
 
# sub DocTypeText ($) {
&DocTypeText("T");
 
# sub DccNumberBox (%) {
# sub TitleBox (%) {
# sub AbstractBox (%) {
# sub RevisionNoteBox {
# sub DocTypeButtons (%) {
# sub PrintRevisionInfo {
# sub DisplayReviewButton{
# sub DontPrintRevisionInfo($$) {
# sub PrintAbstract ($;$) {
# sub PrintKeywords {
# sub PrintRevisionNote {
# sub PrintReferenceInfo ($;$) {
# sub PrintEventInfo (%) {
# sub PrintPubInfo ($) {
# sub PrintModTimes {
# sub OtherVersionLinks {

ok( 1, '1 is true');

use DBUtilities;
my $dbh = CreateConnection(-type => "rw");
