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

sub MailNotices (%) {

  unless ($MailInstalled) {
    return;
  }  

  require "RevisionSQL.pm";
  require "NotificationSQL.pm";
  require "ResponseElements.pm";
  require "Utilities.pm";
  require "Security.pm";
  require "AuthorSQL.pm";
  
  my (%Params) = @_;

  my $DocRevID     =   $Params{-docrevid};
  my $Type         =   $Params{-type}      || "updateunknown";
  my @EmailUserIDs = @{$Params{-emailids}};
  my $ReadyForApproval = 0;
  
if ($myDEBUG) { print DEBUG "MailNotices $ReadyForApproval\n"; }

  FetchDocRevisionByID($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{Version};
  my $DocType    = $DocRevisions{$DocRevID}{DocTypeID};
  my $SubmitterID = $DocRevisions{$DocRevID}{Submitter};
 
# Figure out who cares 

  my @Addressees = ();
  if ($Type eq "update"  || $Type eq "updatedb" || $Type eq "add" || 
      $Type eq "reserve" || $Type eq "addfiles" || $Type eq "updateunknown") {
    @Addressees = UsersToNotify($DocRevID,{-period => "Immediate"} );
  } elsif ($Type eq "signature") {
      require "SignoffSQL.pm";
      my $NumOfResponses    = NumberOfResponders($DocRevID);
      my $NumOfPendingSigs  = NumberOfPendingSignatures($DocRevID);
      my $SizeOfSignoffList = SizeOfSignoffList($DocRevID);

      if ($myDEBUG) { print DEBUG "NumOfResponses: $NumOfResponses  NumOfPendingSigs: $NumOfPendingSigs\n"; }

      if (($NumOfPendingSigs == 1) && ($NumOfResponses == 0))  {
          $ReadyForApproval = 1;
      }
     
      if ( ($SizeOfSignoffList - $NumOfResponses) == 1){
          $ReadyForApproval = 1;
      }

      if ($myDEBUG) { print DEBUG "Ready for Approval $ReadyForApproval\n";}

      if ($ReadyForApproval) {
          if (CanAccess($DocumentID, $Version, $EmailUserID)) {
              if (isPendingSignature($DocRevID, $EmailUserID, 1)) {
                  FetchEmailUser($EmailUserID);
                  if ($myDEBUG) { print DEBUG "Pushing $EmailUserID\n"; }
                  push @Addressees,$EmailUser{$EmailUserID}{EmailAddress};
              }
           }
      }
      else {      
          foreach my $EmailUserID (@EmailUserIDs) { # Extract emails
              if (CanAccess($DocumentID, $Version, $EmailUserID)) {
                  if (isPendingSignature($DocRevID, $EmailUserID, 0)) {
                      FetchEmailUser($EmailUserID);
                      if ($myDEBUG) { print DEBUG "Pushing $EmailUserID\n"; }
                      push @Addressees,$EmailUser{$EmailUserID}{EmailAddress};
                  }
              }
          }
      }
  } elsif (($Type eq "approved") || ($Type eq "disapproved")) { 
    @Addressees = UsersToNotify($DocRevID,{-period => "Immediate"} );
    my %EmailUsers = ();
    my @SignoffIDs = GetAllSignoffsByDocRevID($DocRevID);
    foreach my $SignoffID (@SignoffIDs) {
      my @SignatureIDs = GetSignatures($SignoffID);
      foreach my $SignatureID (@SignatureIDs) {
        my $EmailUserID = $Signatures{$SignatureID}{EmailUserID};
        if (CanAccess($DocumentID, $Version, $EmailUserID)) {
            FetchEmailUser($EmailUserID);
            push @Addressees,$EmailUser{$EmailUserID}{EmailAddress};
        }
      }  
    }  

    # Send an email to all the Authors
    my @RevAuthorIDs = ();
    @RevAuthorIDs = GetAuthorList($DocRevID);
    
    foreach my $RevAuthorID (@RevAuthorIDs) {
        my $EmailUser = FetchEmailUserIDFromAuthorID($RevAuthorID);
        if (CanAccess($DocumentID, $Version, $EmailUser)) {
            FetchEmailUser($EmailUser);
            push @Addressees,$EmailUser{$EmailUser}{EmailAddress};
        }
    }

    # Send an email to all the updaters for this  VersionNumber
    my @UpdaterIDs = ();
    @UpdaterIDs = GetUpdaterListThisVersion($DocumentID, $Version);
    
    foreach my $UpdaterID (@UpdaterIDs ) {
        my $EmailUser = FetchEmailUserIDFromAuthorID($UpdaterID);
        if (CanAccess($DocumentID, $Version, $EmailUser)) {
            FetchEmailUser($EmailUser);
            push @Addressees,$EmailUser{$EmailUser}{EmailAddress};
        }
    }

    # Send an email to the submitter 
    FetchDocument($DocumentID);
    $SubmitterID = $Documents{$DocumentID}{Requester};
    my $EmailUser = FetchEmailUserIDFromAuthorID($SubmitterID);
    if (CanAccess($DocumentID, $Version, $EmailUser)) {
        FetchEmailUser($EmailUser);
        push @Addressees,$EmailUser{$EmailUser}{EmailAddress};
    }

  } 
  
  @Addressees = Unique(@Addressees);

  if (@Addressees) {

    my $FullID = FullDocumentID($DocRevisions{$DocRevID}{DOCID},$DocRevisions{$DocRevID}{VERSION});
    my $Title  = $DocRevisions{$DocRevID}{Title};

    my ($Subject,$Message,$Feedback);
    
    if ($Type eq "update"  || $Type eq "updatedb" || $Type eq "add" || 
        $Type eq "reserve" || $Type eq "addfiles" || $Type eq "updateunknown") {
      $Subject  = "$FullID: $Title";
      $Message  = "The following document was added or updated ".
                  "in the $Project Document Database:\n\n";
      $Feedback = "<b>E-mail sent to: </b>";        
      if      ($Type eq "update") {
        $Message  = "The following document was updated ".
                    "in the $Project Document Database:\n\n";
      } elsif ($Type eq "updatedb") {
        $Message  = "The meta-information for the following document was updated ".
             "in the $Project Document Database:\n\n";
      } elsif ($Type eq "add") {
        $Message  = "The following document was added ".
             "to the $Project Document Database:\n\n";
      } elsif ($Type eq "reserve") {
        $Message  = "The following document was reserved ".
             "in the $Project Document Database:\n\n";
      } elsif ($Type eq "addfiles") {
        $Message  = "Files were added to the following document ".
             "in the $Project Document Database:\n\n";
      }  
    } elsif ($Type eq "signature") {
      if ($myDEBUG) { print DEBUG "signature - Ready for Approval $ReadyForApproval\n";}
      if ($ReadyForApproval) {
          $Subject  = "Ready for approval: $FullID: $Title";
      }
      else {
          $Subject  = "Ready for signature: $FullID: $Title";
      }
      $Message  = "The following document ".
                  "in the $Project Document Database ".
                  "is ready for your signature:\n\n";
      $Feedback = "<b>Signature(s) requested from: </b>";           
    } elsif ($Type eq "approved") {
      $Subject  = "Approved $FullID: $Title";
      $Message  = "The following document ".
                  "in the $Project Document Database ".
                  "has been approved (received all necessary signatures).\n\n";
      $Feedback = "<b>Approval notification sent to: </b>";           
    } elsif ($Type eq "signed") {
      $Subject  = "Signed $FullID: $Title";
      $Message  = "The following document ".
                  "in the $Project Document Database ".
                  "has been signed.\n\n";
      $Feedback = "<b>Approval notification sent to: </b>";           
    } elsif ($Type eq "disapproved"){
      $Subject  = "Disapproved $FullID: $Title";
      $Message  = "The following document ".
                  "in the $Project Document Database ".
                  "has received a disapproval.\n\n";
      $Feedback = "<b>Signature(s) requested from: </b>";           
    }  

    my $Body = &RevisionMailBody($DocRevID);

    debug_file_out(-message => "RevisionMailBody output for DocRevID $DocRevID :\n--\n$Body\n--");

    send_email( "$Project Document Database <$DBWebMasterEmail>",
                (join ', ',@Addressees),
                $Subject,
                $Message."\n".$Body);

    my $Addressees = join ', ',@Addressees;
    $Addressees =~ s/\&/\&amp\;/g;
    $Addressees =~ s/</\&lt\;/g;
    $Addressees =~ s/>/\&gt\;/g;
    
    print $Feedback,$Addressees,"<p>";
  }  
}

sub RevisionMailBody ($) {
  my ($DocRevID) = @_;

  require "ResponseElements.pm";
  require "AuthorSQL.pm";
  require "AuthorUtilities.pm";
  require "MeetingSQL.pm";
  require "RevisionSQL.pm";
  require "TopicSQL.pm";
  require "Sorts.pm";

  FetchDocRevisionByID($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{VERSION};

  FetchDocument($DocumentID);
  my $NumVersions = $Documents{$DocumentID}{NVersions};

  
  my $Title  = $DocRevisions{$DocRevID}{Title};
  my $FullID = FullDocumentID($DocRevisions{$DocRevID}{DOCID},$DocRevisions{$DocRevID}{VERSION});
 
  my $URL    = DocumentURL($DocumentID);

  if ($Version != $NumVersions) {
     $URL = DocumentURL($DocumentID, $Version);
  }
  
  FetchAuthor($DocRevisions{$DocRevID}{Submitter});
  my $Submitter = $Authors{$DocRevisions{$DocRevID}{Submitter}}{FULLNAME};

  my @AuthorRevIDs = GetRevisionAuthors($DocRevID);
     @AuthorRevIDs = sort AuthorRevIDsByOrder @AuthorRevIDs;
  my @AuthorIDs    = AuthorRevIDsToAuthorIDs({ -authorrevids => \@AuthorRevIDs, });
  my @TopicIDs     = GetRevisionTopics({-docrevid => $DocRevID});
  my @EventIDs     = GetRevisionEvents($DocRevID);
  
# Build list of authors  
  
  my @Authors = ();
  foreach $AuthorID (@AuthorIDs) {
    FetchAuthor($AuthorID);
  }
  @AuthorIDs = sort byLastName @AuthorIDs;
  foreach $AuthorID (@AuthorIDs) {
    push @Authors,$Authors{$AuthorID}{FULLNAME};
  }
  my $Authors = join ', ',@Authors;
  
# Build list of topics
  
  my @Topics = ();
  foreach $TopicID (@TopicIDs) {
    FetchTopic({-topicid => $TopicID});
  }
  @TopicIDs = sort TopicByAlpha @TopicIDs;
  foreach $TopicID (@TopicIDs) {
    push @Topics,$Topics{$TopicID}{Long};
  }
  my $Topics = join ', ',@Topics;
  
# Build list of events  
  
  my @Events = ();
  foreach $EventID (@EventIDs) {
    FetchConferenceByConferenceID($EventID);
  }
  @EventIDs = sort EventsByDate @EventIDs;
  foreach $EventID (@EventIDs) {
    push @Events,$Conferences{$EventID}{Title}.
         " (".EuroDate($Conferences{$EventID}{StartDate}).")";
  }
  my $Events = join ', ',@Events;
   
  # Construct the mail body
  
  my $Body = "       Title: ".$DocRevisions{$DocRevID}{Title}."\n".
             " Document ID: ".$FullID."\n".
             "         URL: ".$URL."\n".
             "        Date: ".$DocRevisions{$DocRevID}{DATE}."\n".
             "Submitted by: ".$Submitter."\n".
             "     Authors: ".$Authors."\n".
             "      Topics: ".$Topics."\n";
  if ($Events) {
     $Body = $Body."      Events: ".$Events."\n";
  } 
     $Body = $Body."    Keywords: ".$DocRevisions{$DocRevID}{Keywords}."\n".
                   "    Abstract: ".$DocRevisions{$DocRevID}{Abstract}."\n";
  if ($DocRevisions{$DocRevID}{Note}) {
     $Body = $Body."       Notes: ".$DocRevisions{$DocRevID}{Note}."\n";
  }
  return $Body;  
}

sub UsersToNotify ($$) {
  my ($DocRevID,$ArgRef) = @_;
  my $Period = exists $ArgRef->{-period} ? $ArgRef->{-period} : "Immediate";

  require "AuthorSQL.pm";
  require "MeetingSQL.pm";
  require "NotificationSQL.pm";
  require "TopicSQL.pm";
  
  require "Security.pm";
  require "Utilities.pm";
  require "AuthorUtilities.pm";

  unless ($Period eq "Immediate" || $Period eq "Daily" || $Period eq "Weekly") {
    return undef;
  }  

  &FetchDocRevisionByID($DocRevID);
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{Version};
  my $DocTypeID  = $DocRevisions{$DocRevID}{DocTypeID};

  my $UserID;
  my %UserIDs    = (); # Hash to make user IDs unique (one notification per person)
  my @Addressees = ();

  my $Fetch     = $dbh -> prepare(
    "select EmailUserID from Notification where Period=? and Type=? and ForeignID=?");
  my $TextFetch = $dbh -> prepare(
    "select EmailUserID from Notification where Period=? and Type=? and TextKey=?");

# Get users interested in this particular document (only immediate)
 
  if ($Period eq "Immediate") {
    $Fetch -> execute("Immediate","Document",$DocumentID);
    $Fetch -> bind_columns(undef,\($UserID));
    while ($Fetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }
  }

# Get users interested in all documents for this reporting period
# FIXME: 2nd set can go away in version 9 after all values are reset

  $Fetch -> execute($Period,"AllDocuments",1);
  $Fetch -> bind_columns(undef,\($UserID));
  while ($Fetch -> fetch) {
    $UserIDs{$UserID} = 1; 
  }
  $Fetch -> execute($Period,"AllDocuments",0);
  $Fetch -> bind_columns(undef,\($UserID));
  while ($Fetch -> fetch) {
    $UserIDs{$UserID} = 1; 
  }

# Get users interested in this DocType this reporting period
  if ($Period eq "Immediate") {
    $Fetch -> execute("Immediate", "DocType", $DocTypeID);
    $Fetch -> bind_columns(undef,\($UserID));
    while ($Fetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }
  }

# Get users interested in topics for this reporting period

  GetTopics();
  my @TopicIDs = ();
  my @InitialTopicIDs = GetRevisionTopics( {-docrevid => $DocRevID} );
  
  foreach my $TopicID (@InitialTopicIDs) {
    push @TopicIDs,@{$TopicProvenance{$TopicID}}; # Add ancestors to list
  }
  @TopicIDs = Unique(@TopicIDs);
  foreach my $TopicID (@TopicIDs) {
    $Fetch -> execute($Period,"Topic",$TopicID);
    $Fetch -> bind_columns(undef,\($UserID));
    while ($Fetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }
  }  
    
# Get users interested in events for this reporting period

  my @EventIDs = GetRevisionEvents($DocRevID);
  foreach my $EventID (@EventIDs) {
    FetchConferenceByConferenceID($EventID);
    $Fetch -> execute($Period,"Event",$EventID);
    $Fetch -> bind_columns(undef,\($UserID));
    while ($Fetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }

    my $EventGroupID = $Conferences{$EventID}{EventGroupID};
    
    $Fetch -> execute($Period,"EventGroup",$EventGroupID);
    $Fetch -> bind_columns(undef,\($UserID));
    while ($Fetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }
  }  

# Get users interested in authors for this reporting period

  my @AuthorRevIDs = GetRevisionAuthors($DocRevID);
  my @AuthorIDs    = AuthorRevIDsToAuthorIDs({ -authorrevids => \@AuthorRevIDs, });
  foreach my $AuthorID (@AuthorIDs) {
    $Fetch -> execute($Period,"Author",$AuthorID);
    $Fetch -> bind_columns(undef,\($UserID));
    while ($Fetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }
  }  

# Get users interested in keywords for this reporting period
    
  FetchDocRevisionByID($DocRevID);
  my @Keywords = split /,*\s+/,$DocRevisions{$DocRevID}{Keywords}; # Comma and/or space separated

  foreach my $Keyword (@Keywords) {
    $Keyword =~ tr/[A-Z]/[a-z]/;
    $TextFetch -> execute($Period,"Keyword",$Keyword);
    $TextFetch -> bind_columns(undef,\($UserID));
    while ($TextFetch -> fetch) {
      $UserIDs{$UserID} = 1; 
    }
  }  

# verify user is allowed to receive notification
  
  foreach $UserID (keys %UserIDs) {
    if (CanAccess($DocumentID,$Version,$UserID)) {
      &FetchEmailUser($UserID);  
      my $Name         = $EmailUser{$UserID}{Name}; 
      my $EmailAddress = $EmailUser{$UserID}{EmailAddress};
      if ($EmailAddress) {
        push @Addressees,$EmailAddress;
      }
    }
    else {
       debug_file_out(-message => "$UserID CANNOT ACCESS $DocumentID $Version");
    }
  } 
  
  return @Addressees;
}

sub EmailKeywordForm ($) {
  my ($ArgRef) = @_;
  my $Name     = exists $ArgRef->{-name}    ?   $ArgRef->{-name}     : "";
  my $Period   = exists $ArgRef->{-period}  ?   $ArgRef->{-period}   : "";
  my @Defaults = exists $ArgRef->{-default} ? @{$ArgRef->{-default}} : ();

  require "FormElements.pm";

  print FormElementTitle(-helplink  => "notifykeyword", -helptext => $Period, 
                         -extratext => "(separate with spaces)");

  my $Keywords = join ' ',sort @Defaults;

  print $query -> textfield (-name => $Name , -default   => $Keywords, 
                             -size => 80,     -maxlength => 400);
}

sub EmailAllForm ($) {
  my ($ArgRef) = @_;
  my $Name     = exists $ArgRef->{-name}    ?   $ArgRef->{-name}     : "";
  my @Defaults = exists $ArgRef->{-default} ? @{$ArgRef->{-default}} : ();

  if (@Defaults) {
    print $query -> checkbox(-name => $Name, -checked => 'checked', -value => 1, -label => 'All Documents');
  } else {
    print $query -> checkbox(-name => $Name, -value => 1, -label => 'All Documents');
  }                             
}

sub DisplayNotification ($$;$) {
  my ($EmailUserID,$Set,$Always) = @_;

  require "NotificationSQL.pm";
  require "AuthorHTML.pm";
  require "KeywordHTML.pm";
  require "MeetingHTML.pm";
  require "TopicHTML.pm";
  require "TopicHTML.pm";

  FetchNotifications( {-emailuserid => $EmailUserID} );

  my @DocTypeIDs    = @{$Notifications{$EmailUserID}{"DocType_".$Set}};
  my @AuthorIDs     = @{$Notifications{$EmailUserID}{"Author_".$Set}};
  my @TopicIDs      = @{$Notifications{$EmailUserID}{"Topic_".$Set}};
  my @EventIDs      = @{$Notifications{$EmailUserID}{"Event_".$Set}};
  my @EventGroupIDs = @{$Notifications{$EmailUserID}{"EventGroup_".$Set}};
  my @Keywords      = @{$Notifications{$EmailUserID}{"Keyword_".$Set}};
  my @AllDocuments  = @{$Notifications{$EmailUserID}{"AllDocuments_".$Set}};
  
  my $NewNotify = (@AllDocuments || @AuthorIDs || @TopicIDs || @EventIDs || @EventGroupIDs || @Keywords || @DocTypeIDs);
                    
  if ($NotifyAllTopics || $NewNotify) {
    print "<b>$Set notifications:</b>\n";  
    print "<ul>\n";  
  } elsif ($Always) {
    print "<b>$Set notifications:</b>\n";  
    print "<ul>\n";  
    print "<li>None</li>\n";  
    print "</ul>\n";
    return;
  } else {
    return;
  }
  
  if (@AllDocuments) { 
    print "<li>All documents</li>\n";  
  }  
  
  foreach my $DocTypeID (@DocTypeIDs) {
    print "<li>Document Type: ",DocTypeLink($DocTypeID, "short"),"</li>";
  }
    
  foreach my $TopicID (@TopicIDs) {
    print "<li>Topic: ",TopicLink({ -topicid => $TopicID }),"</li>";
  }
    
  foreach my $AuthorID (@AuthorIDs) {
    print "<li> Author: ",AuthorLink($AuthorID),"</li>";
  }
    
  foreach my $EventID (@EventIDs) {
    print "<li>Event: ",EventLink(-eventid => $EventID),"</li>";
  }
    
  foreach my $EventGroupID (@EventGroupIDs) {
    print "<li>Event Group: ",EventGroupLink(-eventgroupid => $EventGroupID),"</li>";
  }

  foreach my $Keyword (@Keywords) {
    print "<li>Keyword: ",KeywordLink($Keyword),"</li>";
  }
     
  print "</ul>\n";  
}

sub EmailUserSelect (%) {
  require "Sorts.pm";
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  my @Defaults = @{$Params{-default}}; 

  my %Options = ();
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  
  
  my @EmailUserIDs = &GetEmailUserIDs;
  foreach my $EmailUserID (@EmailUserIDs) {
    &FetchEmailUser($EmailUserID);  
    $EmailUserLabels{$EmailUserID} = $EmailUser{$EmailUserID}{Username};
  }  
  
  @EmailUserIDs = sort EmailUserIDsByName @EmailUserIDs;
  
  print FormElementTitle(-helplink => "emailuser", -helptext => "Username"); 
  print $query -> scrolling_list(-name   => 'emailuserid', 
                                 -values => \@EmailUserIDs, 
                                 -labels => \%EmailUserLabels, 
                                 -size   => 10, -default => \@Defaults, 
                                 %Options);

}
  
1;
