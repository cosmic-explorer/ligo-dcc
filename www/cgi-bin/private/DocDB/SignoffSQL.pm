#
# Name: $RCSfile: SignoffSQL.pm,v $
# Description: SQL interface routines for signoffs
#    Revision: $Revision: 1.9.6.5 $
#    Modified: $Author: vondo $ on $Date: 2007/09/25 16:53:03 $
#
#      Author: Eric Vaandering (ewv@fnal.gov)

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
use POSIX;

%SignoffStates =  qw (unsign approve abstain disapprove);

%SignoffDBValues = (
     unsign     => 0,
     approve    => 1,
     abstain    => 2,
     disapprove => 3
);

%SignoffActions = (
     unsign     => "Unsigned",
     approve    => "Signed",
     disapprove => "Denied",
     abstain    => "Abstained"
);

%SignoffButtons = (
     unsign     => "Clear\ selection",
     approve    => "Sign",
     disapprove => "Deny",
     abstain    => "Abstain"
);

%FinalApproverButtons = (
     unsign     => "Clear [Dis]Approval",
     approve    => "Final\ Approval",
     disapprove => "Final\ Disapproval",
     abstain    => ""
);


%FinalApproverActions = (
     unsign     => "Cleared",
     approve    => "Approved",
     disapprove => "Disapproved",
     abstain    => ""
);


sub ProcessSignoffList ($) {
  my ($SignoffList) = @_;

  require "EmailSecurity.pm";

  # FIXME: Handle authors in Smith, John format too

  my $EmailUserID;
  my @EmailUserIDs = ();
  my @SignatoryEntries = split /\n/,$SignoffList;
  foreach my $Entry (@SignatoryEntries) {
    chomp $Entry;
    $Entry =~ s/^\s+//g;
    $Entry =~ s/\s+$//g;

    unless ($Entry) {
      push @WarnStack,"A blank line was entered into the signoff list. It was ignored.";
      next;
    }

    if (grep /\,/, $Entry) {
      @Parts = split /\,\s+/, $Entry,2;
      $Entry = join ' ',@Parts[1],@Parts[0];
    }

    my $EmailUserList = $dbh -> prepare("select EmailUserID from EmailUser where Name=?");

### Find exact match (initial or full name)

    $EmailUserList -> execute($Entry);
    $EmailUserList -> bind_columns(undef, \($EmailUserID));
    @Matches = ();
    while ($EmailUserList -> fetch) {
      push @Matches,$EmailUserID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      if (CanSign($EmailUserID)) {
        require "DocumentSQL.pm";
        my $DocAlias = FetchDocumentAlias($DocumentID);
        push @EmailUserIDs,$EmailUserID;
        next;
      } else {
        push @ErrorStack,"$Entry is not allowed to sign documents. Contact an administrator to change the permissions or ".
                         "restrict your choices to those who can sign documents.";
      }
    }

    push @ErrorStack,"No unique match was found for the signoff $Entry. Please go
                      back and try again.";
  }
  return @EmailUserIDs;
}

sub InsertSignoffList (@) {
  my ($DocRevID,$ParallelSignoff,@EmailUserIDs) = @_;

  require "EmailSecurity.pm";

  my $ParallelSignoffUpdate = $dbh -> prepare("update DocumentRevision set ParallelSignoff=? WHERE DocRevID=?");
  $ParallelSignoffUpdate -> execute ($ParallelSignoff, $DocRevID);


  my $SignoffInsert    = $dbh -> prepare("insert into Signoff (SignoffID,DocRevID) ".
                                         "values (0,?)");
  my $SignatureInsert  = $dbh -> prepare("insert into Signature (SignatureID,EmailUserID,SignoffID) ".
                                         "values (0,?,?)");
  my $DependencyInsert = $dbh -> prepare("insert into SignoffDependency (SignoffDependencyID,PreSignoffID,SignoffID) ".
                                         "values (0,?,?)");

  # For now, we just do something simple. Insert the first with one signature,
  # the second depends on it, etc.

  my $PreSignoffID = 0;
  my $FirstSignoffID = 0;
  foreach $EmailUserID (@EmailUserIDs) {
    unless (CanSign($EmailUserID)) {
      push @WarnStack,"$EmailUser{$EmailUserID}{Name} cannot sign documents. Not added to list.";
      next;
    }
    $SignoffInsert    -> execute($DocRevID);
    my $SignoffID = $SignoffInsert -> {mysql_insertid}; # Works with MySQL only
    unless ($FirstSignoffID) {
      $FirstSignoffID = $SignoffID;
    }
    $SignatureInsert  -> execute($EmailUserID,$SignoffID);
    $DependencyInsert -> execute($PreSignoffID,$SignoffID);
    if (!$ParallelSignoff) {
        $PreSignoffID = $SignoffID;
    }
  }
  return $FirstSignoffID;
}

