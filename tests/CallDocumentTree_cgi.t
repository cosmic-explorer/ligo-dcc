#!/usr/bin/perl -w
# make sure to include the right 
# path https://stackoverflow.com/questions/841785/how-do-i-include-a-perl-module-thats-in-a-different-directory
# undecided yet if I go for /usr1/www/cgi-bin/private/DocDB (using "production" locatio)
# for .. or ../.. (assumes test directory in production location, simpler but with implication on deployment)
# or for $GIT_ROOT/cgi-bin/private (assumes I know GIT_ROOT, and structure is the same) 
# or externally manage PERL5LIB and trust it blindly
#

# make sure to add the dcc code directory to the LIB
#use lib '/usr1/www/cgi-bin/private/DocDB';
# do I smell setup() ?
{
  system("cp SiteConfig.pm.org SiteConfig.pm");
}

use DCC_CGI;
use lib '.';

# How many tests need to run ?
use Test::Simple tests => 2;

&setup();

END { &teardown() ; }

# using the consacrated D0901491-v3 document: DocumentID => docid=3981, version=3
# depth=3
#
my ($output, $err, $exit) = &cgi_call( script          => 'CallDocumentTree',
  				       report_warnings => 0,
                                       query_string    => 'depth=3&docid=3981&firstclick=3&version=3');

#print "Err  : $err  \n";
#print "Exit : $exit \n";
print "Out: $output \n";

ok($exit == 0 , 'CallDocumentTree returned code 0');
# ok($err eq "", 'CallDocumentTree did not generate warnings or errors');
ok(!($output eq "")  , 'CallDocumentTree returned somethig not empty');


