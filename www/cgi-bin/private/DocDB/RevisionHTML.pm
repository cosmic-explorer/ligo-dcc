#        Name: $RCSfile: RevisionHTML.pm,v $
# Description:
#    Revision: $Revision: 1.15.2.17 $
#    Modified: $Author: vondo $ on $Date: 2007/08/07 12:42:40 $
#
#      Author: Eric Vaandering (ewv@fnal.gov)
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

sub DccNumberBox (%) {
  my (%Params) = @_;
  #FIXME: Get rid of global default

  my $Required   = $Params{-required}   || 0;

  my $ElementTitle = &FormElementTitle(-helplink  => "oldnumber" ,
                                       -helptext  => "Old DCC Number" ,
                                       -extratext => "(e.g. M080351)" ,
                                       -required  => $Required );
  print $ElementTitle,"\n";
  print $query -> textfield (-name => 'oldnumber', -default => "",
                             -size => 8, -maxlength => 8);
};

sub TitleBox (%) {
  my (%Params) = @_;
  #FIXME: Get rid of global default

  my $Required   = $Params{-required}   || 0;

  my $ElementTitle = &FormElementTitle(-helplink  => "title" ,
                                       -helptext  => "Title" ,
                                       -required  => $Required );
  print $ElementTitle,"\n";
  print $query -> textfield (-name => 'title', -default => $TitleDefault,
                             -size => 70, -maxlength => 240);
};

sub AbstractBox (%) {
  my (%Params) = @_;
  #FIXME: Get rid of global default

  my $Required = $Params{-required} || 0;
  my $HelpLink = $Params{-helplink} || "abstract";
  my $HelpText = $Params{-helptext} || "Abstract";
  my $Name     = $Params{-name}     || "abstract";
  my $Columns  = $Params{-columns}  || 60;
  my $Rows     = $Params{-rows}     ||  6;

  my $ElementTitle = &FormElementTitle(-helplink  => $HelpLink ,
                                       -helptext  => $HelpText ,
                                       -required  => $Required );
  print $ElementTitle,"\n";
  print $query -> textarea (-name    => $Name, -default => $AbstractDefault,
                            -id      => $Name, 
                            -rows    => $Rows, -columns => $Columns);
};

sub RevisionNoteBox {
  my (%Params) = @_;
  my $Default  = $Params{-default}  || "";
  my $JSInsert = $Params{-jsinsert} || "";

  my $ExtraText = "";

  # Convert text string w/ control characters to JS literal

  if ($JSInsert) {
    $JSInsert =~ s/\n/\\n/g;
    $JSInsert =~ s/\r//g;
    $JSInsert =~ s/\'/\\\'/g;
    $JSInsert =~ s/\"/\\\'/g; # FIXME: See if there is a way to insert double quotes
                              #        Bad HTML/JS interaction, I think
    $ExtraText = "<a href=\"#RevisionNote\" onclick=\"InsertRevisionNote('$JSInsert');\">(Insert notes from previous version)</a>";
  }

  my $ElementTitle = &FormElementTitle(-helplink  => "revisionnote",
                                       -helptext  => "Notes and Changes",
                                       -extratext => $ExtraText,
                                       -required  => $Required );
  print $ElementTitle,"\n";
  print $query -> textarea (-name => 'revisionnote', -default => $Default,
                            -columns => 60, -rows => 6);
};


