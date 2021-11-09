#
# Description: Configuration file for the DocDB. Sets default
#              values and script names. Do not change this file,
#              specific local settings are in ProjectGlobals.pm.
#              Nearly any variable here can be changed there.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:
#
# Copyright 2001-2007 Eric Vaandering, Lynn Garren, Adam Bryant

#    This file is part of DocDB.

#    DocDB is free software; you can redistribute it and/or modify
#    it under the terms of version 2 of the GNU General Public License
#    as published by the Free Software Foundation.

#    DocDB is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with DocDB; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

require "Utilities.pm";

# ListBy looping limit to keep things from spinning
# for minutes, causing people to bounce on the key,
# causing it to spin for hours...
$LOOP_LIMIT = 2000;

# Advertising link for DocDB
$DocDBHome = "http://docdb-v.sourceforge.net/";

# Optional components

# Is the Mailer::Mail module installed?
$MailInstalled = 1;

# Shell Commands, FS details

#$Wget   = "/usr/bin/wget";
#$GTar   = "/bin/tar ";
#$GZip   = "/bin/gzip ";
#$GUnzip = "/bin/gunzip ";
#$Unzip  = "/usr/bin/unzip -q ";
# Set to "" in ProjectGlobals if not installed
#$Zip    = "/usr/bin/zip -q -r ";
#$FileMagic = "/usr/bin/file";
$Wget   = "";
$Tar    = "";
$GTar   = "";
$GZip   = "";
$GUnzip = "";
$Unzip  = "";
$Zip    = "";
$FileMagic = "";

$TmpDir = "/tmp/";

# Useful stuff

%ReverseFullMonth = (January => 1,  February => 2,  March     => 3,
                     April   => 4,  May      => 5,  June      => 6,
                     July    => 7,  August   => 8,  September => 9,
                     October => 10, November => 11, December  => 12);

%ReverseAbrvMonth = (Jan => 1,  Feb => 2,  Mar => 3,
                     Apr => 4,  May => 5,  Jun => 6,
                     Jul => 7,  Aug => 8,  Sep => 9,
                     Oct => 10, Nov => 11, Dec => 12);

@AbrvMonths = ("Jan","Feb","Mar","Apr","May","Jun",
               "Jul","Aug","Sep","Oct","Nov","Dec");

@FullMonths = ("January",  "February","March",   "April",
               "May",      "June",    "July",    "August",
               "September","October", "November","December");

# Useful functions
sub tolower {
   my $string = $_[0];
   $string =~ tr/[A-Z]/[a-z]/;
   return $string;
}

# Reports

@WarnStack   = ();
@ErrorStack  = ();
@DebugStack  = ();
@ActionStack = ();

# Other Globals

# This syntax creates an immutable variable &remote_user
# that is really a subroutine that compiles to returning
# the string that it is initialised with. Weird.
use constant remote_user => &tolower($ENV{REMOTE_USER});
use constant authnz_remote_user => &tolower($ENV{REMOTE_USER});

$ENV{HOME} = "/";

# Preferences

# Unused, encourage users to limit which groups they belong to with cookies
$Preferences{Security}{Certificates}{PopupLimitCookie}     = $FALSE;
# TRUE or FALSE - show KCA certificate instructions
$Preferences{Security}{Certificates}{FNALKCA}              = $TRUE;
# TRUE or FALSE - show DOEgrid certificate instructions
$Preferences{Security}{Certificates}{DOEGrids}             = $FALSE;
# TRUE or FALSE - show certificate instructions even on non-cert version
$Preferences{Security}{Certificates}{ShowCertInstructions} = $TRUE;
# Generate Full document list by dynamically for private db
$Preferences{Options}{DynamicFullList}{Private}            = $FALSE;
# Generate Full document list by dynamically for public db
$Preferences{Options}{DynamicFullList}{Public}             = $FALSE;
# Always use RetrieveFile instead of File Links
$Preferences{Options}{AlwaysRetrieveFile}                  = $FALSE;
# "Put text here to make users agree to a privacy statement or some-such.
# <br/><b>I agree:</b>"
$Preferences{Options}{SubmitAgree}              = "";

$Preferences{Topics}{MinLevel}{Document} = 1;
$Preferences{Events}{MaxSessionList}     = 5;

$htaccess             = ".htaccess";

