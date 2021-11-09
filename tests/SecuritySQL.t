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
{
  system("cp SiteConfig.pm.org SiteConfig.pm");
}



# How many tests need to run ?
use Test::Simple tests => 3;


# require the file/module whose functions you're about to test

#require CGIInclude or die $!;
require DocDBGlobals;
require ProjectGlobals;
require SiteConfig;
#require ResponseElements;
#require NotificationSQL;
#require SignoffSQL;
#require SecuritySQL;
#require RevisionSQL;
#require RevisionHTML;
#require EmailSecurity;
#require FSUtilities;

require SecuritySQL;

# ok( <an expression that calls the function and evaluate to true is the test passes> , "text that informs the nature of the performed test, if possible includes a bug/rfe number");
#ok( 1, '1 is true');


my $AnonymousUser = &FetchEmailUserIDFromRemoteUserName("") // -1;
my $KnownUser     = &FetchEmailUserIDFromRemoteUserName('philippe.grassia@LIGO.ORG') ;
my $UnknownUser   = &FetchEmailUserIDFromRemoteUserName('jabberwookie') // -1 ;



ok( $AnonymousUser == -1, "FetchEmailUserIDFromRemoteUserName(''): empty RemoteUserName");
ok( $KnownUser > 0,       "FetchEmailUserIDFromRemoteUserName: existing user");
ok( $UnknownUser == -1,   "FetchEmailUserIDFromRemoteUserName: non existing  user");




