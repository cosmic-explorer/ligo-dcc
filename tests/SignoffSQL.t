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
use SignoffSQL;

ok( 1, '1 is true');

# ok(ProcessSignoffList ,Success ProcessSignoffList);
# ok(InsertSignoffList ,Success InsertSignoffList);
# ok(GetRootSignoffs ,Success GetRootSignoffs);
# ok(isParallelByDocRevID ,Success isParallelByDocRevID);
# ok(GetAllSignoffsByDocRevID ,Success GetAllSignoffsByDocRevID);
# ok(GetAllEmailUserIDsBySignoffIDs ,Success GetAllEmailUserIDsBySignoffIDs);
# ok(GetSignoffDocumentIDs ,Success GetSignoffDocumentIDs);
# ok(GetSignoffIDs ,Success GetSignoffIDs);
# ok(FetchSignoff ,Success FetchSignoff);
# ok(GetOrderedSignoffsByDocRevID ,Success GetOrderedSignoffsByDocRevID);
# ok(GetSubSignoffs ,Success GetSubSignoffs);
# ok(GetPreSignoffs ,Success GetPreSignoffs);
# ok(GetSignatures ,Success GetSignatures);
# ok(GetPreSignatures ,Success GetPreSignatures);
# ok(GetLastSignerByDocRevID ,Success GetLastSignerByDocRevID);
# ok(GetLastSignoffIDByDocRevID ,Success GetLastSignoffIDByDocRevID);
# ok(GetLastSignatureValueBySignoffID($) ,Success GetLastSignatureValueBySignoffID($));
# ok(isLastSignoffID($) ,Success isLastSignoffID($));
# ok(ClearSignatures ,Success ClearSignatures);
# ok(FetchSignature ,Success FetchSignature);
# ok(GetSignatureText ,Success GetSignatureText);
# ok(GetLastApprovedTimeStamp($) ,Success GetLastApprovedTimeStamp($));
# ok(GetSignerEmail ,Success GetSignerEmail);
# ok(GetAllEmails ,Success GetAllEmails);
# ok(GetTimeStamp ,Success GetTimeStamp);
# ok(NumberOfSigners($) ,Success NumberOfSigners($));
# ok(NumberOfDaysSince($) ,Success NumberOfDaysSince($));

use DBUtilities;
my $dbh = CreateConnection(-type => "rw");