sub DocTypeButtons (%) {
  my (%Params) = @_;

  my $Required = $Params{-required} || 0;
  my $Default  = $Params{-default}  || 0;

  &GetDocTypes();
  &GetDocTypesSecurity();

  my $EmailUserID = (&FetchEmailUserIDFromRemoteUser());
  my @UsersGroupIDs = ();
  @UsersGroupIDs = (&FetchUserGroupIDs($EmailUserID));

  # my @DocTypeIDs = sort DocumentTypeByAlpha keys %DocumentTypes;
  my @DocTypeIDs= sort { $DocumentTypes{$a}{SHORT} cmp $DocumentTypes{$b}{SHORT} } keys %DocumentTypes;
  my %ShortTypes = ();
  my @Values = ();

  my @DocTypeSecIDs = keys %DocumentTypesSecurity;

  foreach my $DocTypeID (@DocTypeIDs) {
    my $FoundTypeID = 0;
    foreach my $DocTypeSecID (@DocTypeSecIDs) {
        if ($DocumentTypesSecurity{$DocTypeSecID}{$DocTypeID} == $DocTypeID) {
            $FoundTypeID = 1;
            foreach my $UsersGroup (@UsersGroupIDs) {
               if ($DocumentTypesSecurity{$DocTypeSecID}{GroupID} == $UsersGroup) {

                   if ($DocumentTypesSecurity{$DocTypeSecID}{IncludeType} == 1) {
                       $ShortTypes{$DocTypeID} = $DocumentTypes{$DocTypeID}{SHORT};
                       push (@Values, $DocTypeID);
                   }
               }
            }
        }
    }
    if ($FoundTypeID == 0) {
        $ShortTypes{$DocTypeID} = $DocumentTypes{$DocTypeID}{SHORT};
        push (@Values, $DocTypeID);
    }
  }

  my $ElementTitle = &FormElementTitle(-helplink  => "doctype" ,
                                       -helptext  => "Document type" ,
                                       -required  => $Required );
  print "<div class=\"LowPaddedTable\">\n";
  print $ElementTitle,"\n";
  print $query -> radio_group(-columns => 3,
                              -name    => "doctype",
		              -values => \@Values,
		              -labels => \%ShortTypes,
                              -default => $Default);
  print "</div>\n";
};


sub DocTypeText ($) {

  my ($Default) = @_;

  &GetDocTypes();
  my $ShortTypes = $DocumentTypes{$Default}{SHORT};

  my $ElementTitle = &FormElementTitle(-helplink  => "doctype" ,
                                       -helptext  => "Document type" ,
                                       -required  => $Required );
  print "<div class=\"LowPaddedTable\">\n";
  print $ElementTitle, " &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
  print $ShortTypes, "<input type=\"hidden\" name=\"doctype\" value=\"";
  print $Default, "\">\n";
  print "</div>\n";
};

