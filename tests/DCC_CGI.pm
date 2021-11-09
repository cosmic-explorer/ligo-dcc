##
## minimalistic module to ease testing of cgi scripts for DCC
## call setup() at the beginning to ensure a proper SiteConfig.pm 
## in the tes directory
## add teardown() in an END{} section to ensure cleanup
##
## cgi_call() call the cgi script via a system() call
## args:
## - script=> script name , the function prepends it with the  docdb_dir value
## - docdb_dir => path to the sources (can be relative)
## - use_warning => if non zero  uses perl -w to make the cgi call 
##   as of 2020-11-24 it will fail most tests because no docdb script is warning free
## - remote_user: simulate authenticated user use equivalent krbprincipalname or eppn 
## - query_string: a=proper&query=string&with=url%20escape     
## - verb: http verb used defaults to GET, but POST can be used to simulate form being submitted
## sensible (hopefully ?) defaults are provided for use_warning 

# in order to find SiteConfig.pm in the tests dir
use lib '.';


sub setup {
    system("cp SiteConfig.pm.org SiteConfig.pm");
    if (! $ENV{MYSQL_HOST} eq '') {
#       print " initiating database \n"; 
       #system('mysql -h ${MYSQL_HOST} -u ${MYSQL_USER} -p${MYSQL_PASSWORD}  ${MYSQL_DATABASE}  < init.d/*.sql');
    } else {
#       print " using local database assuming properly populated \n";
      ;      
    }
}


sub teardown {
  unlink 'SiteConfig.pm';
}


sub cgi_call {
  my (%args) = @_;
  my $script         = $args{script} ;
  my $report_warnings= $args{report_warnings} // 1;
  my $docdb_dir      = $args{docdb_dir}      || '../www/cgi-bin/private/DocDB';
  my $remote_user    = $args{remote_user}    || 'philippe.grassia@ligo.org';
  my $query_string   = $args{query_string}   || '';
  my $verb           = $args{verb}           || 'GET';
  

  # from https://perlmaven.com/testing-perl-cgi
  use Capture::Tiny qw(capture);
  use File::Temp qw(tempdir);
  use URI qw( );

  #maybe make it 'local' if the test runs inside a function (e.g. when graduating to Test::More) ?
  local $ENV{REQUEST_METHOD} = $verb;
  # to find both the SiteConfig.pm in the test dir and the *.pm files in the source directory
  local $ENV{PERL5LIB}       = $docdb_dir;
  # REMOTE_USER usually needed because of ACL control
  local $ENV{REMOTE_USER}    = $remote_user;
  # this is query string so it will need url escaping
  # since we're only simulating the cgi call we can pass these as posix command args
  local $ENV{QUERY_STRING}   = $query_string;
  my $perl_options = $report_warnings ? '-w' : '';
  return  capture { system "perl -I ./ $perl_options $docdb_dir/$script" };
}

1;
