#
#        Name: $RCSfile: SignoffUtilities.pm,v $
# Description: Utility routines related to signoffs
#
#    Revision: $Revision: 1.13.2.4 $
#    Modified: $Author: vondo $ on $Date: 2007/09/20 19:53:14 $

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
#

$myDEBUG = 0;

$Unapproved_RevisionStatus = "Unapproved";
$Pending_RevisionStatus = "Pending";
$Approved_RevisionStatus = "Approved";


sub SignoffStatus ($) {
  require "SignoffSQL.pm";

  my ($SignoffID) = @_;

  # Check to see if there is already a signature for this signoff
  FetchSignoff($SignoffID);

  my $DocRevID = $Signoffs{$SignoffID}{DocRevID};

  my $isParallelSignoff = $DocRevisions{$DocRevID}{ParallelSignoff};
  
  if ($isParallelSignoff) {
      return SignoffStatus_Parallel($SignoffID);
  } else {
      return SignoffStatus_Serial($SignoffID);
  }

}



sub SignoffStatus_Serial ($) {

  my ($SignoffID) = @_;

  my $Status = "Ready";

  # Check to see if there is already a signature for this signoff
  my $DocRevID = $Signoffs{$SignoffID}{DocRevID};
  my $LastSignoffID = GetLastSignoffIDByDocRevID ($DocRevID);


  if ($myDEBUG) { print DEBUG "SignoffStatus_Serial $SignoffID\n"; }
  my @SignatureIDs = &GetSignatures($SignoffID);
  foreach my $SignatureID (@SignatureIDs) {  # Loop over signatures
    &FetchSignature($SignatureID);
    if ($Signatures{$SignatureID}{Signed}) { # See if signed

      if ($Signatures{$SignatureID}{Signed} == $SignoffDBValues{disapprove}) { 
         $Status = "Disapproved";
         # Send emails to everyone notifying that there was a disapproval.
      }
      else {
         $Status = "Signed";
      }
      return $Status;
    }
    else {
      if ($SignoffID == $LastSignoffID) {
         $Status = "Ready";
         return $Status;
      }
    }
  }


  # Now check to see if all prerequisites are signed?

  my @PreSignoffIDs = &GetPreSignoffs($SignoffID);
  foreach my $PreSignoffID (@PreSignoffIDs) { # Loop over PreSignoffs
    if (!$PreSignoffID) { # Is zero for root signatures
      $SignedOff = 1;
    } else {
      $SignedOff = 0;
      my @SignatureIDs = &GetSignatures($PreSignoffID);
      foreach my $SignatureID (@SignatureIDs) {  # Loop over signatures
        &FetchSignature($SignatureID);
        if ($Signatures{$SignatureID}{Signed}) { # See if signed
          $SignedOff = 1;
        }
      }
    }
    unless ($SignedOff) { # All signatures of signoff unsigned
      $Status = "NotReady";
      return $Status;
    }
  }

  return $Status;

}


sub SignoffStatus_Parallel ($) {

  my ($SignoffID) = @_;

  my $Status = "Ready";
  if ($myDEBUG) { print DEBUG "SignoffStatus_Parallel\n"; }

  # Check to see if there is already a signature for this signoff
  FetchSignoff($SignoffID);

  my @SignatureIDs = &GetSignatures($SignoffID);
  foreach my $SignatureID (@SignatureIDs) {  # Loop over signatures
    &FetchSignature($SignatureID);
    if ($Signatures{$SignatureID}{Signed}) { # See if signed

      if ($Signatures{$SignatureID}{Signed} == $SignoffDBValues{disapprove}) { 
         $Status = "Disapproved";
      }
      else {
         $Status = "Signed";
      }
      return $Status;
    }
    else {
      $Status = "Ready";
      return $Status;
    }
  }

  return $Status;
}



