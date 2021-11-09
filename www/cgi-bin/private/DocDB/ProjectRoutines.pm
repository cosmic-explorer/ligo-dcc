#
# Description: These are routines that are specific to your installation and
#              should be customized for your needs. This file is a template
#              only. Make a copy of this file as ProjectRoutines.pm (no
# "template") and make your changes there. Basically you can use ProjectHeader,
# ProjectBodyStart, ProjectFooter, and DocDBFooter to make DocDB  web pages
# just like the web pages for the rest of your project. If you don't want to do
# any customization or just want to test DocDB, these routines work as-is.
# A global variable $Public is used (when set) to remove elements from the
# nav-bars that the public has no interest in. The variable is global
# and can control the style of your headers and footers too.
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

sub ProjectHeader {
  my ($Title,$PageTitle) = @_;

# This routine is reponsible for whatever HTML you want to write in the <HEAD>
# section of the page. You can embed style sheets, etc.
#
# $Title is what is in the <title> element while $PageTitle is the title  of
# the page you may put in the text of the page. They are provided here for
# your  convenience, but you should not print the <title> here since DocDB
# already takes  care of that.

# Here is a link to a style sheet.

#   print "<link rel=\"stylesheet\" href=\"/includes/style.css\" type=\"text/css\">\n";
}

sub ProjectBodyStart {

# This routine is called after the <body> tag is written. Here you can put your
# project specific HTML. You might want to put the document title too, as a
# header. ($Title is what is in the <title> element while $PageTitle is the
# title  of the page you may put in the text of the page.)

  my ($Title,$PageTitle) = @_;
  my @TitleParts = split /\s+/, $PageTitle;
  $PageTitle = join '&nbsp;',@TitleParts;

  print "<h1 id=title>$PageTitle</h1>\n";
  # show the navbar at the top of the page as well as at the bottom
  if ($dbh) {
     &DocDBNavBar();
  }
}

sub ProjectFooter {
  require "DocDBVersion.pm";

  my ($WebMasterEmail,$WebMasterName) = @_;

# This routine is reponsible for whatever you want to put as a footer on the
# page.
#
# Parameters are supplied for the name and e-mail address of the person
# responsible for the pages. We would appreciate it if you keep the link to
# the DocDB home page present.

# You probably want to include some version of this:

  print "<br><p style=\"clear:left\"><small>\n";
  print "<a href=\"$DocDBHome\">DCC</a> ";
  print "<a href=\"/login/news.shtml\">Version $DocDBVersion</a>, contact \n";
  print "<i>\n";
  print "<a href=\"mailto:$WebMasterEmail\">$WebMasterName</a>\n";
  print "</i>\n";
  print "</small><br/>\n";

# This prints benchmark info for pages that have it

  my $user_name = &remote_user;
  if ($UserValidation eq "kerberos" && $user_name ne "") {
    print "</p>";
    print "<small><b>Logged in as: </b>$user_name</small>\n";

    $EmailUserID = (&FetchEmailUserIDFromRemoteUser());
    my @UsersGroupIDs = ();
    @UsersGroupIDs = (&FetchUserGroupIDs($EmailUserID));
    print "<small><b>&nbsp; In Group(s): </b>";
    foreach my $UsersGroup (@UsersGroupIDs) {
        print "$SecurityGroups{$UsersGroup}{NAME} "
    }
### Only show execution time to members of docdbadm group:
    print "<br>\n";
    my $find = "14"; #docdbadm
    if(grep $_ eq $find, @UsersGroupIDs) {
       if ($EndTime && $StartTime) {
          my $TimeDiff = timediff($EndTime,$StartTime);
          print "<b>Execution time: </b>",timestr($TimeDiff),"\n";
       }
    }
###

    print "</small>\n";
  }

# Do not print the </body> and </html> tags, DocDB does that now.
}

sub DocDBNavBar {

# This routine prints the navigation bar just above the footer on the
# page.
# This provides a good default, but you can customize for your installation
# and include an optional extra description and URL (e.g. for a related page).


  my ($ExtraDesc,$ExtraURL) = @_;

  require "Security.pm";

  print "<div class=\"DocDBNavBar\">\n";
  print "<div id=serverstatus class=serverstatus></div>\n";

# Navbar list:
print "<ul class=topnav>\n";

  if ($ExtraDesc && $ExtraURL) {
    print "<li><a href=\"$ExtraURL\">$ExtraDesc</a>\n";
  }
  print "<li><a href=\"$MainPage\">Home</a>\n";
  if (&CanAdminister()) {
    print "<li><a href=\"$AdministerHome\">Administer</a>\n";
  }
  if (&CanCreate()) {
    print "<li><a href=\"$ReserveHome\">Reserve Number</a>\n";
  }
  # if (&CanCreate()) {
  #   print "<li><a href=\"$XMLUpdate\">Bulk Modify</a>\n";
  # }
  if (!$Public) {
      print "<li><a href=\"$SearchForm\">Search</a>\n";
  }
  print "<li><a href=\"$ListBy?days=$LastDays&maxdocs=$HomeMaxDocs\">Recent Changes</a>\n";
  print "<li><a href=\"$ListTopics\">Topics</a>\n";
  if (!$Public) {
     print "<li><a href=\"$ListAllMeetings\">Events</a>\n";
    print "<li><a href=\"$PublicMainPage\">Public</a>\n";
  }
  if ($Public) {
        print "<li><a href=\"$SecureMainPage\">Login</a>\n";
  }
  else {
     if (&CanAdminister()) {
        print "<li><a href=\"$ShibLogout\">Login</a>\n";
     }
     print "<li><a href=\"$WikiHelpPage\">Help</a>\n";
  }
# end list
print "</ul>\n";

  print "</div>\n";
}

sub ProjectReferenceLink (;$$$$) {
  my ($Acronym,$Volume,$Page,$ReferenceID) = @_;

# This routine is used to add links to and optionally replace the text of
# references specific to the project.
# See ReferenceLink in ReferenceLinks.pm for examples.

  my $ReferenceLink = "";
  my $ReferenceText = "";

  return ($ReferenceLink,$ReferenceText);
}

1;