sub PrintRevisionInfo {
  require "FormElements.pm";
  require "Security.pm";

  require "AuthorSQL.pm";
  require "SecuritySQL.pm";
  require "TopicSQL.pm";

  require "AuthorHTML.pm";
  require "DocumentHTML.pm";
  require "FileHTML.pm";
  require "SecurityHTML.pm";
  require "TopicHTML.pm";
  require "XRefHTML.pm";
  require "XRefSQL.pm";

  my ($DocRevID,%Params) = @_;

  my $HideButtons  = $Params{-hidebuttons}  || 0;
  my $HideVersions = $Params{-hideversions} || 0;

  FetchDocRevisionByID($DocRevID);

  my $DocumentID   = $DocRevisions{$DocRevID}{DOCID};
  my $Version      = $DocRevisions{$DocRevID}{VERSION};
  my @RevAuthorIDs = GetRevisionAuthors($DocRevID);
  #  my @RevAuthorGroupIDs = GetRevisionAuthorGroups($DocRevID);
  my @TopicIDs     = GetRevisionTopics( {-docrevid => $DocRevID} );
  my @GroupIDs     = GetRevisionSecurityGroups($DocRevID);
  my @ModifyIDs;
  if ($EnhancedSecurity) {
    @ModifyIDs     = GetRevisionModifyGroups($DocRevID);
  }

  print "<div id=\"RevisionInfo\">\n";

  ### Header info
  print "<div id=\"Header3Col\">\n";

  print "<div id=\"DocTitle\">\n";
   &PrintTitle($DocRevisions{$DocRevID}{Title});
   if ($UseSignoffs) {
     require "SignoffUtilities.pm";
     my ($ApprovalStatus,$Locked, $LastSigned) = &RevisionStatus($DocRevID);
     unless (($ApprovalStatus eq "Unmanaged") || ($ApprovalStatus eq "Ready")) {
       if ($ApprovalStatus eq "Signed") {
           print "<h5>(Signature: $ApprovalStatus";
       } else {
           print "<h5>(Signature: <b>$ApprovalStatus</b>";
       }
       if (!CanAdminister()) {
           print ")</h5>\n";
       } else {
           print ",   ";
       }

     } else {
       unless ($Public) {
          if (CanAdminister()) {
            print "<h5>(";
          }
       }
     }
     if (CanAdminister()) {
        my $QSstatus = $DocRevisions{$DocRevID}{QAcheck};
        if ($QSstatus == 1) {
            print "QA: Certified)</h5>\n";
        } else {
            print "QA: <b>Uncertified</b>)</h5>\n";
        }
     }

   } else {

       unless ($Public) {
           if (CanAdminister()) {
              print "<h5>(";

              my $QSstatus = $DocRevisions{$DocRevID}{QAcheck};
              if ($QSstatus == 1) {
                  print "QA: Certified)</h5>\n";
              } else {
                  print "QA: <b>Uncertified</b>)</h5>\n";
              }
          }
       }
   }
  print "</div>\n";  # DocTitle
  print "</div>\n";  # Header3Col

  ### Left Column
  print "<div id=\"LeftColumn3Col\">\n";

  print "<div id=\"BasicDocInfo\">\n";
  print "<dl>\n";
   &PrintDocNumber($DocRevID);
  if (!$Public) {
   &RequesterByID($Documents{$DocumentID}{Requester});
   &SubmitterByID($DocRevisions{$DocRevID}{Submitter});
   &PrintModTimes;
  }
  print "</dl>\n";
  print "</div>\n";  # BasicDocInfo

  if ($Public) {
      print "<div id=\"UpdateButtons\">\n";
      &LoginToPrivateSiteButton ($DocumentID, $Version);
      print "</div>\n";
  }

  &GetSecurityGroups;

  if (&CanAdminister() && !$HideButtons) {
      my $QAstate = $DocRevisions{$DocRevID}{QAcheck};
      print "<div id=\"UpdateButtons\">\n";
      &QAButton($DocumentID, $Version, $QAstate);
      if (&CanModify($DocumentID,$Version) && !$HideButtons) {
        &UpdateButton($DocumentID, $Version);
        &UpdateDBButton($DocumentID,$Version,$QAState);
        DisplayReviewButton($DocRevID);
      }
      &AddFilesButton($DocumentID,$Version);
      print "</div>\n";
  } elsif (&CanCertify() && !$HideButtons) {
      my $QAstate = $DocRevisions{$DocRevID}{QAcheck};
      print "<div id=\"UpdateButtons\">\n";
      &QAButton($DocumentID, $Version, $QAstate);
      if (&CanModify($DocumentID,$Version) && !$HideButtons) {
        &UpdateButton($DocumentID, $Version);
        &UpdateDBButton($DocumentID,$Version,$QAState);
        DisplayReviewButton($DocRevID);
        if ($Version) {
          &AddFilesButton($DocumentID,$Version);
        }
      }
      print "</div>\n";
  } else {
      if (&CanModify($DocumentID,$Version) && !$HideButtons) {
        print "<div id=\"UpdateButtons\">\n";
        &UpdateButton($DocumentID, $Version);
        &UpdateDBButton($DocumentID,$Version,$QAState);
        DisplayReviewButton($DocRevID);
        if ($Version) {
          &AddFilesButton($DocumentID,$Version);
        }
        print "</div>\n";
      }
  }

  unless ($Public || $HideButtons) {
    require "NotificationHTML.pm";
    if (!$ReadOnly) {
        print "<div id=\"UpdateButtons\">\n";
        &CloneDocumentButton($DocumentID, $Version);
        print "</div>\n";
    }
    &DocNotifySignup(-docid => $DocumentID);
  }

  unless ($Public || $HideButtons) {
    # Don't show 'View Related Document Tree' button if no related documents
    @Unvisited = FetchXRefs(-docrevid => $DocRevID);
    if (@Unvisited){
      print "<div id=\"UpdateButtons\">\n";
      &ViewTreeButton(-docid => $DocumentID, -version =>$Version);
      # &ViewTreeButton($DocumentID, $Version);
      print "</div>\n";
    }
  }

  print "</div>\n";  # LeftColumn3Col

  ### Main Column

  print "<div id=\"MainColumn3Col\">\n";

  ### Right column (wrapped around by middle column)
  print "<div id=\"RightColumn3Col\">\n";

  unless ($Public) {
      &SecurityListByID(@GroupIDs);
      &ModifyListByID(@ModifyIDs);
  }
  unless ($HideVersions) {
    &OtherVersionLinks($DocumentID,$Version);
  }

  print "</div>\n";  # RightColumn3Col

  PrintAbstract($DocRevisions{$DocRevID}{Abstract}); # All are called only here, so changes are OK
  FileListByRevID($DocRevID); # All are called only here, so changes are OK
  print TopicListByID( {-topicids => \@TopicIDs, -listelement => "long"} );

  my @RevAuthorGroupIDs = GetRevisionAuthorGroups($DocRevID);

  AuthorListByAuthorRevID({ -authorrevids => \@RevAuthorIDs, -authorgrouprevids => \@RevAuthorGroupIDs});
  PrintKeywords($DocRevisions{$DocRevID}{Keywords});
  PrintRevisionNote($DocRevisions{$DocRevID}{Note});
  PrintXRefInfo($DocRevID);
  PrintReferenceInfo($DocRevID);
  PrintEventInfo(-docrevid => $DocRevID, -format => "normal");
  PrintPubInfo($DocRevisions{$DocRevID}{PUBINFO});

  if ($UseSignoffs) {
    require "SignoffHTML.pm";
    PrintRevisionSignoffInfo($DocRevID);
  }

  # PrintXRefTree($DocRevID);

  print "</div>\n";  # MainColumn3Col

  print "<div id=\"Footer3Col\">\n"; # Must have to keep NavBar on true bottom
  print "</div>\n";  # Footer3Col
  print "</div>\n";  # RevisionInfo

}