sub RecurseSignoffStatus ($) {
  require "SignoffSQL.pm";

  my ($SignoffID) = @_;

  my $Status = $Approved_RevisionStatus;

  my $SignoffStatus = &SignoffStatus($SignoffID);

  if ($SignoffStatus eq "Signed") { # Check status of this signoff

# Find signoffs that depend on this, if any

    my @SubSignoffIDs = &GetSubSignoffs($SignoffID);
    foreach my $SubSignoffID (@SubSignoffIDs) { # Check these
      my $SignoffStatus =  &RecurseSignoffStatus($SubSignoffID);
      unless ($SignoffStatus eq $Approved_RevisionStatus) {
        $Status = $Pending_RevisionStatus;
        last;
      }
    }
  } else {
    $Status = $Pending_RevisionStatus;
  }

  return $Status;
}



sub FindLastApprovedDocRevID($) {

  my ($DocRevID) = @_;
  my $LastDocRevID =0;

  # Find last approved version
  if ($Status  eq $Approved_RevisionStatus) {
      $LastDocRevID = $DocRevID;
  } elsif ($Status eq $Pending_RevisionStatus) {

      my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
      my @DocRevIDs   = reverse sort RevisionByVersion &FetchRevisionsByDocument($DocumentID);

      foreach my $CheckRevID (@DocRevIDs) {
          &FetchDocRevisionByID($CheckRevID);

          my $Status =  $Approved_RevisionStatus;
          my $SignoffID = GetLastSignoffIDByDocRevID ($CheckRevID);
          
          if ($SignoffID) {
              $Status = SignoffStatus($SignoffID);
          } else {
              $Status = "Unmanaged";
          }
          
          if ($Status eq $Approved_RevisionStatus || $Status eq "Signed") {
              $LastDocRevID = $CheckRevID;
              last;
          }          
      }
  }

  return $LastDocRevID;

}



sub RevisionStatus_Parallel ($) {

     my ($DocRevID) = @_;
    
     $Locked       = 0;
     $LastDocRevID = undef;
     # First check if the last signer has approved the document
     my $LastSignoffID = GetLastSignoffIDByDocRevID ($DocRevID);

     FetchSignoff($LastSignoffID);
     $Status = SignoffStatus_Parallel($LastSignoffID);

     if ($myDEBUG) { print DEBUG "RevisionStatus_Parallel: DocRevID: $DocRevID LastSignoffID($LastSignoffID) Status($Status)\n"; }

     my @SignatureIDs = &GetSignatures($LastSignoffID);
     foreach my $SignatureID (@SignatureIDs) {  # Loop over signatures
        &FetchSignature($SignatureID);
         if ($Signatures{$SignatureID}{Signed} == $SignoffDBValues{approve}) { # See if approved

            if ($myDEBUG) {print DEBUG "RevisionStatus_Parallel: DocRevID: $DocRevID SignatureID($SignatureID) \n"; }

            $Status = $Approved_RevisionStatus;
            $Locked = 1;

            if ($myDEBUG) { print DEBUG "RevisionStatus_Parallel: DocRevID: $DocRevID Final Approval - approved \n"; }
            return ($Status, $Locked, $DocRevID); 
         } elsif ($Signatures{$SignatureID}{Signed} == $SignoffDBValues{disapprove}) { # See if disapproved
            if ($myDEBUG) {print DEBUG "RevisionStatus_Parallel: DocRevID: $DocRevID SignatureID($SignatureID) \n"; }

            $Status = $Unapproved_RevisionStatus;
            $Locked = 1;

            if ($myDEBUG) { print DEBUG "RevisionStatus_Parallel: DocRevID: $DocRevID Final Approval - disapproved \n"; }
            return ($Status, $Locked, $DocRevID); 
         } else {
            if ($myDEBUG) { print DEBUG "RevisionStatus_Parallel: DocRevID: $DocRevID Final Approval - fall through\n"; }
            $Status = $Pending_RevisionStatus;
         }
     }
 
     if ($myDEBUG) { print DEBUG "before calling FindLastApprovedDocRevID $DocRevID, $Status\n"; }
     $CheckDocRevID = FindLastApprovedDocRevID ($DocRevID);
     if ($CheckDocRevID) {
         $LastDocRevID = $CheckDocRevID;
     } 
      
     return ($Status, $Locked, $LastDocRevID);

} #RevisionStatus_Parallel 



