#        Name: TalkHTML.pm
# Description: HTML producing routines for talk entries related to meetings
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified: Stephen Wood (saw@jlab.org)

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

sub TalkEntryForm (@) {
  require "FormElements.pm";
  require "DocumentHTML.pm";

  my @SessionOrderIDs = @_;

  require "Scripts.pm";
  print "<table id=\"TalkEntryTable\" class=\"LowPaddedTable Alternating CenteredTable\">\n";
  print "<thead>\n";
  print "<tr>\n";
  print "<th>",FormElementTitle(-helplink => "sessionorder", -helptext => "Order,",  -nocolon => $TRUE);
  print        FormElementTitle(-helplink => "talketc",      -helptext => "etc.", -nocolon => $TRUE);
  print "</th>\n";
  print "<th>",FormElementTitle(-helplink => "talkdocid"    , -helptext => "Doc. #",            -nocolon => $TRUE),"</th>\n";
  print "<th>",FormElementTitle(-helplink => "talkinfo"     , -helptext => "Talk Title &amp; Note", -nocolon => $TRUE),"</th>\n";
  print "<th>",FormElementTitle(-helplink => "talktime"     , -helptext => "Time",              -nocolon => $TRUE),"</th>\n";
  print "<th>",FormElementTitle(-helplink => "authorhint"   , -helptext => "Author Hints",      -nocolon => $TRUE),"</th>\n";
  print "<th>",FormElementTitle(-helplink => "topichint"    , -helptext => "Topic Hints",       -nocolon => $TRUE),"</th>\n";
  print "</tr>\n";
  print "</thead>\n";

  # Sort session IDs by order

  my $ExtraTalks = 10;
  if (@SessionOrderIDs) { $ExtraTalks = 3; }
  for (my $Talk=1;$Talk<=$ExtraTalks;++$Talk) {
    push @SessionOrderIDs,"n$Talk";
  }

  my $TalkOrder = 0;
  foreach $SessionOrderID (@SessionOrderIDs) {

    ++$TalkOrder;
    if ($TalkOrder % 2) {
      $RowClass = "";
    } else {
      $RowClass = "alt";
    }
    $TalkDefaultOrder = $TalkOrder;
    my $EntryTimeStamp;

    @TalkDefaultTopicHints  = ();
    @TalkDefaultAuthorHints = ();
    if (grep /n/,$SessionOrderID) { # Erase defaults
      $TalkDefaultTime        = "00:30";
      $TalkDefaultConfirmed   = "";
      $TalkDefaultTitle       = "";
      $TalkDefaultNote        = "";
      $TalkSeparatorDefault   = "";
      $TalkDefaultDocID       = "";
      @TalkDefaultAuthorHints = ();
      @TalkDefaultTopicHints  = ();
    } else { # Key off Meeting Order IDs, do differently for Sessions and Separators
      if ($SessionOrders{$SessionOrderID}{SessionTalkID}) {
        my $SessionTalkID     = $SessionOrders{$SessionOrderID}{SessionTalkID};
        $TalkDefaultConfirmed = $SessionTalks{$SessionTalkID}{Confirmed}  || "";
        $TalkDefaultTime      = $SessionTalks{$SessionTalkID}{Time}       || "00:30";
        $TalkDefaultTitle     = $SessionTalks{$SessionTalkID}{HintTitle}  || "";
        $TalkDefaultNote      = $SessionTalks{$SessionTalkID}{Note}       || "";
        $TalkDefaultDocID     = $SessionTalks{$SessionTalkID}{DocumentID} || "";
        $TalkSeparatorDefault = "No";
        $EntryTimeStamp       = $SessionTalks{$SessionTalkID}{TimeStamp};
        # Get hints and convert to format accepted by scrolling lists

        my @TopicHintIDs = &FetchTopicHintsBySessionTalkID($SessionTalkID);
        foreach my $TopicHintID (@TopicHintIDs) {
          push @TalkDefaultTopicHints,$TopicHints{$TopicHintID}{TopicID};
        }
        my @AuthorHintIDs = &FetchAuthorHintsBySessionTalkID($SessionTalkID);
        foreach my $AuthorHintID (@AuthorHintIDs) {
          push @TalkDefaultAuthorHints,$AuthorHints{$AuthorHintID}{AuthorID};
        }
      } elsif ($SessionOrders{$SessionOrderID}{TalkSeparatorID}) {
        my $TalkSeparatorID   = $SessionOrders{$SessionOrderID}{TalkSeparatorID};
        $TalkDefaultConfirmed = "";
        $TalkDefaultTime      = $TalkSeparators{$TalkSeparatorID}{Time}  || "00:30";
        $TalkDefaultTitle     = $TalkSeparators{$TalkSeparatorID}{Title} || "";
        $TalkDefaultNote      = $TalkSeparators{$TalkSeparatorID}{Note}  || "";
        $TalkSeparatorDefault = "Yes";
        $EntryTimeStamp       = $TalkSeparators{$TalkSeparatorID}{TimeStamp};
      }
    }
    print "<tbody class=\"$RowClass\">\n";
    print "<tr>\n";

    print "<td rowspan=\"2\">\n";
     $query -> param('sessionorderid',$SessionOrderID);
     print $query -> hidden(-name => 'sessionorderid', -default => $SessionOrderID);
     print $query -> hidden(-name => 'timestamp',      -default => $EntryTimeStamp);
     &TalkOrder;                       print "<br/>\n";
     &TalkConfirm($SessionOrderID);
     &TalkReserve($SessionOrderID);
     &TalkDelete($SessionOrderID);
     &TalkSeparator($SessionOrderID);
    print "</td>\n";

    print "<td rowspan=\"2\">\n"; &TalkDocNumber($SessionOrderID);     print "</td>\n";
    print "<td>\n";               &TalkTitle($TalkDefaultTitle);   print "</td>\n";
    print "<td rowspan=\"3\">\n"; &TalkTimePullDown;               print "</td>\n";
    print "<td rowspan=\"3\">\n"; &TalkAuthors($SessionOrderID);   print "</td>\n";
    print "<td rowspan=\"3\">\n"; &TalkTopics($SessionOrderID);    print "</td>\n";
    print "</tr>\n";
    print "<tr>\n";
    print "<td>\n"; &TalkNote; print "</td>\n";
    print "</tr>\n";
    print "<tr>\n";
    print "<td colspan=\"2\">\n"; &TalkNewSession($SessionOrderID); print "</td>\n";
    if ($TalkDefaultDocID && $TalkSeparatorDefault ne "Yes") {
      my $TitleLink = &DocumentLink(-docid => $TalkDefaultDocID, -titlelink => $TRUE);
      print "<td colspan=\"2\">Match: $TitleLink</td>\n";
    } else {
      print "<td colspan=\"2\">&nbsp;</td>\n";
    }
    print "</tr>\n";
    print "</tbody>\n";
  }
  print "</table>\n";
}