sub DisplayReviewButton{
  require "SQLUtilities.pm";

  my ($DocRevID)  = @_;
  my $DocTime     = &EuroDateHM($Documents{$DocumentID}{Date});
  my $DocumentID  = $DocRevisions{$DocRevID}{DOCID};
  my $Version     = $DocRevisions{$DocRevID}{VERSION};
  my $DocTypeID   = $DocRevisions{$DocRevID}{DocTypeID};
  my $Abstract    = $DocRevisions{$DocRevID}{Abstract};
  my $ReviewState = $DocRevisions{$DocRevID}{ReviewState};

  my $DocTypeCheck = 0;
  my $ReviewDocCheck = 0;

  # First check if the document is the correct type
  foreach my $AcceptableDocType (@ReviewableDocTypes) {
      if ($DocTypeID == $AcceptableDocType) {
          $DocTypeCheck = 1;
      }
  }

  if ($DocTypeCheck) {
      if ($DocTypeID == $Presentation_DocType) {
          if ($Abstract ne "") {
              $ReviewDocCheck = 1;
          }
      }
      if ($DocTypeID == $Publication_DocType) {
          my @FileIDs  = &FetchDocFiles($DocRevID);
          if (@FileIDs) {
              $ReviewDocCheck = 1;
          }
      }
  }

  if ($ReviewDocCheck) {
      &ReviewButton($DocumentID, $Version, $ReviewState);
  }
}

sub DontPrintRevisionInfo($$) {
   my ($Mode,$documentID) = @_;
   my $lb = '';
   my $Version = $params{version};
   my $event = 'onClick="window.location=';
   if ($Mode eq "reserve" || $Version eq '0') {
      $lb = $event."'/".&FetchDocumentAlias($documentID)."-x0'\"";
   } elsif ($Version =~ /\d+/) {
      $lb = $event."'/".&FetchDocumentAlias($params{docid})."-v".$params{version}."'\"";
   } else {
      $lb = $event."'/".&FetchDocumentAlias($params{docid})."'\"";
   }
   my $ButtonMode = "Change Metadata";
   my $RightButton = "'/cgi-bin/private/DocDB/DocumentAddForm?mode=".$Mode.
                     "&docid=".$params{docid}."&version=".$Version."'";

   if ($Mode eq "reserve") {
      $ButtonMode = "Reserve Another Document";
      $RightButton = "'/cgi-bin/private/DocDB/DocumentAddForm?mode=".$Mode.
                     "&docid=0&version=0'";
   } elsif ($Mode eq "update") {
      $ButtonMode = "Upload Document/Add New Version";
      $RightButton = "'/cgi-bin/private/DocDB/DocumentAddForm?mode=".$Mode.
                     "&docid=".$params{docid}."&version=".$Version."'";
   } elsif ($Mode eq "use") {
      $ButtonMode = "Reserve Another Document";
      $RightButton = "'/cgi-bin/private/DocDB/DocumentAddForm?mode=".$Mode.
                     "&docid=0&version=0'";
   } elsif ($Mode eq "add") {
      $ButtonMode = "Add Files";
      $RightButton = "'/cgi-bin/private/DocDB/AddFilesForm?mode=".$Mode.
                     "&docid=".$params{docid}."&version=".$Version."'";
   }

   print "<div id=\"NotRevisionInfo\">\n";
   print "   <div id=\"pda2buttons\">\n";
   if ($Mode eq "reserve") {
      print "      <button class=pda2bl ".$lb.">Go To New Document</button>";
   } else {
      print "      <button class=pda2bl ".$lb.">View Document</button>";
   }
   print "      <button class=pda2br ".$event.$RightButton."\">";
   print "         Return To ".$ButtonMode;
   print "      </button>\n";
   print "   </div> <!-- pda2buttons -->\n";
   print "</div> <!-- RevisionInfo -->\n";
}