sub RevisionStatus_Serial ($) {

     my ($DocRevID) = @_;

     $Locked       = 0;
     $LastDocRevID = undef;
     if ($myDEBUG) { print DEBUG "Entering RevisionStatus_Serial $Status, $Locked, $LastDocRevID\n"; }

     # First check if the last signer has approved the document
     my $LastSignoffID = GetLastSignoffIDByDocRevID ($DocRevID);

     FetchSignoff($LastSignoffID);
     $Status = SignoffStatus_Serial($LastSignoffID);

     my @SignatureIDs = &GetSignatures($LastSignoffID);
     foreach my $SignatureID (@SignatureIDs) {  # Loop over signatures
         &FetchSignature($SignatureID);
         if ($Signatures{$SignatureID}{Signed} == $SignoffDBValues{approve}) { # See if approved

            $Status = $Approved_RevisionStatus;
            $Locked = 1;
            if ($myDEBUG) { print DEBUG "RevisionStatus_Serial returning: Approved, Locked, DocRevID\n"; }
            return ($Status, $Locked, $DocRevID); 

         } elsif ($Signatures{$SignatureID}{Signed} == $SignoffDBValues{disapprove}) { # See if disapproved
            $Status = $Unapproved_RevisionStatus;
            $Locked = 1;
            if ($myDEBUG) { print DEBUG "RevisionStatus_Serial returning: Unapproved, Locked, DocRevID\n"; }
            return ($Status, $Locked, $DocRevID); 

         } else {
            $Status = $Pending_RevisionStatus;
         }
     }


     my @RootSignoffIDs = &GetRootSignoffs($DocRevID);
     if (@RootSignoffIDs) {
        foreach my $SignoffID (@RootSignoffIDs) {
           my $SignoffStatus = &RecurseSignoffStatus($SignoffID);
           if ($SignoffStatus eq $Pending_RevisionStatus) {
              $Status = $Pending_RevisionStatus;
              last;
           }
         }
      } else {
         $Status = "Unmanaged";
      }

      if ($DocRevisions{$DocRevID}{Demanaged}) {
         $Status = "Demanaged";
       }

      if ($myDEBUG) { print DEBUG "before calling FindLastApprovedDocRevID $DocRevID, $Status\n"; }
      $CheckDocRevID = FindLastApprovedDocRevID ($DocRevID);
      if ($CheckDocRevID) {
          $LastDocRevID = $CheckDocRevID;
      } 


      return ($Status,$Locked,$LastDocRevID);

} #RevisionStatus_Serial_


sub RevisionStatus ($) { # Return the approval status of a revision
                         # and the last approved version (if exists)
                         # Status can be approved, unapproved, unmanaged, demanaged
    require "SignoffSQL.pm";
    require "RevisionSQL.pm";
    require "Sorts.pm";

    my ($DocRevID) = @_;
    &FetchDocRevisionByID($DocRevID);

    my $Status       = "Unmanaged";
    my $Locked       = 0;
    my $LastDocRevID = undef;

    if ($myDEBUG) {open (DEBUG, ">>/tmp/debug.mca");}

    my $ParallelSignoff = $DocRevisions{$DocRevID}{ParallelSignoff};

    if ($myDEBUG) { print DEBUG "Entered RevisionStatus: DocRevID $DocRevID ParallelStatus : $ParallelSignoff\n"; }


    if ($ParallelSignoff) {
       if ($myDEBUG) { print DEBUG "ParallelSignoff\n"; }
       ($Status, $Locked, $LastDocRevID) = RevisionStatus_Parallel($DocRevID);
    }
    else {
       if ($myDEBUG) { print DEBUG "SerialSignoff\n"; }
       ($Status, $Locked, $LastDocRevID) = RevisionStatus_Serial($DocRevID);
    }  


    if ($myDEBUG) { print DEBUG "returning RevisionStatus: DocRevID $DocRevID Status: $Status Locked $Locked LastDocRevID: $LastDocRevID\n"; }

    return ($Status, $Locked, $LastDocRevID);
}



