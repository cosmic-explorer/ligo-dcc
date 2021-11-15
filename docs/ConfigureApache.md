# Filesystem layout
## /usr1
the application is a series of cgi scripts that live in /usr1/www/cgi-bin

- the private version of dcc is stored in ```/usr1/www/cgi-bin/private/DocDB ```
- the public version of the dcc is in ```/usr1/www/cgi-bin/DocDB```
- the landing page of the private site also serves as login screen it is located at ``` /usr1/www/html/login```
- the javascript and cascading stylesheets are in ```/usr1/www/html/Static``` 
- the files associated with the documents for the private site are in ```/usr1/www/html/DocDB```
- the files of the public documents are actually symlinks in ```/usr1/www/html/public/DocDB```  :zap: (not the Static directory)

Currently ```/usr1/www/html/DocDB``` represents ~ 2.7TB. I suggest to start with a zfs pool of 4 TB. 

## /usr2
- database : ```/usr2/mysql```  holds the mysql database so it is to be used where one usually expects ```/var/lib/mysql```
- GLIMPSE : the metadata used for document search are stored there this includes a "shadow copy" of the files which are translated from binary blobs (docs, xls, pdf, etc) to ascii files prior to indexing by glimpse

current requirement for this partition is 16GB

## install dcc scripts:

- untar [docdb-3.2.2.tar.gz](uploads/39d38ac144bff55bdbf03691ce0d66c4/docdb-3.2.2.tar.gz) to ```/usr1/www/cgi-bin/private```
- modify SiteConfig.pm to match the host parameters (namely db usernames and password)
- if setting up an independent DCC, modifiy ProjectGlobals.pm and define a new project name / project short. you will need to adjust the apache url rewrite rules accordingly
- in ```/usr1/www/cgi-bin/DocDB``` copy or symlink the content of ```/usr1/www/cgi-bin/private/DocDB```
- replace SiteConfig.pm with the following adjusted to the actual host (DB password, $hostname...)
```perl 
#
# Description: Configuration file for site specific settings.
#              This file is included in every DocDB program.
#
#      Author: Melody C. Araya (maraya@ligo.caltech.edu)
#    Modified:
#
# Copyright 2011 Melody C. Araya

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


# DB settings

$db_name       = "dcc_docdb";               # Database name
$db_host       = "localhost";
$db_rwuser     = "";             # You can change the names of the accounts if you are
$db_rwpass     = "";             # hosting more than one DocDB on the same SQL server
$db_rouser     = "docdb_readonly";      # (for two different projects). Otherwise its probably
$db_ropass     = "docdb_password";      # best just to leave the names as-is.

# Root directories and URLs

$file_root   = "/usr1/www/html/public/";
$script_root = "/usr1/www/cgi-bin/DocDB/";
$public_root = "/usr1/www/html/public/";

# PRODUCTION SITE

# Gives us "hostname" from $HOSTNAME
use Sys::Hostname;
# #
$host_name = 'https://'.hostname.'.ligo.org/';
# #
$web_root        = $host_name."public/";
$wiki_root       = $host_name."wiki/index.php";
$cgi_root        = $host_name."cgi-bin/DocDB/";
$Public_cgi_root = $host_name."cgi-bin/DocDB/";
$secure_root     = $host_name."cgi-bin/private/DocDB/";
# #
$DocDBHome = $host_name."/wiki/index.php/Main_Page";

$ContentSearchReturns = "/usr1/www/html/DocDB/";

$WelcomeMessage = "This is the repository of $Project talks, publications, and other documents.";

# Location of the script called for server status updates
$ServerStatusUrl  = "/cgi-bin/DocDB/serverstatus.sh";

# Server status polling interval in milliseconds
$ServerStatusPollInterval  = "900000";

$ReadOnly       = 0;            # Can be used in conjunction with individual
                                # authorization methods to set up a group-like
                                # area with group passwords which can view
                                # but not change any info
#$ReadOnlyAdmin  = 0;           # Allows administration from the read-only
                                # area. Only suggested for boot-strapping until
                                # you have an individual selected as admin

#$UseSignoffs          = 0;     # Sign-off system for document approval
#$MailInstalled        = 1;     # Is the Mailer::Mail module installed?
#$MailServer           = "";

# These settings are for public version of DB. Uncomment these five lines
# for the version of this file you place in the public area. While only the
# first is probably necessary, as a precaution its wise to do the other 4 as
# well.

$Public           = 1;
$remote_user      = ""; # Just to be safe
$RemoteUsername   = ""; # Just to be safe
$db_rwuser        = ""; # Just to be safe
$db_rwpass        = ""; # Just to be safe

1;
```
- adjust /usr1/www/cgi-bin/DocDB/ProjectGlobals.pm as needed :
```perl
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
$DBWebMasterName  = "Document Database Administrators";

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
$HomeMaxDocs          = 50;    # Maximum number of documents on home page
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

$UserValidation = "kerberos";   # || "basic" || "certificate"
                                # Do we do group authorization like V5 and before
                                # or do we allow .htaccess/.htpasswd users to map to groups
                                # (basic) or map REMOTE_USER to groups (kerberos certificate)
$GroupSuffix = "\@ligo\.org";   # Important: If the group suffix does not match the keytab,
                                # permissions are not enabled.


$ContentSearch                   =  "/usr/local/bin/glimpse-query.sh";
$IncrementalContentSearch        =  "/usr/local/bin/glimpse-incr.sh";

if ($Public) {
     $ContentSearchReturns       =  "/usr1/www/html/DocDB";;
} else {
     $ContentSearchReturns       =  $file_root;
}

$DefaultViewAccess    = 1;      #
$UseAliasAsFileName   = 1;      # Use an alternative naming convention instead
                                # of using the docid as the document identifier.

$Obsolete_Group          = "Obsolete";       # Group where obsoleted versions are put into.
$Public_Group            = "Public_Pending"; # Public Group
$AuthorsOnly_Group       = "Authors";        # Authorship Group
$AuthorsOnly_GroupSuffix = "_Authors";       # HTDBM File Group Suffix


1;
```
 