sub PrintAbstract ($;$) {
  my ($Abstract,$ArgRef) = @_;

  my $Format = exists $ArgRef->{-format} ? $ArgRef->{-format} : "div";

  if ($Abstract) {
    $Abstract = URLify(AddLineBreaks($Abstract));
    $Abstract = SanitizeLatexExpression($Abstract);
  } else {
    $Abstract = "None";
  }

  if ($Format eq "div") {
    print "<div id=\"Abstract\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Abstract:</span></dt>\n";
    print "<dd>$Abstract</dd>\n";
    print "</dl>\n";
    print "<small id='MathJaxInsert' class='MathJaxInsert'></small>\n";
    print "</div>\n";
  } elsif ($Format eq "bare") {
    print  $Abstract;
  }
}

sub PrintKeywords {
  my ($Keywords) = @_;

  require "KeywordHTML.pm";

  $Keywords =~ s/^\s+//;
  $Keywords =~ s/\s+$//;

  if ($Keywords) {
    print "<div id=\"Keywords\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Keywords:</span></dt>\n";
    print "<dd>\n";
    my @Keywords = split /\,*\s+/,$Keywords;
    my $Link;
    foreach my $Keyword (@Keywords) {
      $Link = &KeywordLink($Keyword);
      print "$Link \n";
    }
    print "</dd></dl>\n";
    print "</div>\n";
  }
}

sub PrintRevisionNote {
  require "Utilities.pm";

  my ($RevisionNote) = @_;
  if ($RevisionNote) {
    print "<div id=\"RevisionNote\">\n";
    $RevisionNote = URLify(AddLineBreaks($RevisionNote));
    $RevisionNote = SanitizeLatexExpression($RevisionNote);
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Notes and Changes:</span></dt>\n";
    print "<dd>$RevisionNote</dd>\n";
    print "</dl>\n";
    print "</div>\n";
  }
}

sub PrintReferenceInfo ($;$) {
  require "MiscSQL.pm";
  require "ReferenceLinks.pm";

  my ($DocRevID,$ReportMode) = @_;
  unless ($ReportMode) {$ReportMode = "long";}
  my @ReferenceIDs = &FetchReferencesByRevision($DocRevID);

  if (@ReferenceIDs) {
    &GetJournals;
    if ($ReportMode eq "long") {
      print "<div id=\"ReferenceInfo\">\n";
      print "<dl>\n";
      print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Journal References:</span></dt>\n";
    }
    foreach my $ReferenceID (@ReferenceIDs) {
      $JournalID = $RevisionReferences{$ReferenceID}{JournalID};
      if ($ReportMode eq "long") {
        print "<dd>Published in ";
      }
      my ($ReferenceLink,$ReferenceText) = &ReferenceLink($ReferenceID);
      if ($ReferenceLink) {
        print "<a href=\"$ReferenceLink\">";
      }
      if ($ReferenceText) {
        print "$ReferenceText";
      } else {
        print "$Journals{$JournalID}{Abbreviation} ";
        if ($RevisionReferences{$ReferenceID}{Volume}) {
          print " vol. $RevisionReferences{$ReferenceID}{Volume}";
        }
        if ($RevisionReferences{$ReferenceID}{Page}) {
          print " pg. $RevisionReferences{$ReferenceID}{Page}";
        }
      }
      if ($ReferenceLink) {
        print "</a>";
      }
      if ($ReportMode eq "long") {
        print ".</dd>\n";
      } elsif ($ReportMode eq "short") {
        print "<br/>\n";
      }
    }
    if ($ReportMode eq "long") {
      print "</dl>\n";
      print "</div>\n";
    }
  }
}