sub BuildSignoffDefault ($$) {
  require "SignoffSQL.pm";
  require "NotificationSQL.pm";

  my ($DocRevID, $ActiveOnly) = @_;
  my $ParallelSignoff = $DocRevisions{$DocRevID}{ParallelSignoff};

  my @EmailUserIDs = ();

  if ($ParallelSignoff) {
     my @SignoffList = GetOrderedSignoffsByDocRevID($DocRevID);
     foreach my $SignoffID (@SignoffList) {
       my ($SignatureID) = &GetSignatures($SignoffID);
       &FetchSignature($SignatureID);
       push @EmailUserIDs,$Signatures{$SignatureID}{EmailUserID};
     }
  }
  else {
     my ($SignoffID) = &GetRootSignoffs($DocRevID);

     while ($SignoffID) {
       my ($SignatureID) = &GetSignatures($SignoffID);
       &FetchSignature($SignatureID);
       push @EmailUserIDs,$Signatures{$SignatureID}{EmailUserID};
       my ($NewSignoffID) = &GetSubSignoffs($SignoffID);
       $SignoffID = $NewSignoffID;
     }
  }

  my $Default = "";

  foreach my $EmailUserID (@EmailUserIDs) {
    &FetchEmailUser($EmailUserID);
    if ($ActiveOnly) {
        my @UserGroupIDs = FetchUserGroupIDs($EmailUserID);
        if (@UserGroupIDs) {
           $Default .= $EmailUser{$EmailUserID}{Name} . "\n";
        }
    }
    else {
        $Default .= $EmailUser{$EmailUserID}{Name} . "\n";
    }
  }

  return $Default;
}

sub UnsignRevision { # Remove all signatures from a revision
                     # (Called when files are added to a revision)
  require "SignoffSQL.pm";

  my ($DocRevID) = @_;

  my $SignatureUpdate = $dbh -> prepare("update Signature set Signed=0 where SignatureID=?");

  my @SignoffIDs = &GetAllSignoffsByDocRevID($DocRevID);

  foreach my $SignoffID (@SignoffIDs) {
    my @SignatureIDs = &GetSignatures($SignoffID);
    foreach my $SignatureID (@SignatureIDs) {
      $SignatureUpdate -> execute($SignatureID);
    }
  }

  my $Status = "";
  if (@SignoffIDs) {
    $Status = "Unsigned";
  } else {
    $Status = "NoAction";
  }

  return $Status;
}

sub NotifySignatureSignees ($$) {
   unless ($UseSignoffs) { return; }

   my ($DocRevID, $SignatureStatus) = @_;

   require "SignoffSQL.pm";
   require "MailNotification.pm";

   if ($SignatureStatus == $SignoffDBValues{disapprove}) {

       my @EmailUserIDs = &ReadySignatories($DocRevID);

       &MailNotices(-docrevid => $DocRevID, -type => "disapproved");
   }
   else {
       NotifySignees($DocRevID);
   }

}


sub NotifySignees ($) {

   unless ($UseSignoffs) { return; }

  require "SignoffSQL.pm";
  require "MailNotification.pm";

  my ($DocRevID) = @_;

  my ($Status)     = &RevisionStatus($DocRevID);
  my @EmailUserIDs = &ReadySignatories($DocRevID);

  if (@EmailUserIDs) {
    
    &MailNotices(-docrevid => $DocRevID, -type => "signature",
                 -emailids => \@EmailUserIDs);
  }

  if ($Status eq $Approved_RevisionStatus) {
    &MailNotices(-docrevid => $DocRevID, -type => "approved");
  }
  if ($Status eq "Signed") {
    &MailNotices(-docrevid => $DocRevID, -type => "signed");
  }

  if ($Status ne "Unmanaged") {
    print "<b>Approval status: $Status</b><br>\n";
  }
}

sub ReadySignatories ($) {
  require "SignoffSQL.pm";

  my ($DocRevID) = @_;

  my @SignoffIDs   = &GetAllSignoffsByDocRevID($DocRevID);
  my @EmailUserIDs = ();
  foreach my $SignoffID (@SignoffIDs) {
    if (&SignoffStatus($SignoffID) eq "Ready") {
      my @SignatureIDs = &GetSignatures($SignoffID);
      foreach my $SignatureID (@SignatureIDs) {
        push @EmailUserIDs,$Signatures{$SignatureID}{EmailUserID};
      }
    }
  }
  return @EmailUserIDs;
}