$LastDays             = 2;    # Number of days for default in LastModified
$HomeLastDays         = 2;     # Number of days for last modified on home page
$HomeMaxDocs          = 50;    # Maximum number of documents on home page
$MeetingWindow        = 7;     # Days before and after meeting to preselect
$TalkHintWindow       = 7;     # Days before and after to guess on documents
$MeetingFiles         = 3;     # Number of upload boxes on meeting short form
$InitialSessions      = 5;     # Number of initial sessions when making meeting

$FirstYear            = 2000;  # Earliest year that documents can be created

$TalkMatchThreshold   = 100;   # Threshold for matching talks with agenda entries
                               # in agendas

$AllCanSign           = 1;     # Allow all EmailUsers to sign

# Don't match on these
@MatchIgnoreWords     = ("from","with","then","than","that","what");

$RequiredMark = "&nbsp;*&nbsp;";

# Character set for page encoding.
# May have to modify MySQL text fields accordingly.
$HTTP_ENCODING        = 'ISO-8859-1';
# $HTTP_ENCODING        = 'utf-8';

# Which things are publicly viewable?
$PublicAccess{MeetingList} = 0;

# Options

$CaseInsensitiveUsers = 0;
$EnhancedSecurity     = $TRUE; # Separate lists for view, modify
$SuperiorsCanModify   = 1;     # In enhanced model, a superior group can modify
                               # a subordinate groups documents without explicit
                               # permission
$UserValidation = "";          # || "basic-user" || "certificate"
                               # Do we do group authorization like V5 and before
			                      # or do we allow .htaccess/.htpasswd users to map to groups (basic)
			                      # or require SSL certificates of users which map to groups (certificate)
$ReadOnly       = 0;           # Can be used in conjunction with individual
                               # authorization methods to set up a group-like
                               # area with group passwords which can view
                               # but not change any info
$ReadOnlyAdmin  = 0;           # Allows administration from the read-only
                               # area. Only suggested for boot-strapping until
                               # you have an individual selected as admin

$UseSignoffs          = 0;     # Optional sign-off system for document approval
$ContentSearch        = 1;     # Scripts and engine installed for searching files

$DefaultPublicAccess  = 0;     # New documents are public by default

# Include project specific settings

require "ProjectGlobals.pm";

# Special files (here because they use values from above)

# CGI Scripts

$MainPage              = $cgi_root."DocumentDatabase";
$ModifyHome            = $cgi_root."ModifyHome";
$ShibLogout            = $cgi_root."ShibLogout";


$DocumentAddForm       = $cgi_root."DocumentAddForm";
$ReserveHome           = $cgi_root."ReserveHome";
$ProcessDocumentAdd    = $cgi_root."ProcessDocumentAdd";
$DeleteConfirm         = $cgi_root."DeleteConfirm";
$DeleteDocument        = $cgi_root."DeleteDocument";

$ShowDocument          = $cgi_root."ShowDocument";
$SecureShowDocument    = $secure_root."ShowDocument";
$RetrieveFile          = $cgi_root."RetrieveFile";
$RetrieveArchive       = $cgi_root."RetrieveArchive";
$ProcessPNPReview      = $cgi_root."ProcessPNPReview";

$XSearch               = $cgi_root."XSearch";
$Search                = $cgi_root."Search";
$SearchForm            = $cgi_root."SearchForm";

$AuthorAddForm         = $cgi_root."AuthorAddForm";
$AuthorAdd             = $cgi_root."AuthorAdd";

$ListManagedDocuments  = $cgi_root."ListManagedDocuments";

$ListAuthors           = $cgi_root."ListAuthors";
$ListAuthorGroups      = $cgi_root."ListAuthorGroups";
$ListEventsBy          = $cgi_root."ListEventsBy";
$ListEmailUsers        = $cgi_root."ListEmailUsers";
$ListGroups            = $cgi_root."ListGroups";
$ListKeywords          = $cgi_root."ListKeywords";
$ListTopics            = $cgi_root."ListTopics";
$ListTypes             = $cgi_root."ListTypes";
$ListBy                = $cgi_root."ListBy";

$AddFiles              = $cgi_root."AddFiles";
$AddFilesForm          = $cgi_root."AddFilesForm";

$DisplayMeeting        = $cgi_root."DisplayMeeting";
$MeetingModify         = $cgi_root."MeetingModify";
$SessionModify         = $cgi_root."SessionModify";
$ListAllMeetings       = $cgi_root."ListAllMeetings";
$ConfirmTalkHint       = $cgi_root."ConfirmTalkHint";
$ShowCalendar          = $cgi_root."ShowCalendar";