# Apache 
- /etc/httpd/conf.d/dcc.private.conf
```
##
## /cgi-bin script alias is COMMENTED OUT in httpd.conf to avoid collisions
## and overlaps with dcc's urls
## therefore othe cgi apps (bugzilla , awstats etc) need to define their own
## set of aliases
##


#
# glimpse search can take a loooooong time
#
Timeout 1000

#
#  this serves as a blanket to restrict access to ANYTHING served
#  One must take care of expanding or restricting access control
#  based on location
#  e.g. /login requires 'all granted' to allow unauthenticated user to get to the login page

#
# You MUST enable AuthType shibboleth for the module to process
# any requests, and there MUST be a require command as well. To
# enable Shibboleth but not specify any session/access requirements
# use "require shibboleth".
#
<Location />
    DirectoryIndex index.html index.cgi index.php /dcc
    AuthType shibboleth
    AuthName "This content is viewable by only LIGO/Virgo personnel. Please enter your LIGO Directory name, e.g. albert.einstein, and password to continue."
    ShibRequestSetting RequireSession true
    <RequireAll>
 	 require shib-session
    </RequireAll>
    XbitHack on
</Location>

#
#  landing page uses images stored at url root. These need explicit relaxed permissions
#
<LocationMatch "^/.*\.(gif|jpe?g|png|ico)$">
    Require all granted
</LocationMatch>

#
#  where the private version of the dcc code lives
#  using the alias and Location shoudl make the move away
#  from /usr1 easier.
#
Alias /cgi-bin/private/DocDB /usr1/www/cgi-bin/private/DocDB

ScriptAlias /dcc /usr1/www/cgi-bin/private/DocDB/DocumentDatabase

<Location "/cgi-bin/private/DocDB">
	Options +ExecCGI +Indexes
	DirectoryIndex DocumentDatabase
	SetHandler cgi-script
</Location>


#
# where the files attached to the documents live
# ultimately I want it to be /dcc/data but for now I'll
# accept /usr1/www/html b/c symlinking of public docs
#

DefineExternalGroup dccauth environment /usr1/www/cgi-bin/private/DocDB/RemoteUserHasAccess
Alias "/DocDB" "/usr1/www/html/DocDB"
<Location "/DocDB">
 	Options +Indexes
        AuthType shibboleth
        AuthName "This content is viewable by only LIGO/Virgo personnel. Please enter your LIGO Directory name, e.g. albert.einstein, and password to continue."
        ShibRequestSetting requireSession true
        <RequireAll>
            GroupExternal dccauth
            Require external-group foobar
            Require all granted
	</RequireAll>
</Location>


<LocationMatch "/.*\.(js|css)$">
	Require all granted
</LocationMatch>

RewriteEngine On
RewriteCond %{HTTPS} !on
RewriteRule ^/(.*) https://%{SERVER_NAME}%{REQUEST_URI} [R]
```