sub TalkTitle ($) {
  $query -> param('talktitle',$TalkDefaultTitle);
  print $query -> textfield (-name => 'talktitle', -size => 40, -maxlength => 128,
                             -default => $TalkDefaultTitle);
}

sub TalkNote {
  $query -> param('talknote', $TalkDefaultNote);
  print $query -> textarea (-name => 'talknote',-value => $TalkDefaultNote,
                            -columns => 40, -rows => 4);
}

sub TalkDelete ($) {
  my ($SessionOrderID) = @_;
  if ($TalkSeparatorDefault eq "Yes" || $TalkSeparatorDefault eq "No") {
    print $query -> checkbox(-name  => "talkdelete",
                             -value => "$SessionOrderID", -label => 'Delete');
    print "<br/>\n";
  }
}

sub TalkConfirm ($) {
  my ($SessionOrderID) = @_;

  if ($TalkSeparatorDefault eq "Yes") {
#    print "&nbsp;\n";
  } elsif ($TalkDefaultConfirmed) {
    print $query -> checkbox(-name  => "talkconfirm", -checked => 'checked',
                             -value => "$SessionOrderID", -label => 'Confirm');
    print "<br/>\n";
  } else {
    print $query -> checkbox(-name  => "talkconfirm",
                             -value => "$SessionOrderID", -label => 'Confirm');
    print "<br/>\n";
  }
}

