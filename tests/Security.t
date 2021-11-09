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


require Security;

# ok( <an expression that calls the function and evaluate to true is the test passes> , "text that informs the nature of the performed test, if possible includes a bug/rfe number");
#ok( 1, '1 is true');
ok( CanAccess(174536, 1, undef) == 0 , "CanAccess: permission denied for G2100519-v1 for anonymous user");
ok( CanAccess(174536, 1, 3508) == 1 , "CanAccess: permission granted for G2100519-v1 for LIGO user");
#  kagra user accessing P1900244-v9
ok( CanAccess(162240,6, 2076) == 1, 'Can Access: permission granted for P1900244-v6 for KAGRA user');


