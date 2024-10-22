#
# Description: Configuration file for your projects DocDB settings. 
#              Set variables  for server names, accounts, and command 
#              paths here.
#              Rename as ProjectGlobals.pm
#              This file is included in every DocDB program.
#              You can override any settings in DocDBGlobals.pm here.
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: 

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

$Project        = "LIGO";
$ShortProject   = "LIGO";    # This is the project used in the Document ID
require "SiteConfig.pm";

$cgi_path    = "/cgi-bin/"; # Used for cookies

# Name and e-mail address of the administrators (or mailing list for admins)

$DBWebMasterEmail = "dcc-help\@ligo.org";
#$DBWebMasterName  = "Document Database Administrators";
$DBWebMasterName  = "DCC Help";

# Text customization. Leave $WelcomeMessage blank for no message on top of DB
# BTeV uses a welcome message for the public part of the DB, but not for the
# private

$FirstYear      = 1990;           # Earliest year that documents can be created
$WelcomeMessage = "This is the repository of $Project talks, publications, and other documents.";

# ----- No other changes are needed for the non-public version of the DocDB.
# ----- However, there are other configuration settings you may want to investgate

# If you are just linking executables for the public version of the database
# you need to include lines like these three to pick up the .pm files from 
# the default location. Replace /www/cgi-bin/DocDB with your path.

#if (-e "/www/cgi/DocDBGlobals.pm") {
#  use lib "/www/cgi-bin/DocDB/";
#}

# ----- No other changes are needed for the DocDB. However, there are 
# ----- other configuration settings you may want to investgate

# ----- At this point you can also change any of the other variables in
# ----- DocDBGlobals.pm for things like $HomeLastDays, command locations
# ----- (if not using Linux) etc.

#$LastDays             = 20;    # Number of days for default in LastModified
$HomeLastDays         = 2;     # Number of days for last modified on home page
$HomeMaxDocs          = 500;    # Maximum number of documents on home page
#$MeetingWindow        = 7;     # Days before and after meeting to preselect
#$TalkHintWindow       = 7;     # Days before and after to guess on documents
#$MeetingFiles         = 3;     # Number of upload boxes on meeting short form
#$InitialSessions      = 5;     # Number of initial sessions when making meeting

#$Wget   = "/usr/bin/wget --no-check-certificate"; # --no-check is not default, enable if needed
                                                   # useful when fetching from https with "invalid" certs
#$Tar    = "";                     # Set this if you don't have GNU tar
#$GTar   = "/bin/tar ";            # Set this if you do have GNU tar (e.g. Linux)
#$GZip   = "/bin/gzip ";           # Currently only needed if non-GNU tar
#$GUnzip = "/bin/gunzip ";         # Currently only needed if non-GNU tar
#$Unzip  = "/usr/bin/unzip -q ";
#$Zip    = "/usr/bin/zip -q -r ";  # Set to "" in ProjectGlobals if not installed

#$TmpDir = "/tmp/";

#$PublicAccess{MeetingList} = 0;  
  
# ----- These are some options for extra features of the DocDB that can be 
# ----- enabled. Values shown are defaults, change 0 -> 1 to enable a feature.
# ----- There are a lot of other options shown in DocDBGlobals.pm. You can
# ----- change any of them here.

#$CaseInsensitiveUsers = 0;     # Can use "Project" for a name in the 
                                # security groups, but "project" in .htaccess 

$EnhancedSecurity     = 1;      # Separate lists for view, modify
$SuperiorsCanModify   = 1;      # In enhanced model, a superior group can modify
                                # a subordinate groups documents without explicit
                                # permission

$Public_QAcheck       = 1;      # Setting document QA state to this (along with empty view ids)
                                # makes the document public
                                # Setting document QA state to this with not empty view ids
                                # makes document have the view ids as viewable by

$PublicPending_QA     = 0;      # Setting document QA state to this (along with 1 in view ids)
                                # makes document public pending

$UserValidation = "kerberos";   # || "basic" || "certificate"
                                # Do we do group authorization like V5 and before
			        # or do we allow .htaccess/.htpasswd users to map to groups (basic)
			        # or map REMOTE_USER to groups (kerberos certificate)			       

$GroupSuffix = "\@ligo\.org";   # Important: If the group suffix does not match the keytab, permissions
                                # are not enabled.


$ContentSearch                   =  "/usr/local/bin/glimpse-query.sh";
#$IncrementalContentSearch        =  "/usr/local/bin/glimpse-incr.sh";
$IncrementalContentSearch        =  "/usr/bin/redis-cli LPUSH incremental";
$PNPReviewURL                    =  'https://'.$pnp_host_name.'/Shibboleth.sso/Login?target=https://'.$pnp_host_name.'/';
$NCatPort                        = 6666;
$NCatCommand                     =  "/usr/bin/ncat --send-only  ".$pnp_host_name." ".$NCatPort;

if ($Public) {
     $ContentSearchReturns       =  "/usr1/www/html/DocDB";;
} else {
     $ContentSearchReturns       =  $file_root;
}

$DefaultViewAccess    = 1;      #
$UseAliasAsFileName   = 1;      # Use an alternative naming convention instead
                                # of using the docid as the document identifier.

$Obsolete_Group  = "Obsolete";          # Group where obsoleted versions are put into.
$Public_Group    = "Public_Pending";    # Public Group 
$AuthorsOnly_Group = "Authors";         # Authorship Group 
$Certify_Group     = "Public_Certify";  # Group which can make documents public
$AuthorsOnly_GroupSuffix= "_Authors";   # HTDBM File Group Suffix

%ReviewStates = (
    0 => "Not Submitted",
    1 => "Draft Submitted",
    2 => "Under Review",
    3 => "Accepted",
    4 => "Withdrawn"
);

$Presentation_DocType = 5;     # G - documents
$Publication_DocType  = 8;     # P - documents

@ReviewableDocTypes = (
    $Presentation_DocType,
    $Publication_DocType
);

$ReviewAsOf = "2014-08-01";

$InitiatePnP = "Initiate P&P Review";
$GotoPnPSite = "Go to P&P Website";

1;
