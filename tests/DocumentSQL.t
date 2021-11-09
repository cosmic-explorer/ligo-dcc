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
use Test::Simple tests => 4;


# require the file/module whose functions you're about to test
use ProjectGlobals;
#require Utilities;
use MiscSQL;
use DocumentSQL;

# FIXME: generate non colliding DocAlias
#sub InsertDocument (%)
my $DocAlias= 'T2105041';
my $DocumentID = &InsertDocument(-docnumber=>$DocAlias, -requesterid=>-1);
ok( defined $DocumentID , 'New Document was created');
#sub FetchDocumentAlias {
ok( &FetchDocumentAlias($DocumentID) eq $DocAlias , 'Alias retrieved from DocumentID');

#sub FetchDocumentType {
ok (&FetchDocumentType($DocumentID) eq 'T' , 'Document Type retrieved from DocumentID');

#sub GetDocumentIDByAlias {
ok( &GetDocumentIDByAlias($DocAlias) == $DocumentID, 'DocumentID retrieved from Alias');

# GetAllDocuments is not called once in current code : delete ?
#sub GetAllDocuments {a

#sub FetchDocument {
#sub FetchDocumentFilenames {
#

use DBUtilities;
my $dbh = CreateConnection(-type => "rw");
my $CleanUp = $dbh->prepare('delete from Document where Alias = ?;');
$CleanUp->execute($DocAlias);