sub TalkReserve ($) {
  my ($SessionOrderID) = @_;

  if ($TalkSeparatorDefault eq "Yes") {
#    print "&nbsp;\n";
  } elsif ($TalkDefaultConfirmed) {
#    print "&nbsp;\n";
  } else {
    print $query -> checkbox(-name  => "talkreserve",
                             -value => "$SessionOrderID", -label => 'Reserve');
    print "<br/>\n";
  }
}

sub TalkOrder {
  $query -> param('talkorder',$TalkDefaultOrder);
  print $query -> textfield (-name => 'talkorder', -value => $TalkDefaultOrder,
                             -size => 4, -maxlength => 5);
}

sub TalkSeparator ($) {
  my ($SessionOrderID) = @_;

  if ($TalkSeparatorDefault eq "Yes") {
    print "Break\n";
    print "<br/>\n";
  } elsif ($TalkSeparatorDefault eq "No") {
#    print "No\n";
#    print "<br/>\n";
  } else {
    $query -> param('talkseparator', "");
    print $query -> checkbox(-name => "talkseparator", -value => "$SessionOrderID", -label => 'Break');
    print "<br/>\n"
  }
}

sub TalkDocNumber {
  my ($SessionOrderID) = @_;
  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } else {
    require "DocumentSQL.pm";
    my $TalkDocAlias = FetchDocumentAlias($TalkDefaultDocID);
    $query -> param("talkdocid-$SessionOrderID",$TalkDefaultAlias);
    print $query -> textfield (-name  => "talkdocid-$SessionOrderID", 
                               -default => $TalkDocAlias,
                               -size  => 8, -maxlength => 8);
  }
}

sub TalkTimePullDown {

  require "SQLUtilities.pm";

  my $DefaultTime = &TruncateSeconds($TalkDefaultTime);

  my @hours = ("----");
  for (my $Hour = 0; $Hour<=5; ++$Hour) {
    for (my $Min = 0; $Min<=59; $Min=$Min+5) {
      push @hours,sprintf "%2.2d:%2.2d",$Hour,$Min;
    }
  }

  $query -> param('talktime', $DefaultTime);
  print $query -> popup_menu (-name => 'talktime', -values => \@hours,
                              -default => $DefaultTime);
}

sub TalkAuthors ($) {
  my ($SessionOrderID) = @_;

  require "AuthorHTML.pm";

  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } else {
    if ($AuthorMode eq "field") {
      unless (@TalkDefaultAuthorHints) {
        $query -> param("authortext-$SessionOrderID","");
      }
      AuthorTextEntry( {-name    => "authortext-$SessionOrderID", -helplink => "",
                        -default => \@TalkDefaultAuthorHints} );
    } else {
      unless (@TalkDefaultAuthorHints) {
        $query -> param("authors-$SessionOrderID","");
      }
      &AuthorScroll(-helplink => "", -name => "authors-$SessionOrderID",
                    -default  => \@TalkDefaultAuthorHints, -multiple => $TRUE);
    }
  }
}

sub TalkTopics ($) {
  my ($SessionOrderID) = @_;

  require "TopicHTML.pm";

  if ($TalkSeparatorDefault eq "Yes") {
    print "&nbsp;\n";
  } else {
    unless (@TalkDefaultTopicHints) {
      $query -> param("topics-$SessionOrderID","");
    }
    TopicScroll({ -name     => "topics-$SessionOrderID", -required   => $RequiredEntries{Topic},
                  -default  => \@TalkDefaultTopicHints,  -multiple   => $TRUE,
                  -helplink => "",                       -itemformat => "short",
               });
  }
}