sub PrintEventInfo (%) {
  require "MeetingSQL.pm";
  require "MeetingHTML.pm";

  my %Params = @_;
  my $DocRevID = $Params{-docrevid};
  my $Format   = $Params{-format}   || "normal";

  my @EventIDs = GetRevisionEvents($DocRevID, -accessible_only=> 1);
  
  if (@EventIDs) {
    unless ($Format eq "short" || $Format eq "description") {
      print "<div id=\"EventInfo\">\n";
      print "<dl>\n";
      print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Associated with Events:</span></dt> \n";
    }
    foreach my $EventID (@EventIDs) {
      my $EventLink;
      if ($Format eq "description") {
        $EventLink = EventLink(-eventid => $EventID, -format => "long");
      } else {
        $EventLink = EventLink(-eventid => $EventID);
      }
      my $Start = EuroDate($Conferences{$EventID}{StartDate});
      my $End   = EuroDate($Conferences{$EventID}{EndDate});
      unless ($Format eq "short" || $Format eq "description") {
        print "<dd>";
      }
      print "$EventLink ";
      if ($Format eq "short" || $Format eq "description") {
        print "($Start)<br/>";
      } else {
        if ($Start && $End && ($Start ne $End)) {
          print " held from $Start to $End ";
        }
        if ($Start && $End && ($Start eq $End)) {
          print " held on $Start ";
        }
        if ($Conferences{$EventID}{Location}) {
          print " in $Conferences{$EventID}{Location}";
        }
        print "</dd>\n";
      }
     }
    unless ($Format eq "short" || $Format eq "description") {
      print "</dl></div>\n";
    }
  }
}

sub PrintPubInfo ($) {
  require "Utilities.pm";

  my ($pubinfo) = @_;
  if ($pubinfo) {
    print "<div id=\"PubInfo\">\n";
    $pubinfo = URLify(AddLineBreaks($pubinfo));
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Publication Information:</span></dt>\n";
    print "<dd>$pubinfo</dd>\n";
    print "</dl>\n";
    print "</div>\n";
  }
}

sub PrintModTimes {
  require "SQLUtilities.pm";

  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  $DocTime     = &EuroDateHM($Documents{$DocumentID}{Date});
  $RevTime     = &EuroDateHM($DocRevisions{$DocRevID}{DATE});
  $VersionTime = &EuroDateHM($DocRevisions{$DocRevID}{VersionDate});

  my $ActualDateTime = ConvertToDateTime({-MySQLTimeStamp => $DocRevisions{$DocRevID}{TimeStamp}, });
  my $ActualTime  = DateTimeString({ -DateTime => $ActualDateTime });

  print "<dt>Document Created:</dt>\n<dd>$DocTime</dd>\n";
  print "<dt>Contents Revised:</dt>\n<dd>$VersionTime</dd>\n";
  print "<dt>Metadata Revised:</dt>\n<dd>$RevTime</dd>\n";
  if ($ActualTime ne $RevTime) {
    print "<dt>Actually Revised:</dt>\n<dd>$ActualTime</dd>\n";
  }
}

sub OtherVersionLinks {
  require "Sorts.pm";

  my ($DocumentID,$CurrentVersion) = @_;
  my @RevIDs   = reverse sort RevisionByVersion &FetchRevisionsByDocument($DocumentID);

  unless ($#RevIDs > 0) {return;}
  print "<div id=\"OtherVersions\">\n";
  print "<b>Other Versions:</b>\n";

  print "<table id=\"OtherVersionTable\" class=\"Alternating LowPaddedTable\">\n";
  my $RowClass = "alt";

  foreach $RevID (@RevIDs) {
    my $Version = $DocRevisions{$RevID}{VERSION};
    if ($Version == $CurrentVersion) {next;}
    unless (&CanAccess($DocumentID,$Version)) {next;}
    $link = DocumentLink(-docid => $DocumentID, -version => $Version);
    $date = &EuroDateHM($DocRevisions{$RevID}{DATE});
    print "<tr class=\"$RowClass\"><td>$link\n";
    if ($RowClass eq "alt") {
      $RowClass = "Even";
    } else {
      $RowClass = "alt";
    }
    print "<br/>$date\n";
    if ($UseSignoffs) {
      require "SignoffUtilities.pm";
      my ($ApprovalStatus,$LastSigned) = &RevisionStatus($RevID);
      unless (($ApprovalStatus eq "Unmanaged") || ($ApprovalStatus eq "Ready")) {
        print "<br/>$ApprovalStatus";
      }
    }
    print "</td></tr>\n";
  }

  print "</table>\n";
  print "</div>\n";
}

1;