- short_urls.private.conf : url rewrite rules for the private site
```
<Directory "/usr1/www/html">

	# regex that macthes common file extensions
        Define LIGO_EXTENSION_LIST pdf|ppt[x]?|doc[x]?|htm[l]?|t[e]?xt|easm|jp[e]?g|xls[x]?|gif|tif[f]?|png|bmp|zip|tar|odp|dwg|tex|ps|avi|w[am]v|mp[e]?[gpx34]|
mov|dat|slddrw|sldprt|fpd

	# regex matching a dcc document designation
	Define LIGO_DOCUMENT_PATTERN ^(LIGO\-)?([A-Z]\d{6,7}|d+)(-[vx])?(\d+)?

        # regex that matches the end of a url : .../ .../main .../main/
        Define LIGO_URL_TAIL (/main)?

        # Extensive logs during the setup phase, remove at MTP
	LogLevel alert rewrite:trace4

        RewriteEngine On
        RewriteBase /
        Options +FollowSymLinks

        ## Do not rewrite if already pointing to a valid file or directory
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d


	## Document Card
	## Input  : /LIGO-M080351-v3 or /M080351-x0/main or /M080351/
        ## Output : /cgi-bin/private/DocDB/ShowDocument?docid=M080351&version=3
	RewriteRule ${LIGO_DOCUMENT_PATTERN}${LIGO_URL_TAIL}/?$ /cgi-bin/private/DocDB/ShowDocument\?docid\=$2\&version=$4 [QSA,NC]

	## Get Main File
	## Input  : /LIGO-M080351-v15/main
	## Output : /cgi-bin/private/DocDB/RetrieveFile\?docid\=M080351
	RewriteRule ${LIGO_DOCUMENT_PATTERN}${LIGO_URL_TAIL}/?  /cgi-bin/private/DocDB/RetrieveFile\?docid\=$2 [QSA,NC]

	## retrieve file with alternate extension
	## Input  : /LIGO-M080351-v3.pdf
	## Output : /cgi-bin/private/DocDB/RetrieveFile\?docid\=M080351&version=3&extension=pdf
 	RewriteRule ${LIGO_DOCUMENT_PATTERN}\.(${LIGO_EXTENSION_LIST}) /cgi-bin/private/DocDB/RetrieveFile\?docid\=$2\&version\=$4\&extension\=$5 [QSA,NC]
```
-  short_urls.private.conf
```
<Directory "/var/www/html">

	# regex that macthes common file extensions
        Define LIGO_EXTENSION_LIST pdf|ppt[x]?|doc[x]?|htm[l]?|t[e]?xt|easm|jp[e]?g|xls[x]?|gif|tif[f]?|png|bmp|zip|tar|odp|dwg|tex|ps|avi|w[am]v|mp[e]?[gpx34]|mov|dat|slddrw|sldprt|fpd

	# regex matching a dcc document designation
	Define LIGO_DOCUMENT_PATTERN ^(LIGO\-)?([A-Z]\d{6,7}|d+)(-[vx])?(\d+)?

        # regex that matches the end of a url : .../ .../main .../main/
        Define LIGO_URL_TAIL (/main)?

        # Extensive logs during the setup phase, remove at MTP
	LogLevel alert rewrite:trace4

        RewriteEngine On
        RewriteBase /
        Options +FollowSymLinks

        ## Do not rewrite if already pointing to a valid file or directory
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d


	## Document Card
	## Input  : /LIGO-M080351-v3 or /M080351-x0/main or /M080351/
        ## Output : /cgi-bin/private/DocDB/ShowDocument?docid=M080351&version=3
	RewriteRule ${LIGO_DOCUMENT_PATTERN}${LIGO_URL_TAIL}/?$ /cgi-bin/private/DocDB/ShowDocument\?docid\=$2\&version=$4 [QSA,NC]

	## Get Main File
	## Input  : /LIGO-M080351-v15/main
	## Output : /cgi-bin/private/DocDB/RetrieveFile\?docid\=M080351
	RewriteRule ${LIGO_DOCUMENT_PATTERN}${LIGO_URL_TAIL}/?  /cgi-bin/private/DocDB/RetrieveFile\?docid\=$2 [QSA,NC]

	## retrieve file with alternate extension
	## Input  : /LIGO-M080351-v3.pdf
	## Output : /cgi-bin/private/DocDB/RetrieveFile\?docid\=M080351&version=3&extension=pdf
 	RewriteRule ${LIGO_DOCUMENT_PATTERN}\.(${LIGO_EXTENSION_LIST}) /cgi-bin/private/DocDB/RetrieveFile\?docid\=$2\&version\=$4\&extension\=$5 [QSA,NC]

	## Generate XML
	## Input  : /LIGO-M080351-v3/of=xml
        ## Output : /cgi-bin/private/DocDB/ShowDocument?docid=M080351&version=3&outformat=xml
	RewriteRule ${LIGO_DOCUMENT_PATTERN}/?of=(xml|html)?$ /cgi-bin/private/DocDB/ShowDocument\?docid\=$2\&version\=$4\&outformat\=$6 [QSA,NC]


   ## not sure what these rules are for.
   ## public:
    # filenames with pound sign:
    RewriteRule ![\ #]+$ - [S=1]
    RewriteRule ^(LIGO-)?(\w{1}\d{6,7}|\d{1,})(-[vx])?(\d{1,})?(.*)$ /cgi-bin/private/DocDB/Search\?maxdocs\=10\&outerlogic\=AND\&innerlogic\=AND\&numbersearch\=$2\&numbersearchmode\=allsub [QSA,NC,NE]
    # generic filename rule:
    RewriteRule ^(LIGO-)?(\w{1}\d{6,7}|\d{1,})(-[vx])?(\d{1,})?/(.*)$ /cgi-bin/private/DocDB/RetrieveFile\?docid\=$2\&version\=$4\&filename\=$5 [QSA,NC,NE]

</Directory>
```