$SignoffChooser        = $cgi_root."SignoffChooser";
$SignRevision          = $cgi_root."SignRevision";
$SignatureReport       = $cgi_root."SignatureReport";

$QACheckRevision       = $cgi_root."QACheckRevision";

$AdministerHome        = $cgi_root."AdministerHome";
$AdministerForm        = $cgi_root."AdministerForm";
$AuthorAdminister      = $cgi_root."AuthorAdminister";
$InstitutionAdminister = $cgi_root."InstitutionAdminister";
$TopicAdminister       = $cgi_root."TopicAdminister";
$DocTypeAdminister     = $cgi_root."DocTypeAdminister";
$JournalAdminister     = $cgi_root."JournalAdminister";
$ConferenceAdminister  = $cgi_root."ConferenceAdminister";

$KeywordAdministerForm  = $cgi_root."KeywordAdministerForm";
$KeywordListAdminister  = $cgi_root."KeywordListAdminister";
$KeywordGroupAdminister = $cgi_root."KeywordGroupAdminister";

$GroupAdministerForm   = $cgi_root."GroupAdministerForm";
$GroupAdminister       = $cgi_root."GroupAdminister";

$EmailAdministerForm   = $cgi_root."EmailAdministerForm";
$EmailAdminister       = $cgi_root."EmailAdminister";

$EventAdministerForm         = $cgi_root."EventAdministerForm";
$ExternalDocDBAdministerForm = $cgi_root."ExternalDocDBAdministerForm";

$Statistics            = $cgi_root."Statistics";

$SelectPrefs           = $cgi_root."SelectPrefs";
$SetPrefs              = $cgi_root."SetPrefs";
$CustomListForm        = $cgi_root."CustomListForm";

$SelectGroups          = $cgi_root."SelectGroups";
$SetGroups             = $cgi_root."SetGroups";

#MCA:  $EmailLogin            = $cgi_root."EmailLogin";
$EmailLogin            = $cgi_root."SelectEmailPrefs";
$SelectEmailPrefs      = $cgi_root."SelectEmailPrefs";
$WatchDocument         = $cgi_root."WatchDocument";

$CertificateApplyForm  = $cgi_root."CertificateApplyForm";
$BulkCertificateInsert = $cgi_root."BulkCertificateInsert";
$UserAccessApply       = $cgi_root."UserAccessApply";
$ListGroupUsers        = $cgi_root."ListGroupUsers";

$DocDBHelp             = $cgi_root."DocDBHelp";
$WikiInstructions      = $wiki_root."/Quick_Start_Guide_-_What_to_do%3F";
$WikiHelpPage          = $wiki_root."/Getting_DocDB_Help";
$DocDBInstructions     = $cgi_root."DocDBInstructions";
$ShowTalkNote          = $cgi_root."ShowTalkNote";
$EditTalkInfo          = $cgi_root."EditTalkInfo";

$XMLUpload             = $cgi_root."XMLUpload";
$XMLUpdate             = $cgi_root."XMLUpdate";
$XMLClone              = $cgi_root."XMLClone";
$XMLCloneConfirm       = $cgi_root."XMLCloneConfirm";
$DocumentTree          = $cgi_root."DocumentTree";
$CallDocumentTree      = $cgi_root."CallDocumentTree";

$PublicMainPage        = $Public_cgi_root."DocumentDatabase";
$SecureMainPage        = $secure_root."DocumentDatabase";

$document_root = $file_root=~ s!/DocDB/?!!r;
my $_BaseURL_ = $Public ==1 ? "/public": "";

unless ($CSSDirectory && $CSSURLPath) {
  # eliminate these pesky // 
  $CSSDirectory = $document_root."/Static/css" =~ s!//!/!gr;
  $CSSURLPath   = $_BaseURL_."/Static/css";
}

unless ($JSDirectory && $JSURLPath) {
  $JSDirectory = $document_root."/Static/js";
  $JSURLPath   = $_BaseURL_."/Static/js";
}

unless ($ImgDirectory && $ImgURLPath) {
  $ImgDirectory = $document_root."/Static/img";
  $ImgURLPath   = $_BaseURL_."/Static/img";
}

if (!$Tar && $GTar) {
  $Tar = $GTar;
}

1;
