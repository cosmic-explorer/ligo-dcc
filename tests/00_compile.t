#!/usr/bin/perl -w
# make sure to include the right 
# path https://stackoverflow.com/questions/841785/how-do-i-include-a-perl-module-thats-in-a-different-directory
# undecided yet if I go for /usr1/www/cgi-bin/private/DocDB (using "production" locatio)
# for .. or ../.. (assumes test directory in production location, simpler but with implication on deployment)
# or for $GIT_ROOT/cgi-bin/private (assumes I know GIT_ROOT, and structure is the same) 
# or externally manage PERL5LIB and trust it blindly
#

# 
# fails on philippe.grassia@dcc-dev because of
# Test::Compile not found.
#
use strict;
use warnings;


# make sure to add the dcc code directory to the LIB
#use lib '/usr1/www/cgi-bin/private/DocDB';
# use lib '../www/cgi-bin/private/DocDB';
use lib 'blib';

# do I smell setup() ?
{
  system("cp SiteConfig.pm.org SiteConfig.pm");
}


# reminesce of teardown() ? 
END {
  unlink 'SiteConfig.pm';
}



my @scripts = qw(AddFilesForm
AdministerForm
AdministerHome
AuthorAdd
AuthorAddForm
AuthorAdminister
BulkCertificateInsert
CallDocumentTree
CertificateApplyForm
ConfirmTalkHint
CustomListForm
DeleteConfirm
DeleteDocument
DisplayMeeting
DocDBHelp
DocDBInstructions
DocTypeAdminister
DocumentAddForm
DocumentDatabase
DocumentTree
EditTalkInfo
EmailAdminister
EmailAdministerForm
EmailCreate
EmailLogin
EventAdministerForm
ExternalDocDBAdministerForm
GroupAdminister
GroupAdministerForm
InstitutionAddForm
InstitutionAdminister
JournalAdminister
KeywordGroupAdminister
KeywordListAdminister
ListAllMeetings
ListAuthorGroups
ListAuthors
ListBy
ListEmailUsers
ListEventsBy
ListGroups
ListGroupUsers
ListKeywords
ListManagedDocuments
ListTopics
ListTypes
MeetingModify
MigrationHelper
ModifyHome
ProcessDocumentAdd
ProcessPNPReview
RemoteUserHasAccess
Resecure
ReserveHome
RetrieveArchive
RetrieveArchive
RetrieveFile
RetrieveFile
Search
SearchForm
SelectEmailPrefs
SelectGroups
SelectPrefs
SessionModify
SetGroups
SetPrefs
ShibLogout
ShowCalendar
ShowDocument
ShowTalkNote
SignatureReport
SignoffChooser
SignRevision
Statistics
TopicAdminister
UserAccessApply
WatchDocument
XMLClone
XMLUpdate
XMLUpload
XSearch) ;

system("mkdir blib");
system("cp ../www/cgi-bin/private/DocDB/*.pm blib/");
foreach my $script (@scripts) {
   system("cp ../www/cgi-bin/private/DocDB/$script blib/$script");
}

system("cp SiteConfig.pm.org blib/SiteConfig.pm");
use Test::Compile::Internal;
my $test = Test::Compile::Internal->new();
$test->all_files_ok('blib');
$test->done_testing();

system("rm -rf blib");