- dcc.public.conf
```
Alias "/pub" "/usr1/www/html/DocDB"
Alias /cgi-bin/DocDB /usr1/www/cgi-bin/DocDB

<Location "/cgi-bin/DocDB">
        Require all granted
        Options +ExecCGI +Indexes +FollowSymlinks
        DirectoryIndex DocumentDatabase
        SetHandler cgi-script
</Location>

Alias /public /usr1/www/html/public
<Location "/public">
	Options +Indexes +FollowSymLinks +IncludesNoExec +ExecCGI
	require all granted
	DirectoryIndex "/cgi-bin/DocDB/DocumentDataBase"
</Location>
```

- short_urls.public.conf url rewrite for the public site
```
<LocationMatch ^/(.+)/public>

	Require all granted

	# regex that macthes common file extensions
        Define LIGO_EXTENSION_LIST pdf|ppt[x]?|doc[x]?|htm[l]?|t[e]?xt|easm|jp[e]?g|xls[x]?|gif|tif[f]?|png|bmp|zip|tar|odp|dwg|tex|ps|avi|w[am]v|mp[e]?[gpx34]|
mov|dat|slddrw|sldprt|fpd

        # regex that matches the end of a public url : .../public .../main/public .../public/main .../main/public/main with or without trailing /
        Define LIGO_PUBLIC_TAIL (/main)?/public(/main)?

	# regex matching a dcc document designation
	Define LIGO_DOCUMENT_PATTERN (LIGO\-)?([A-Z]\d{6,7}|d+)(-[vx])?(\d+)?


        # Extensive logs during the setup phase, remove at MTP
	LogLevel alert rewrite:trace4
	RewriteEngine on
	## Do not rewrite if already pointing to a valid file or directory
	RewriteCond %{REQUEST_FILENAME} !-f
	RewriteCond %{REQUEST_FILENAME} !-d


	## Get Main File
	## Input  : /LIGO-M080351-v15/main/public
	## Output : /cgi-bin/DocDB/RetrieveFile\?docid\=M080351
	RewriteRule ${LIGO_DOCUMENT_PATTERN}${LIGO_PUBLIC_TAIL}/?  /cgi-bin/DocDB/RetrieveFile\?docid\=$2 [QSA,NC]

	## retrieve file with alternate extension
	## Input  : /LIGO-M080351-v3.pdf/public
	## Output : /cgi-bin/DocDB/RetrieveFile\?docid\=M080351&version=3&extension=pdf
 	RewriteRule ${LIGO_DOCUMENT_PATTERN}\.(${LIGO_EXTENSION_LIST}) /cgi-bin/DocDB/RetrieveFile\?docid\=$2\&version\=$4\&extension\=$5 [QSA,NC]


	## Document Card
	## Input  : /LIGO-M080351-v3/public/ or /M080351-x0/main/public or /M080351/public/main
        ## Output : /cgi-bin/DocDB/ShowDocument?docid=M080351&version=3
	RewriteRule ${LIGO_DOCUMENT_PATTERN}${LIGO_PUBLIC_TAIL}/?$ /cgi-bin/DocDB/ShowDocument\?docid\=$2\&version=$4 [QSA,NC]

	## Generate XML
	## Input  : /LIGO-M080351-v3/public/of=xml
        ## Output : /cgi-bin/DocDB/ShowDocument?docid=M080351&version=3&outformat=xml
# fails with error message:
#There were errors processing your request:
#    File names with / are not allowed for security reasons.

	RewriteRule ${LIGO_DOCUMENT_PATTERN}/public/of=(xml|html)?$ /cgi-bin/DocDB/ShowDocument\?docid\=$2\&version\=$4\&outformat\=$6 [QSA,NC]


   ## not sure what these rules are for.
   ## public:
    # filenames with pound sign:
    RewriteRule ![\ #]+$ - [S=1]
#    RewriteRule ^(LIGO-)?(\w{1}\d{6,7}|\d{1,})(-[vx])?(\d{1,})?(.*)$ /cgi-bin/DocDB/Search\?maxdocs\=10\&outerlogic\=AND\&innerlogic\=AND\&numbersearch\=$2\&numbersearchmode\=allsub [QSA,NC,NE]
    # generic filename rule:
#    RewriteRule ^(LIGO-)?(\w{1}\d{6,7}|\d{1,})(-[vx])?(\d{1,})?/(.*)$ /cgi-bin/DocDB/RetrieveFile\?docid\=$2\&version\=$4\&filename\=$5 [QSA,NC,NE]

</LocationMatch>
```