#
# This is where the OLD DocRevID signature data should be fetched
# and then used to populate the new revision to preserve the
# signoff info.
#
sub CopyRevisionSignoffs { # CopySignoffs from one revision to another
                           # One mode to copy with signed Signatures,
                           # one without

  my ($OldDocRevID,$NewDocRevID,$CopySignatures) = @_;
  require "EmailSecurity.pm";

  my @OldSignoffIDs    = &GetAllSignoffsByDocRevID($OldDocRevID);
  unless (@OldSignoffIDs) { return 0; }

  my @NewSignoffIDs    = &GetAllSignoffsByDocRevID($NewDocRevID);
  my $SignoffDelete    = $dbh -> prepare("delete from Signoff           where DocRevID=?");
  my $SignatureDelete  = $dbh -> prepare("delete from Signature         where SignoffID=?");
  my $DependencyDelete = $dbh -> prepare("delete from SignoffDependency where SignoffID=?");
 
  $SignoffDelete -> execute ($NewDocRevID);
  foreach my $CleanupSignoffID (@NewSignoffIDs) {
      $SignatureDelete -> execute ($CleanupSignoffID);    
      $DependencyDelete -> execute ($CleanupSignoffID);    
  }


  my $SignoffInsert    = $dbh -> prepare("insert into Signoff (SignoffID, DocRevID, Note, TimeStamp) ".
                                         "values (0,?,?,?)");
  my $SignatureInsert  = $dbh -> prepare("insert into Signature (SignatureID,EmailUserID,SignoffID, Note, Signed, TimeStamp) ".
                                         "values (0,?,?,?,?,?)");
  my $DependencyInsert = $dbh -> prepare("insert into SignoffDependency (SignoffDependencyID,PreSignoffID,SignoffID) ".
                                         "values (0,?,?)");

  my @SignoffIDs     = &GetOrderedSignoffsByDocRevID($OldDocRevID);
  my $NumSignoffs    = scalar(@SignoffIDs);
  my $PreSignoffID   = 0;
  my $FirstSignoffID = 0;
  


  for ($i = 0 ; $i < $NumSignoffs ; $i++) {
      my $OldSignoffID = $SignoffIDs[$i];
      my $TimeStamp    = 0;

      my $SignoffNote = ();
      &FetchSignoff($OldSignoffID);
      if ($CopySignatures) {
          $SignoffNote = $Signoffs{$OldSignoffID}{Note};
          $TimeStamp   = $Signoffs{$OldSignoffID}{TimeStamp};
      }

      $SignoffInsert -> execute($NewDocRevID, $SignoffNote, $TimeStamp);
      my $SignoffID = $SignoffInsert -> {mysql_insertid};  #Get the SignoffID of the newly 
      unless ($FirstSignoffID) {
          $FirstSignoffID = $SignoffID;
      }

      my @SignatureIDs = &GetSignatures($OldSignoffID);

      foreach my $OldSignatureID (@SignatureIDs) {
          &FetchSignature($OldSignatureID);

          my $EmailUserID = $Signatures{$OldSignatureID}{EmailUserID};
          my $Note        = ();
          my $Signed      = ();
          my $TimeStamp   = $SQL_NOW;

          if (isActiveUser($EmailUserID)) {
              if ($CopySignatures) {
                 $Note        = $Signatures{$OldSignatureID}{Note};
                 $Signed      = $Signatures{$OldSignatureID}{Signed};
                 $TimeStamp   = $Signatures{$OldSignatureID}{TimeStamp};
              }

              $SignatureInsert  -> execute($EmailUserID, $SignoffID, $Note, $Signed, $TimeStamp);

              my $SignatureID = $SignatureInsert -> {mysql_insertid};  #Get the SignatureID of the newly 
              $Signatures{$SignatureID}{EmailUserID} = $EmailUserID;
              $Signatures{$SignatureID}{SignoffID}   = $SignoffID  ;
              $Signatures{$SignatureID}{Note}        = $Note       ;
              $Signatures{$SignatureID}{Signed}      = $Signed     ;
              $Signatures{$SignatureID}{TimeStamp}   = $TimeStamp  ;

              $DependencyInsert -> execute($PreSignoffID,$SignoffID);
          }
          $PreSignoffID = $SignoffID;
      }
   }

   return $FirstSignoffID; 
}
1;
#