sub GetRootSignoffs ($) {
  my ($DocRevID) = @_;

  my @RootSignoffs = ();

  my $SignoffList = $dbh -> prepare("select Signoff.SignoffID from Signoff,SignoffDependency ".
                                     "where SignoffDependency.PreSignoffID=0 ".
                                      "and SignoffDependency.SignoffID=Signoff.SignoffID ".
                                      "and Signoff.DocRevID=?");

  $SignoffList -> execute($DocRevID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @RootSignoffs,$SignoffID;
  }

  return @RootSignoffs;
}

sub isParallelByDocRevID ($) {
  my ($DocRevID) = @_;

  my $ParallelSignoff = NULL;
  my $ParallelQuery =  $dbh -> prepare("select ParallelSignoff from DocumentRevision ".
                                       "where DocRevID=?");
  $ParallelQuery -> execute($DocRevID);
  $ParallelQuery -> bind_columns(undef, \($ParallelSignoff));
  $ParallelQuery -> fetch;

  return $ParallelSignoff;

}


sub GetAllSignoffsByDocRevID ($) {
  my ($DocRevID) = @_;
  my @SignoffIDs = ();

  my $SignoffList = $dbh -> prepare("select SignoffID from Signoff ".
                                     "where DocRevID=?");

  $SignoffList -> execute($DocRevID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @SignoffIDs,$SignoffID;
  }
  return @SignoffIDs;
}

sub GetAllEmailUserIDsBySignoffIDs {
  my @SignoffIDs = @_;
  my @EmailUserIDs = ();
  my $EmailList = $dbh -> prepare("select EmailUserID from Signature where SignoffID=?");
  foreach my $id (@SignoffIDs) {
     $EmailList -> execute($id);
     $EmailList ->bind_columns(undef, \($EmailUserID));
     while($EmailList -> fetch) {
       push @EmailUserIDs, $EmailUserID;
     }
  }
   return @EmailUserIDs;
}

sub GetActiveEmailUserIDsByDocRevID ($) {
  my ($DocRevID) = @_;
  my @EmailUserIDs = ();

  my $EmailUserID = 0;
  my $EmailList = $dbh -> prepare("select EmailUserID from Signature JOIN Signoff ".
                                  "ON Signoff.SignoffID = Signature.SignoffID  where Signoff.DocRevID=?");
  $EmailList -> execute($DocRevID);
  $EmailList ->bind_columns(undef, \($EmailUserID));

  while($EmailList -> fetch) {
    
     if (FetchUserGroupIDs($EmailUserID)) {
          if ($myDEBUG) {print  DEBUG "GetActiveEmailUserIDsByDocRevID $EmailUserID\n";}
          push @EmailUserIDs, $EmailUserID;
     }
  }

  return @EmailUserIDs;
}

sub GetAllSignoffsByDocRevID ($) {
  my ($DocRevID) = @_;
  my @SignoffIDs = ();

  my $SignoffList = $dbh -> prepare("select SignoffID from Signoff ".
                                     "where DocRevID=?");

  $SignoffList -> execute($DocRevID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @SignoffIDs,$SignoffID;
  }
  return @SignoffIDs;
}

