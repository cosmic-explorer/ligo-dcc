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
use Test::Simple tests => 1;


# require the file/module whose functions you're about to test
use ProjectGlobals;
use SignoffUtilities;

ok( 1, '1 is true');

# ok(SignoffStatus , 'Success SignoffStatus');
# ok(SignoffStatus_Serial , 'Success SignoffStatus_Serial');
# ok(SignoffStatus_Parallel , 'Success SignoffStatus_Parallel');
# ok(RecurseSignoffStatus , 'Success RecurseSignoffStatus');
# ok(FindLastApprovedDocRevID($) , 'Success FindLastApprovedDocRevID');
# ok(RevisionStatus_Parallel , 'Success RevisionStatus_Parallel');
# ok(RevisionStatus_Serial , 'Success RevisionStatus_Serial');
# ok(RevisionStatus , 'Success RevisionStatus');
# ok(BuildSignoffDefault , 'Success BuildSignoffDefault');
# ok(UnsignRevision , 'Success UnsignRevision');
# ok(NotifySignatureSignees , 'Success NotifySignatureSignees');
# ok(NotifySignees , 'Success NotifySignees');
# ok(ReadySignatories , 'Success ReadySignatories');
# ok(CopyRevisionSignoffs , 'Success CopyRevisionSignoffs');

use DBUtilities;
my $dbh = CreateConnection(-type => "rw");
