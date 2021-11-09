#!/usr/bin/perl -w
# obviously everything falls apart if you try to use strict
# mostly for reasons of @INC
#use strict;
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

require SiteConfig;

# How many tests need to run ?
use Test::Simple tests => 1;

ok( $dbh , "connection database at $db_host established");