sub GetAllEmailUserIDsBySignoffIDs {
  my @SignoffIDs = @_;
  my @EmailUserIDs = ();
  my $EmailList = $dbh -> prepare("select EmailUserID from Signature where SignoffID=?");
  foreach my $id (@SignoffIDs) {
     $EmailList -> execute($id);
     $EmailList ->bind_columns(undef, \($EmailUserID));
     while($EmailList -> fetch) {
       push @EmailUserIDs, $EmailUserID;
     }
  }
   return @EmailUserIDs;
}

sub InactiveUsersInSignoff($) {

  my ($DocRevID) = @_;

  if ($myDEBUG) {print  DEBUG "InactiveUsersInSignoff : DocRevID $DocRevID\n";}
  my @EmailUserIDs = GetAllEmailUserIDsByDocRevID($DocRevID); 
  if ($myDEBUG) {print  DEBUG "InactiveUsersInSignoff @EmailUserIDs\n";}
  my @UserGroupIDs = ();
  my $InactiveUsers = 0;
  
  foreach my $EmailUserID (@EmailUserIDs) {
      @UserGroupIDs = FetchUserGroupIDs($EmailUserID);
      unless (@UserGroupIDs) {
         $InactiveUsers++;
      }
  }
  
  return $InactiveUsers;
}

sub GetAllEmailUserIDsByDocRevID ($) {
  my ($DocRevID) = @_;
  my @EmailUserIDs = ();

  my $EmailUserID = 0;
  my $EmailList = $dbh -> prepare("select EmailUserID from Signature JOIN Signoff ".
                                  "ON Signoff.SignoffID = Signature.SignoffID  where Signoff.DocRevID=?");
  $EmailList -> execute($DocRevID);
  $EmailList ->bind_columns(undef, \($EmailUserID));

  while($EmailList -> fetch) {
     if ($myDEBUG) {print  DEBUG "GetAllEmailUserIDsByDocRevID $EmailUserID\n";}
     push @EmailUserIDs, $EmailUserID;
  }

  return @EmailUserIDs;
}
sub GetSignoffDocumentIDs (%) {
  my %Params = @_;

  my $EmailUserID = $Params{-emailuserid} || 0;

  my @DocumentIDs = ();
  my $List;

  if ($EmailUserID) {
    $List = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from Signature,Signoff,DocumentRevision
            where Signature.EmailUserID=? and Signoff.SignoffID=Signature.SignoffID and
            Signoff.DocRevID=DocumentRevision.DocRevID");
    $List -> execute($EmailUserID);
  }

  if ($List) {
    my $DocumentID;
    $List -> bind_columns(undef, \($DocumentID));
    while ($List -> fetch) {
      push @DocumentIDs,$DocumentID;
    }
  }

  return @DocumentIDs;
}

