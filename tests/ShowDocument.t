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
# do I smell setup() ?
{
  system("cp SiteConfig.pm.org SiteConfig.pm");
}

use lib '.';
use DCC_CGI;

# How many tests need to run ?
use Test::Simple tests => 3;

&setup();

END { &teardown() ; }

my ($DocumentXML, $err, $exit) = &cgi_call( script          => 'ShowDocument', 
  					    report_warnings => 0,
                                            query_string    => 'docid=T080330&outformat=xml');
print "Err  : $err  \n";
print "Exit : $exit \n";

ok($exit == 0 , 'ShowDocument returned code 0');
ok($err eq "", 'ShowDocument did not generate warnings or errors');
ok($DocumentXML =~ /xref(by|to).*alias/ , '#445, DocumentAlias listed in xrefby, xrefto in XML output' );