sub TalkNewSession ($) {
  my ($SessionOrderID) = @_;

  require "MeetingSQL.pm";

  my $SessionTalkID   = $SessionOrders{$SessionOrderID}{SessionTalkID};
  my $TalkSeparatorID = $SessionOrders{$SessionOrderID}{TalkSeparatorID};

  my $SessionID;
  if ($SessionTalkID) {
    $SessionID = $SessionTalks{$SessionTalkID}{SessionID};
  } elsif ($TalkSeparatorID) {
    $SessionID = $TalkSeparators{$TalkSeparatorID}{SessionID};
  }

  my $ConferenceID = $Sessions{$SessionID}{ConferenceID};

  &FetchSessionsByConferenceID($ConferenceID); # Get names of all sessions

  my @SessionIDs = ("0");
  $SessionLabels{0} = "Move to new session?";

# To get them all in order, have to use MeetingOrderIDs

  my @MeetingOrderIDs = &FetchMeetingOrdersByConferenceID($ConferenceID);
  @MeetingOrderIDs = sort MeetingOrderIDByOrder @MeetingOrderIDs;
  foreach my $MeetingOrderID (@MeetingOrderIDs) { # Loop over sessions/breaks
    my $SessionID          = $MeetingOrders{$MeetingOrderID}{SessionID};
    if ($SessionID) {
      push @SessionIDs,$SessionID;
      $SessionLabels{$SessionID} = $Sessions{$SessionID}{Title};
    }
  }

  print $query -> popup_menu (-name    => "newsessionid-$SessionOrderID",
                              -labels => \%SessionLabels,
                              -values  => \@SessionIDs);
}

sub SessionTalkPulldown {
  my (@SessionTalkIDs) = @_;

  require "TalkHintSQL.pm";
  require "AuthorSQL.pm";

  my %SessionTalkLabels = ();

  foreach my $SessionTalkID (@SessionTalkIDs) {
    $SessionTalkLabels{$SessionTalkID} = &SessionTalkSummary($SessionTalkID);
  }
  $SessionTalkLabels{0} = "Select your talk from this list";
  unshift @SessionTalkIDs,"0";

  print FormElementTitle(-helplink => "talkfromagenda", -helptext => "Talk from Agenda");
  print $query -> popup_menu (-name    => 'sessiontalkid',
                              -labels => \%SessionTalkLabels,
                              -values  => \@SessionTalkIDs);

}

sub SessionTalkSummary {
  my ($SessionTalkID) = @_;

  require "TalkHintSQL.pm";
  require "AuthorSQL.pm";

  my @AuthorHintIDs = &FetchAuthorHintsBySessionTalkID($SessionTalkID);
  my @Authors = ();
  foreach my $AuthorHintID (@AuthorHintIDs) {
    my $AuthorID = $AuthorHints{$AuthorHintID}{AuthorID};
    &FetchAuthor($AuthorID);
    $Author = $Authors{$AuthorID}{FULLNAME};
    push @Authors,$Author;
  }

  my $SessionTalkSummary = "";

  my $Authors = join ', ',@Authors;
  if ($SessionTalks{$SessionTalkID}{HintTitle}) {
    $SessionTalkSummary = $SessionTalks{$SessionTalkID}{HintTitle};
  } else {
    $SessionTalkSummary = "Unknown";
  }
  $SessionTalkSummary .= " - ";
  if (@Authors) {
    $SessionTalkSummary .= $Authors;
  } else {
    $SessionTalkSummary .= "Unknown";
  }
  return $SessionTalkSummary;
}

# Note on replacing NOBR. Error is in standard spec, but all implementations
# Obey

# > I strive to make XHTML files that validate. But when I have something like a
# > phone number or social security number that I don't want the browser to
# > break apart I have to use the <nobr> tag to do that. The <nobr> tag,
#> however, keeps the page from validating. Unfortunately, I can't find any
#> kind of "break" style in the CSS spec that would allow me to create a class
#> that would tell the browser to do basically what the <nobr> tag
#> does--something like <span class="PhoneNumber">999-999-9999</span>.
#>
#> Is there an alternative to the <nobr> tag

#In your example, this style rule:
#
#.PhoneNumber { white-space: nowrap; }

#> that works in all of the browsers?

#That works in all browsers that support all CSS1 properties (of which there
#are now several).

1;