sub GetSignoffIDs (%) {
  my %Params = @_;

  my $EmailUserID = $Params{-emailuserid} || 0;

  my @SignoffIDs = ();
  my $List;

  if ($EmailUserID) {
    $List = $dbh -> prepare("select DISTINCT(Signature.SignoffID) from Signature
            where Signature.EmailUserID=?");
    $List -> execute($EmailUserID);
  }

  if ($List) {
    my $SignoffID;
    $List -> bind_columns(undef, \($SignoffID));
    while ($List -> fetch) {
      push @SignoffIDs,$SignoffID;
    }
  }

  return @SignoffIDs;
}


sub FetchSignoff ($) {
  my ($SignoffID) = @_;

  my ($DocRevID,$Note,$TimeStamp);
  my $SignoffFetch = $dbh -> prepare("select DocRevID,Note,TimeStamp from Signoff ".
                                     "where SignoffID=?");

#  if ($Signoffs{$SignoffID}{TimeStamp}) {
#    return $SignoffID;
#  }

  $SignoffFetch -> execute($SignoffID);
  ($DocRevID,$Note,$TimeStamp) = $SignoffFetch -> fetchrow_array;

  if ($TimeStamp) {
    $Signoffs{$SignoffID}{DocRevID}    = $DocRevID   ;
    $Signoffs{$SignoffID}{Note}        = $Note       ;
    $Signoffs{$SignoffID}{TimeStamp}   = $TimeStamp  ;
    return $SignoffID;
  } else {
    return 0;
  }
}

sub GetOrderedSignoffsByDocRevID ($) {
  my ($DocRevID) = @_;
 
  my @SignoffList = ();
  my $SignoffID; 

  my $ParallelSignoff = $DocRevisions{$DocRevID}{ParallelSignoff};

  if ($ParallelSignoff) {
     #
     # Arrange based on SignoffID in ascending order
     #
      my $SignoffListQuery = $dbh -> prepare("SELECT Signature.SignoffID FROM Signature".
          " JOIN Signoff ON Signature.SignoffID = Signoff.SignoffID".
          " WHERE Signoff.DocRevID = ?" .
          " ORDER BY `Signoff`.`SignoffID` ASC");
     $SignoffListQuery -> execute($DocRevID);
     $SignoffListQuery -> bind_columns(undef, \($SignoffID));
     my $i = 0;
     while ($SignoffListQuery -> fetch) {
         $SignoffList[$i]  = $SignoffID;
         $i++;
     }
  }  
  else {
     #  
     #  Use SignoffDependency
     #
     my $PreSignoffID;
     my @SignoffIDs = &GetAllSignoffsByDocRevID($DocRevID);
     my $FirstSignoff = 0;

     if (@SignoffIDs) {
        foreach my $TestSignoff (@SignoffIDs) {
           my $FirstSignoffList = $dbh -> prepare ("SELECT SignoffID FROM SignoffDependency ".
                "WHERE PreSignoffID=0 AND SignoffID= ?");
           $FirstSignoffList -> execute($TestSignoff);
           $FirstSignoffList -> bind_columns(undef, \($SignoffID));
           if ($FirstSignoffList -> fetch) {
                   $FirstSignoff = $SignoffID;
           }
        }
     }

     if ($FirstSignoff == 0) { return; }

     $SignoffList[0] = $FirstSignoff;
     $PreSignoffID = $FirstSignoff; 
     my $SignoffListQuery = $dbh -> prepare ("SELECT SignoffID FROM SignoffDependency " .
       "WHERE SignoffDependency.PreSignoffID = ?");
     $SignoffListQuery -> execute($PreSignoffID);
     $SignoffListQuery -> bind_columns(undef, \($SignoffID));
  
     my $i = 1;
     while ($SignoffListQuery -> fetch) {
         $SignoffList[$i]  = $SignoffID;
         $PreSignoffID = $SignoffID; 
         $i++;
      
         $SignoffListQuery -> execute($PreSignoffID);
         $SignoffListQuery -> bind_columns(undef, \($SignoffID));
     }
  }
 

  return @SignoffList;
}

sub GetSubSignoffs ($) {
  my ($PreSignoffID) = @_;

  my $SignoffID;
  my @SubSignoffIDs = ();

  my $SignoffList = $dbh -> prepare("select SignoffID from SignoffDependency ".
                                     "where PreSignoffID=?");

  $SignoffList -> execute($PreSignoffID);
  $SignoffList -> bind_columns(undef, \($SignoffID));
  while ($SignoffList -> fetch) {
    push @SubSignoffIDs,$SignoffID;
  }

  return @SubSignoffIDs;
}

sub GetPreSignoffs ($) {
  my ($SignoffID) = @_;

  my $PreSignoffID;
  my @PreSignoffIDs = ();

  my $SignoffList = $dbh -> prepare("select PreSignoffID from SignoffDependency ".
                                     "where SignoffID=?");

  $SignoffList -> execute($SignoffID);
  $SignoffList -> bind_columns(undef, \($PreSignoffID));
  while ($SignoffList -> fetch) {
    push @PreSignoffIDs,$PreSignoffID;
  }

  return @PreSignoffIDs;
}

sub GetSignature ($) {
  my ($SignoffID) = @_;

  my $SignatureID;

  my $Signature = $dbh -> prepare("select SignatureID from Signature ".
                                     "where SignoffID=?");

  $Signature -> execute($SignoffID);
  $Signature -> bind_columns(undef, \($SignatureID));
  if ($Signature -> fetch) { 
      &FetchSignature($SignatureID);
  }

  return $SignatureID;
}

sub GetSignatures ($) {
  my ($SignoffID) = @_;

  my $SignatureID;
  my @SignatureIDs = ();

  my $SignatureList = $dbh -> prepare("select SignatureID from Signature ".
                                     "where SignoffID=?");

  $SignatureList -> execute($SignoffID);
  $SignatureList -> bind_columns(undef, \($SignatureID));
  while ($SignatureList -> fetch) { &FetchSignature($SignatureID);
    push @SignatureIDs,$SignatureID;
  }

  return @SignatureIDs;
}


sub GetPreSignatures ($) {
  my ($SignoffID) = @_;

  my $SignatureID;
  my @PreSignatureIDs = ();

  my $PreSignatureList = $dbh -> prepare("select SignatureID from Signature ".
                                     "where SignoffID=?");

  $SignatureList -> execute($SignoffID);
  $SignatureList -> bind_columns(undef, \($SignatureID));
  while ($SignatureList -> fetch) { &FetchSignature($SignatureID);
    push @SignatureIDs,$SignatureID;
  }

  return @SignatureIDs;
}

sub GetLastSignerByDocRevID ($) {
  my ($DocRevID) = @_;

  my $EmailUserID = 0;

  #
  # Get the last signer based on SignoffID 
  #
   my $SignoffListQuery = $dbh -> prepare("SELECT Signature.EmailUserID FROM Signature".
       " JOIN Signoff ON Signature.SignoffID = Signoff.SignoffID".
       " WHERE Signoff.DocRevID = ?" .
       " ORDER BY `Signoff`.`SignoffID` DESC LIMIT 1");
  $SignoffListQuery -> execute($DocRevID);
  $SignoffListQuery -> bind_columns(undef, \($EmailUserID));
  if ($SignoffListQuery -> fetch) {
     return $EmailUserID;
  }
  return 0;

}

sub GetLastSignoffIDByDocRevID ($) {
  my ($DocRevID) = @_;

  my $SignoffID = 0;

  #
  # Get the last signer based on SignoffID 
  #
   my $SignoffListQuery = $dbh -> prepare("SELECT SignoffID FROM Signoff".
       " WHERE DocRevID = ?" .
       " ORDER BY SignoffID DESC LIMIT 1");
  $SignoffListQuery -> execute($DocRevID);
  $SignoffListQuery -> bind_columns(undef, \($SignoffID));
  if ($SignoffListQuery -> fetch) {
     return $SignoffID;
  }
  
  return 0;

}

sub GetLastSignatureValueBySignoffID($) {
  my ($SignoffID) = @_;

  my $Signed;
  #
  # Get the last signature value  based on the SignoffID
  #
   my $SignatureQuery = $dbh -> prepare("SELECT Signed FROM Signature".
       " WHERE Signature.SignoffID = ?");
  $SignatureQuery -> execute($DocRevID);
  $SignatureQuery -> bind_columns(undef, \($Signed));
  if ($SignatureQuery -> fetch) {
      return $Signed;
  }

  return 0;
}

sub isLastSignoffID($) {
  my ($SignoffID) = @_;

  #
  # Get the DocRevID based on SignoffID 
  #
  #
  my $DocRevID = 0;
  my $DocRevIDQuery = $dbh -> prepare("SELECT DocRevID FROM Signoff".
       " WHERE SignoffID = ?" );
  $DocRevIDQuery -> execute($SignoffID);
  $DocRevIDQuery -> bind_columns(undef, \($DocRevID));
  if ($DocRevIDQuery -> fetch) {
     my $LastSignoffID = GetLastSignoffIDByDocRevID($DocRevID);
     if ($LastSignoffID == $SignoffID) {
        return 1;
     }
  }
  
  return 0;
}


sub isPendingSignature($$$) {
  my ($DocRevID, $EmailUserID, $IncludeApprover) = @_;
  my ($Signed, $SignoffID);

  my $SignedQuery = $dbh -> prepare("SELECT Signed, Signature.SignoffID FROM Signature ".
       " JOIN Signoff ON Signature.SignoffID = Signoff.SignoffID ".
       " WHERE Signoff.DocRevID = ? AND Signature.EmailUserID = ?");
  $SignedQuery -> execute($DocRevID, $EmailUserID);
  $SignedQuery -> bind_columns(undef, \($Signed, $SignoffID));
  if ($SignedQuery -> fetch) {
      if ($IncludeApprover) {
         unless ($Signed) {
             return 1;
         }
         else {
             if ($Signed == 0) {
                 return 1;
             }
         }
      }
      else {
         if (!isLastSignoffID($SignoffID)) {
             unless ($Signed) {
                 return 1;
             }
             else {
                 if ($Signed == 0) {
                     return 1;
                 }
             }
         }
      }
  }
  
  return 0;
}

#using POD syntax here
=item isRevisionOpenforSignature($DocRevID)

    Input: existing DocRevID
    Returns: boolean true if all following conditions are met:

   1- revision is NOT obsolete (i.e. this is the active rev in the document version)
   2- a signature (serial or parallel) is defined for this revision
   3-  the (final) approver has not signed the revision

  returns false otherwise
=cut
sub isRevisionOpenforSignature($) {
    my ($DocRevID)= @_;

    use Data::Dumper;
    #check 1- and 2- in one sql query
    my $RevNotObsoleteAndHasSignatureQuery = $dbh -> prepare("SELECT UNIQUE(DocumentRevision.DocumentID) as DocumentID ".
    "FROM DocumentRevision JOIN Signoff ON DocumentRevision.DocRevID = Signoff.DocRevID ".
    "WHERE DocumentRevision.DocRevID = ? AND DocumentRevision.Obsolete = 0") or die $dbh->errstr;
    $RevNotObsoleteAndHasSignatureQuery -> execute($DocRevID) or die('could not execute $RevNotObsoleteAndHasSignatureQuery');
    # if query comes back empty either the rev is obsolete or there is no signature process
    my $DocID=$RevNotObsoleteAndHasSignatureQuery->fetchrow_array();
    unless ( defined($DocID) ) { return 0; }
    # (Signed = 0 or Signed is NULL) because no default value in table definition
    my $HasApproverAlreadySigned = $dbh -> prepare("SELECT Signature.Signed FROM Signature, Signoff ".
     " WHERE Signature.SignoffID=Signoff.SignoffID ".
         "AND Signoff.DocRevID = ? ORDER BY Signoff.SignoffID DESC limit 1 ;") or die $dbh->errstr;
    $HasApproverAlreadySigned -> execute($DocRevID) or die('could not execute $HasApproverAlreadySigned'.
      "\n statement : ".$HasApproverAlreadySigned-> {Statement});
    my $Signed= $HasApproverAlreadySigned -> fetchrow_array();

    return  ($Signed !=0 )  ? 0 : 1;
}


# Surprisingly, this is called when you click 'Sign Document'!!
sub ClearSignatures {
   $HaveAllSignatures = 0;
   %Signatures = ();
}

sub FetchSignature ($) {
  my ($SignatureID) = @_;

  my ($EmailUserID,$SignoffID,$Note,$Signed,$TimeStamp);
  my $SignatureFetch = $dbh -> prepare("select EmailUserID,SignoffID,Note,Signed,TimeStamp from Signature ".
                                     "where SignatureID=?");

#  if ($Signatures{$SignatureID}{TimeStamp}) {
#    return $SignatureID;
#  }

  $SignatureFetch -> execute($SignatureID);
  ($EmailUserID,$SignoffID,$Note,$Signed,$TimeStamp) = $SignatureFetch -> fetchrow_array;

  if ($TimeStamp) {
    $Signatures{$SignatureID}{EmailUserID} = $EmailUserID;
    $Signatures{$SignatureID}{SignoffID}   = $SignoffID  ;
    $Signatures{$SignatureID}{Note}        = $Note       ;
    $Signatures{$SignatureID}{Signed}      = $Signed     ;
    $Signatures{$SignatureID}{TimeStamp}   = $TimeStamp  ;
    return $SignatureID;
  } else {
    return 0;
  }
}

sub GetSignatureText ($) { 
  use Time::Piece;  # for time/date calculations

  my ($SignatureID) = @_;

  my $ServerTimeZone = strftime "%Z", localtime() ;
  my $currentJulianDay = localtime->julian_day;

  if (FetchSignature ($SignatureID)) {
      my $SignValue = $Signatures{$SignatureID}{Signed};
      if ($SignValue) {
         my $signIndex = "unsigned" ;
         if ($SignValue == 1) { $signIndex = "approve";}
         if ($SignValue == 2) { $signIndex = "abstain";}
         if ($SignValue == 3) { $signIndex = "disapprove";}
         
         my $signaction;
         my $signoffid = $Signatures{$SignatureID}{SignoffID};
         if (isLastSignoffID($signoffid)){
             $signaction = $FinalApproverActions{$signIndex};
         }
         else {
             $signaction = $SignoffActions{$signIndex};
         }
         my $timestamp = $Signatures{$SignatureID}{TimeStamp};
         my $SignatureJulianDay= Time::Piece->strptime($timestamp, '%Y-%m-%d %H:%M:%S')->julian_day;
         if ($currentJulianDay - $SignatureJulianDay >2) {
            #expedient way to get only the date from the full timestamp
            ($timestamp)= split(' ', $timestamp);  
            $ServerTimeZone='';           
         } 
         if ($signIndex eq "unsigned") {
             $Message = "($signaction)";
         }
         else {
             $Message = "($signaction on $timestamp $ServerTimeZone)";
         }
         return $Message;
      }
  }
  return "";
  
}



##########
sub GetSignerEmail ($) {
  my ($EmailUserID) = @_;
 
  my @SignerEmails = ();
  my $SignerEmailList = $dbh->prepare("select EmailAddress from EmailUser where EmailUserID=?"); 
  $SignerEmailList->execute($EmailUserID);
  $SignerEmailList->bind_columns(undef, \($EmailAddress));
  while ($SignerEmailList->fetch) {
    push @SignerEmails,$EmailAddress;
  }
 
  return @SignerEmails;
}
 
sub GetAllEmails (%) {
  my @EmailUserIDs = ();
 
  my ($DocRevID) = @_;
  my $list = $dbh->prepare("select distinct(EmailUserID) from Signature ".
                           "where SignoffID in ".
                           "(select SignoffID from Signoff where DocRevID=?)");
  $list->execute($DocRevID);
  $list->bind_columns(undef, \($EmailUserID));
  while ($list->fetch) {
    #print "$EmailUserID\n";
    push @EmailUserIDs,$EmailUserID;
  }
  @AllAddresses = ();
  foreach my $email (@EmailUserIDs) {
    my ($EmailUserID) = @_;
    my $addr = $dbh->prepare("select EmailAddress from EmailUser where EmailUserID=?");
    $addr->execute($email);
    $addr->bind_columns(undef, \($EmailAddress));
    while ($addr->fetch) {
      #print "$EmailAddress\n";
      push @AllAddresses,$EmailAddress;
    }
  }
  return @AllAddresses;
}


##########

#
# Number of signers who've signed
#
sub NumberOfSigners($) {
   my ($docrevid) = @_;
   my $N = 0;

   my ($EmailUserID, $Signed) = (); 
   my $query = $dbh->prepare("SELECT EmailUserID, Signed from Signature ".
                             " RIGHT JOIN Signoff ON Signoff.SignoffID = Signature.SignoffID ".
                             " WHERE Signoff.DocRevID=? ");
   $query->execute($docrevid);
   $query->bind_columns(undef, \($EmailUserID, $Signed));
   while ($query->fetch) {
      if ($Signed == 1) {
          $N++;
      }
   }
   return $N;

}


#
# Size of SignoffList
#
sub SizeOfSignoffList($) {
   my ($DocRevID) = @_;

   my $N = 0;

   my ($Signed) = (); 
   my $query = $dbh->prepare("SELECT Signed from Signature ".
                             " RIGHT JOIN Signoff ON Signoff.SignoffID = Signature.SignoffID ".
                             " WHERE Signoff.DocRevID=? ");
   $query->execute($DocRevID);
   $query->bind_columns(undef, \($Signed));
   while ($query->fetch) {
      $N++;
   }


   return $N;

}

#
# Number of signers who have responded
#
sub NumberOfResponders($) {
   my ($docrevid) = @_;
   my $N = 0;

   my $query = $dbh->prepare("SELECT `Signed`, `SignatureID` from `Signature` ".
                             " JOIN Signoff ON Signoff.SignoffID = Signature.SignoffID ".
                             " WHERE Signoff.DocRevID=? ");

   $query->execute($docrevid) or die ("Exec failed: $!");
  
   while (my @row = $query->fetchrow_array()){
      my $Signed = $row[0];
      my $SignatureID = $row[1];
      if ($myDEBUG) { print DEBUG "NumberOfResponders DocRevID $docrevid  SignatureID: $SignatureID Signed: $Signed\n"; }
      unless ($Signed) {
         if ($myDEBUG) { print DEBUG "unless signed $SignatureID \n"; }
      }
      else {
          if ($Signed >= 1) {
              $N++;
          }
      }
   }

   if ($myDEBUG) { print DEBUG "NumberOfResponders $N\n"; }
   return $N;

}

sub NumberOfPendingSignatures($) {
   my ($docrevid) = @_;
   my $N = 0;

   my ($EmailUserID, $Signed) = ();
   my $query = $dbh->prepare("SELECT EmailUserID, Signed from Signature ".
                             " RIGHT JOIN Signoff ON Signoff.SignoffID = Signature.SignoffID ".
                             " WHERE Signoff.DocRevID=? ");
   $query->execute($docrevid);
   $query->bind_columns(undef, \($EmailUserID, $Signed));
   while ($query->fetch) {
      if (!$Signed ) {
          $N++;
      }
   }

   return $N;
}



sub NumberOfDaysSince($) {

   ($SignoffID) = @_;

   my $NumOfDays = 0;

   my $PreSignoffID = 0;
   my $SignoffQuery = $dbh -> prepare("select PreSignoffID from SignoffDependency ".
                                       "where SignoffID=?");
 
   $SignoffQuery -> execute($SignoffID);
   $SignoffQuery -> bind_columns(undef, \($PreSignoffID));
   $SignoffQuery -> fetch;

   my ($SignoffTimeStamp, $PreSignoffTimeStamp) = ();

   $TimeNow = ();
   my $TimeStampQuery  =  $dbh->prepare ( "SELECT NOW()");
   $TimeStampQuery -> execute();
   $TimeStampQuery -> bind_columns(undef, \($TimeNow));
   $TimeStampQuery -> fetch;

   if ($PreSignoffID) {
       my $PreSignoffTimeStampQuery = $dbh->prepare ("SELECT TimeStamp FROM Signature WHERE SignoffID = ?");
       $PreSignoffTimeStampQuery -> execute($PreSignoffID);
       $PreSignoffTimeStampQuery -> bind_columns(undef, \($PreSignoffTimeStamp));
       $PreSignoffTimeStampQuery -> fetch;
   
       my $query_string = qq ( SELECT DATEDIFF( '$TimeNow', '$PreSignoffTimeStamp') );
       my $query = $dbh->prepare($query_string);
       $query -> execute();

       $query->bind_columns(undef, \($NumOfDays));
       if ($query->fetch()) {
   
       }
   } else {
       my $SignoffTimeStampQuery   = $dbh->prepare ( "SELECT TimeStamp FROM Signature WHERE SignoffID = ?");
       $SignoffTimeStampQuery -> execute($SignoffID);
       $SignoffTimeStampQuery -> bind_columns(undef, \($SignoffTimeStamp));
       $SignoffTimeStampQuery -> fetch;
 
       my $query_string = qq ( SELECT DATEDIFF( '$TimeNow', '$SignoffTimeStamp') );
       my $query = $dbh->prepare($query_string);
       $query -> execute();

       $query->bind_columns(undef, \($NumOfDays));
       if ($query->fetch()) {
   
       }

   }
 
   return abs($NumOfDays);
}

1;
