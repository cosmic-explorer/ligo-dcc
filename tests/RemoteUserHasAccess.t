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
# do I smell setup() ?
BEGIN {
  system("cp SiteConfig.pm.org SiteConfig.pm");
}


use DCC_CGI;



sub script_call {
  # FIXME: this is a copy of DCC_CGI->cgi_call, adjust for calling RemoteUserHasAccess
  my (%args) = @_;
  my $script         = $args{script} ;
  my $report_warnings= $args{report_warnings} // 1;
  my $docdb_dir      = $args{docdb_dir}      || '../www/cgi-bin/private/DocDB';
  my $the_remote_user= $args{remote_user}    || 'philippe.grassia@ligo.org';
  my $query_string   = $args{query_string}   || '';
  my $stdin          = $args{stdin}          || '';

  # from https://perlmaven.com/testing-perl-cgi
  use Capture::Tiny qw(capture);
#  use File::Temp qw(tempdir);
#  use URI qw( );

  # to find both the SiteConfig.pm in the test dir and the *.pm files in the source directory
  local $ENV{PERL5LIB}       = $docdb_dir;
  # REMOTE_USER usually needed because of ACL control
  local $ENV{REMOTE_USER}    = $the_remote_user;
  # this is query string so it will need url escaping
  # since we're only simulating the cgi call we can pass these as posix command args
  local $ENV{QUERY_STRING}   = $query_string;
  local $ENV{URI} = "https://localhost/$query_string";
  my $perl_options = $report_warnings ? '-w' : '';
  return  capture { system "echo \"$stdin\" | perl -I ./ $perl_options $docdb_dir/$script" };
}

# How many tests need to run ?
use Test::Simple tests => 3;

&setup();

END { &teardown() ; }

my ($output, $err, $exit) = &script_call( script          => 'RemoteUserHasAccess', 
  				          report_warnings => 0,
                                          stdin           => '',
                                          query_string    => '/DocDB/0174/G2100519/001/Offsource_GRB_Trigger_Followup.png');
print "Err  : $err  \n";
print "Exit : $exit \n";
print "Output: $output \n" ;
ok($exit == 0 , 'RemoteUserHasAccess: denied');
ok($err eq "", 'RemoteUserHasAccess: did not generate warnings or errors');
ok($output eq "" ,'RemoteUserHasAccess: output as expected.'); 


