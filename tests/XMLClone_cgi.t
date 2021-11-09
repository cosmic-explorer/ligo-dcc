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


use DCC_CGI;

# How many tests need to run ?
use Test::Simple tests => 4;

&setup();

sub getDocAlias($) {
    my ($str, @args)=@_;
    if ( $str =~ /duplicate\sdocument\sis\s(.*)\./) {
        return $1;
    } else {
        return 'not-found';
    }
}

END { &teardown() ; }

my ($DocumentHTML, $err, $exit) = &cgi_call( script          => 'XMLClone', 
  					    report_warnings => 0,
                                            query_string    => 'docid=164724&mode=add&version=0');
print "Err  : $err  \n";
print "Exit : $exit \n";
my $Alias_Found= &getDocAlias($DocumentHTML);
print "Output: $Alias_Found \n";

ok($exit == 0 , 'XMLClone returned code 0');
ok($err eq "", 'XMLClone did not generate warnings or errors');
ok( $Alias_Found =~ /[A-Z]\d{6,7}/, 'XMLClone sucessfully created a document' );

require SiteConfig;

my $sql = <<'EOD';
    select Signoff.*  from Signoff, DocumentRevision, Document
    where   Alias=?
        and
            DocumentRevision.DocumentID=Document.DocumentID
        and
            Signoff.DocRevID=DocumentRevision.DocRevID;
EOD

my $sth = $dbh->prepare($sql);

my @Documents_to_Compare = ( 'G2000007', $Alias_Found );
my @number_of_signoffs =();
foreach( 'G2000007', $Alias_Found) {
    my $docAlias = $_;
    $sth->execute($docAlias);
    my $rows = $sth->rows;
    push @number_of_signoffs , $rows;
    $sth->finish();
}


ok ($number_of_signoffs[0] == $number_of_signoffs[1], "XMLClone: document and clone have same number of signoffs $number_of_signoffs[1]" );

