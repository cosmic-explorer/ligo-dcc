#
# Description: SQL routines to UPDATE the DocDB Author, EmailUser, and SecurityGroup tables 
#
#      Member: Melody C. Araya (maraya@ligo.caltech.edu)
#
# Notes:  
#     $DocDB_Authors{$AuthorID}{AUTHORID}
#     $DocDB_Authors{$AuthorID}{LastName}
#     $DocDB_Authors{$AuthorID}{FirstName}
#     $DocDB_Authors{$AuthorID}{InstitutionID}
#
#     $DocDB_EmailUsers{$EmailUserID}{EMAILUSERID}
#     $DocDB_EmailUsers{$EmailUserID}{AuthorID}
#     $DocDB_EmailUsers{$EmailUserID}{UserName}
#     $DocDB_EmailUsers{$EmailUserID}{FullName}
#     $DocDB_EmailUsers{$EmailUserID}{Verified}
#     $DocDB_EmailUsers{$EmailUserID}{New}
#     $DocDB_EmailUsers{$EmailUserID}{EmployeeNumber}
#

#     $Members{$MemberID}{MEMBERID}
#     $Members{$MemberID}{FULLNAME}
#     $Members{$MemberID}{Formal} 
#     $Members{$MemberID}{LastName}
#     $Members{$MemberID}{FirstName}
#     $Members{$MemberID}{UserName}
#     $Members{$MemberID}{EmailForward}
#     $Members{$MemberID}{RemoteUser}
#     $Members{$MemberID}{ACTIVE}  
#     $Members{$MemberID}{PositionCode};
#     $Members{$MemberID}{InstitutionName};    # Institution ShortName
#     $Members{$MemberID}{DocDB_EmailID}  
#     $Members{$MemberID}{DocDB_AuthorID}  
#     $Members{$MemberID}{VERIFIED}  
#     $Members{$MemberID}{NewEntry}
#     $Members{$MemberID}{NewMember}
# 
#     $FormerGroupMembers{$RemoteUserID}{EmployeeNumber}
#     $FormerGroupMembers{$RemoteUserID}{UserName}
#     $FormerGroupMembers{$RemoteUserID}{FirstName}
#     $FormerGroupMembers{$RemoteUserID}{LastName}
#     $FormerGroupMembers{$RemoteUserID}{EmailForward}
#     $FormerGroupMembers{$RemoteUserID}{RemoteUsername}
#     $FormerGroupMembers{$RemoteUserID}{InstitutionID}
#     $FormerGroupMembers{$RemoteUserID}{AuthorID}
#     $FormerGroupMembers{$RemoteUserID}{EmailUserID}
#     $FormerGroupMembers{$RemoteUserID}{VERIFIED}
#

use Data::Dumper;

require "DocDB_UsersUtilities.pm";  
require "DocDB_InstitutionSQL.pm";  

sub DocDB_UpdateAuthorTable() {

   &DocDB_GetInstitutions();
  
   foreach my $MemberID (keys %Members) {
      my $LastName  =  $Members{$MemberID}{LastName};
      my $FirstName =  $Members{$MemberID}{FirstName};
      my $InstShortName =  $Members{$MemberID}{InstitutionName}; 
      my $Active    =  $Members{$MemberID}{ACTIVE};
      my $UserName  =  $Members{$MemberID}{UserName};
      my $NewInstID = DocDB_GetInstitutionIDByShortName($InstShortName);
      my $EmployeeNumber = $MemberID;

      unless ($InstShortName) {
         next;
      }
      unless ($Active) {
#         print ROSTER_LOG "WARNING: Skipping INACTIVE author: $LastName, $FirstName \n";
                  next;
      }

      my ($AuthorID, $InstID);
      #
      # First make sure that an EmailUser record does not exist for this author
      # 
      # Need to change the call to GetAuthorIDFromMemberID
      #
      $AuthorID = &DocDB_GetAuthorIDFromEmployeeNumber($MemberID);
#      print ROSTER_LOG "DocDB_GetAuthorIDFromEmployeeNumber $MemberID = $AuthorID\n";

      if ($AuthorID) {
          $AuthorID = &DocDB_FetchAuthorByID($AuthorID);
#          print ROSTER_LOG "DocDB_FetchAuthorByID  =  $AuthorID\n";
      }
      else {
          $AuthorID = &DocDB_FetchAuthorByName($FirstName, $LastName);
#          print ROSTER_LOG "DocDB_FetchAuthorByName $FirstName, $LastName = $AuthorID\n";
      }

      if ($AuthorID) {
          $InstID = $DocDB_Authors{$AuthorID}{InstitutionID};
          $ActiveAuthor = $DocDB_Authors{$AuthorID}{Active};
 
          #
          # Figure out if the Institution needs to be updated
          #
          if (!$ActiveAuthor && ($NewInstID ne $InstID)) {
              print ROSTER_LOG 
                  "ACTION_NEEDED: Change Author Institution: $LastName, $FirstName : New Inst=($InstShortName)$NewInstID : Old Inst=$InstID \n";

              ChangeInstitution ($AuthorID, $InstID, $NewInstID);
          }
          #
          # Make sure that the Author status is active
          #
          my $AuthorIDUpdate = $docdb_handle -> prepare("update Author set Active=1 where AuthorID=? ");
          $AuthorIDUpdate->execute($AuthorID);
          $DocDB_Authors{$AuthorID}{Active} = 1;

      } else {
          # 
          #  Add a new entry in the Author table, only if there is an
          #  institution associated with the author.   
          #
          if ($NewInstID) {
              print ROSTER_LOG "INFO:  About to add Author Table for $FirstName $LastName : $NewInstID\n";
             my $author_insert = $docdb_handle -> prepare("insert into Author (FirstName, LastName, InstitutionID) values (?, ?, ?) ");
              my $success = 1;
              $author_insert -> execute ($FirstName, $LastName, $NewInstID) or $success = 0;

              if ($success) {
                  my ($author_id);
                  my $author_select = $docdb_handle -> prepare("select AuthorID from Author where FirstName = ?  AND LastName = ? AND InstitutionID = ?");

                  $author_select -> execute($FirstName, $LastName, $NewInstID);
                  $author_select-> bind_columns(undef, \($author_id));
                  if ($author_select -> fetch) {
                      $DocDB_Authors{$AuthorID}{AUTHORID} = $author_id;
                      $DocDB_Authors{$AuthorID}{LastName} = $LastName;
                      $DocDB_Authors{$AuthorID}{FirstName} = $FirstName;
                      $DocDB_Authors{$AuthorID}{InstitutionID} = $NewInstID;
                  } else {

                  print ROSTER_LOG "ERROR: Unable to insert $LastName, $FirstName : $NewInstID into Author Table\n";
                  }
              }
              else {
                  print ROSTER_LOG "ERROR: Unable to insert $LastName, $FirstName : $NewInstID into Author Table\n";
              }
  
          } else {
              print ROSTER_LOG "ERROR: Cannot figure out DocDB Inst ID for: $LastName, $FirstName : $InstShortName\n";
              print ROSTER_LOG "ACTION_NEEDED: Add Author Entry : $LastName, $FirstName : $InstShortName\n";
          }
       }
    }
}

sub ChangeInstitution($$$) {
    my ($AuthorID, $OldInstID, $NewInstID) = @_;

    # OldInstID: 114 = Unknown 
    if ($OldInstID ==  114) {
        print ROSTER_LOG "WARNING: About to change institution for $AuthorID from $OldInstID to $NewInstID\n";
        my $inst_update = $docdb_handle -> prepare(
             "update Author set InstitutionID=? WHERE AuthorID=?");
        my $success = 1;
        $inst_update -> execute ($NewInstID, $AuthorID) or $success = 0;
    }
}


sub DocDB_ResetEmailUserVerified () {

  my $verified_flag_update= $docdb_handle -> prepare("update EmailUser set Verified=0  WHERE 1"); 
  $verified_flag_update -> execute;

}

sub DocDB_SetEmailUserVerified ($) {
  my ($EmailUserID) = @_;

  my $verified_flag_update= $docdb_handle -> prepare("update EmailUser set Verified=1  WHERE EmailUserID=?"); 
  $verified_flag_update -> execute($EmailUserID);

}


sub DocDB_UpdateEmailUserTable() {
   if ($VERIFY_USERS) {
       DocDB_ResetEmailUserVerified();
   }
   foreach my $MemberID (keys %Members) {
      my $InstShortName =  $Members{$MemberID}{InstitutionName}; 
      my $LastName      =  $Members{$MemberID}{LastName};
      my $FirstName     =  $Members{$MemberID}{FirstName};
      my $FullName      =  $Members{$MemberID}{FULLNAME};
      my $UserName      =  $Members{$MemberID}{UserName};
      my $EmailAddress  =  $Members{$MemberID}{EmailForward};
      my $RemoteUserName=  $Members{$MemberID}{RemoteUser};
      my $InstShortName =  $Members{$MemberID}{InstitutionName}; 
      my $Active        =  $Members{$MemberID}{ACTIVE}; 
      my $GroupID       =  $Members{$MemberID}{GroupID};
      my $VERIFIED      =  1;

      print ROSTER_LOG "Processing $RemoteUserName: EmailAddress: $EmailAddress\n";

      unless ($InstShortName) {
         print ROSTER_LOG "WARNING: $UserName  - no Institution Name\n";
         next;
      }
      unless ($Active) {
         print ROSTER_LOG "WARNING: Skipping INACTIVE EmailUser: $UserName\n";
         next;
      }

      my $InstID = DocDB_GetInstitutionIDByShortName($InstShortName);
#      print "ProcessingEmailUser: $FullName in $InstShortName($InstID)\n";

      my ($AuthorID);
      $AuthorID = DocDB_GetAuthorIDFromUserName($UserName);   

      unless ($AuthorID) {
          $AuthorID = DocDB_GetAuthorID($FirstName, $LastName, $InstID); 
          if (!$AuthorID) {
              $AuthorID = DocDB_AddAuthor($FirstName, $LastName, $InstID); 
          }
      }
      print ROSTER_LOG "AuthorID is $AuthorID\n";

      my ($EmailUserID, $full_name);
      my $email_list = $docdb_handle -> prepare(
          "select EmailUserID, Name from EmailUser where AuthorID=$AuthorID AND EmailAddress LIKE (\"$EmailAddress\")"); 
      $email_list-> execute();
      $email_list-> bind_columns(undef, \($EmailUserID, $full_name));

      #Search the EmailUser table using the AuthorID and EamilAddress
      if ($email_list-> fetch) {
          print ROSTER_LOG "$UserName EmailUserID is $EmailUserID\n";
          if ($EmailUserID) {
              $DocDB_EmailUsers{$EmailUserID}{EMAILUSERID} = $EmailUserID;
              $DocDB_EmailUsers{$EmailUserID}{AuthorID} = $AuthorID;
              $DocDB_EmailUsers{$EmailUserID}{FullName} = $full_name;
              $DocDB_EmailUsers{$EmailUserID}{UserName} = $UserName;
              $DocDB_EmailUsers{$EmailUserID}{EmailAddress} = $EmailAddress;
              $DocDB_EmailUsers{$EmailUserID}{Verified} = 1;
              $DocDB_EmailUsers{$EmailUserID}{New} = 0;
              $DocDB_EmailUsers{$EmailUserID}{EmployeeNumber} = $MemberID;
              $Members{$MemberID}{DocDB_EmailID} = $EmailUserID;
              $Members{$MemberID}{NewEntry}      = 0;
              if ($VERIFY_USERS) {
                  DocDB_SetEmailUserVerified ($EmailUserID);
              }
              #print ROSTER_LOG "INFO: EmailUserID: $EmailUserID EmailAddress: $EmailAddress \n";
          }

          if (!defined($RemoteUserName) || ($RemoteUserName eq "")) {
              print ROSTER_LOG "INFO: Unable to find $RemoteUserName \n";
              AddRemoteUserName($EmailUserID, $EmailAddress, $EmailAddress);
          }
          else {
              #print ROSTER_LOG "INFO:Able to find $RemoteUserName \n";
              AddRemoteUserName($EmailUserID, $RemoteUserName, $EmailAddress);
          }
      } else {

          my $NewEntry = 1;

          # Before adding an EmailUser entry make sure that the UserName does not exist
          my ($emailID, $name, $authorID);
          my $username_list = $docdb_handle -> prepare(
              "select EmailUserID, Name, AuthorID from EmailUser where Username LIKE (\"$UserName\") AND EmailAddress LIKE (\"$EmailAddress\")"); 
          $username_list-> execute();
          $username_list-> bind_columns(undef, \($emailID, $name, $authorID));
          if ($username_list-> fetch) {
              $EmailUserID = $emailID;
              $FullName = $name;
              if ($authorID != $AuthorID) {
                  print ROSTER_LOG 
                       "WARNING: Found Username: $UserName in EmailUser table: About to update AuthorID $authorID to $AuthorID\n";
                  my $email_update = $docdb_handle -> prepare(
                   "update EmailUser set AuthorID=? WHERE Username=? AND EmailUserID=?"); 
                  my $success = 1;
                  $email_update -> execute ($AuthorID, $UserName, $EmailUserID) or $success = 0;
              }
              $NewEntry = 0;
          }

          if ($EmailUserID) {
              #print ROSTER_LOG 
              #     "INFO: Found EmailUser ($EmailUserID,$UserName, $FullName, $EmailAddress,$AuthorID) \n";
              $DocDB_EmailUsers{$EmailUserID}{EMAILUSERID} = $EmailUserID;
              $DocDB_EmailUsers{$EmailUserID}{AuthorID} = $AuthorID;
              $DocDB_EmailUsers{$EmailUserID}{FullName} = $FullName;
              $DocDB_EmailUsers{$EmailUserID}{UserName} = $UserName;
              $DocDB_EmailUsers{$EmailUserID}{EmailAddress} = $EmailAddress;
              $DocDB_EmailUsers{$EmailUserID}{Verified} = 1;
              $DocDB_EmailUsers{$EmailUserID}{New}      = 0;
              $DocDB_EmailUsers{$EmailUserID}{EmployeeNumber} = $MemberID;
              $Members{$MemberID}{DocDB_EmailID} = $EmailUserID;
              $Members{$MemberID}{NewEntry}      = 0;
 
              if ($VERIFY_USERS) {
                 DocDB_SetEmailUserVerified ($EmailUserID);
              }
              $NewEntry = 0;
          }

          if ($AuthorID && $NewEntry) {
              $EmailUserID = DocDB_AddEmailUser($UserName, $FullName, $EmailAddress, 1, $AuthorID, $MemberID);
          }
          if (!defined($RemoteUserName) || ($RemoteUserName eq "")) {
              print ROSTER_LOG "INFO: Unable to find $RemoteUserName \n";
              AddRemoteUserName($EmailUserID, $EmailAddress, $EmailAddress);
          }
          else {
              print ROSTER_LOG "INFO:Able to find $RemoteUserName \n";
              AddRemoteUserName($EmailUserID, $RemoteUserName, $EmailAddress);
          }

      }
   }

   # Log the list of unverified EmailUser records
   #
  
   if ($VERIFY_USERS) {
       my ($EmailUserID, $UserName, $AuthorID);
       my $VerifiedUsers = $docdb_handle -> prepare(
            "select EmailUserID, Username, AuthorID from EmailUser where Verified=0 ");
       $VerifiedUsers -> execute;
       $VerifiedUsers -> bind_columns(undef, \($EmailUserID, $UserName, $AuthorID));

       while ($VerifiedUsers -> fetch) {
          print ROSTER_LOG "ACTION: Cleanup UNVERIFIED EmailUser: $UserName($EmailUserID)\n";
          if ($AuthorID) {
              print ROSTER_LOG "WARNING:  Updating $UserName AuthorID:$AuthorID to Inactive\n";
              my $AuthorIDUpdate = $docdb_handle -> prepare("update Author set Active=0 where AuthorID=? ");
              $AuthorIDUpdate->execute($AuthorID);
          }	
          
           my ($AuthorGroupListID, $AuthorGroupID);
           my $AuthorGroupList = $docdb_handle -> prepare(
             "SELECT AuthorGroupListID, AuthorGroupID from AuthorGroupList where AuthorID=? ");
           $AuthorGroupList -> execute($AuthorID);
           $AuthorGroupList -> bind_columns(undef, \($AuthorGroupListID, $AuthorGroupID));
           while ($AuthorGroupList -> fetch) {
              print ROSTER_LOG "WARNING:  Removing from AuthorGroupList AuthorGroupID: $AuthorGroupID\n";
              my $AuthorGroupUpdate = $docdb_handle -> prepare(
                  "DELETE from AuthorGroupList where AuthorGroupListID=? ");
              $AuthorGroupUpdate->execute($AuthorGroupListID);
           }	

           my ($UsersGroupID, $GroupID);
           my $UsersGroups= $docdb_handle -> prepare(
             "select UsersGroupID, GroupID from UsersGroup RIGHT JOIN EmailUser ON UsersGroup.EmailUserID = EmailUser.EmailUserID where UsersGroup.EmailUserID = ? AND EmailAddress LIKE \(\"%@LIGO.ORG\"\)");
           $UsersGroups-> execute($EmailUserID);
           $UsersGroups-> bind_columns(undef, \($UsersGroupID, $GroupID));
           while ($UsersGroups -> fetch) {
              print ROSTER_LOG "WARNING:  Removing Group: $GroupID for  $UserName \n";
              my $GroupUpdate = $docdb_handle -> prepare("DELETE from UsersGroup where UsersGroupID=? ");
              $GroupUpdate->execute($UsersGroupID);
          }	
       }
   
       DocDB_ResetEmailUserVerified();
   }
}

 
sub DocDB_UpdateUsersGroup() {
    #  Values from the SecurityGroup table
    my $LIGO_LAB = 9;
    my $LSC      = 4;
    my $VIRGO    = 55;
    my $LIO      = 56;
    my $docdbadm = 1;


    foreach my $MemberID (keys %Members) {
       my $Active        =  $Members{$MemberID}{ACTIVE}; 
       my $UserName      =  $Members{$MemberID}{UserName}; 
       my $EmailID       =  $Members{$MemberID}{DocDB_EmailID}; 
       my $PositionCode  =  $Members{$MemberID}{PositionCode};
       my $InstCode      =  $Members{$MemberID}{InstitutionName};    # Institution ShortName
       my $New           =  $Members{$MemberID}{NewEntry};  
       my $GroupID       =  $Members{$MemberID}{GroupID};

      unless ($InstCode) {
         next;
      }
      unless ($Active) {
#         print ROSTER_LOG "WARNING: No group assignment: skipping $EmailID: $UserName\n";
         &RemoveEmailUserIDFromUserGroups($EmailID, $UserName);
         next;
      }
      unless ($EmailID) {
         next;
      }
 
       my $inVIRGO = ($InstCode eq "VIRGO");
       my $inGEO   = ($InstCode eq "GEO");
       my $inLIGO  = ($InstCode eq "CT" || $InstCode eq "LM"  || 
                      $InstCode eq "LO" || $InstCode eq "LV");

       my $inLIO   = ($GroupID == $LIO);
       
       my $new_group = $GroupID;

       if ($new_group == 0) {
           $new_group = $VIRGO;
           print ROSTER_LOG "ACTION_NEEDED: No group assignment for $UserName  defaultiong to $new_group \n";
       }
 
       # We don't limit admin or undergrad group anymore
       # Check if this person is in the administrative group
       #if ($PositionCode) {
       #   if ($PositionCode == 7 || $PositionCode == 8) {
       #   } else {
       #      $new_group = $LSC;
       #   }
       #}

       if ($inLIGO) {
           $new_group = $LIGO_LAB;
       } elsif ($inGEO) {
           $new_group = $LSC;
       } elsif ($inVIRGO) {
           $new_group = $VIRGO
       } elsif ($inLIO) {
           $new_group = $LIO;
       }

       # Check if this user already has an entry in the UsersGroup table
       my ($CalculatedGroupID);
       my $UsersGroupSelect = $docdb_handle -> prepare("select GroupID from UsersGroup where EmailUserID= ?");
       $UsersGroupSelect->execute($EmailID);
       $UsersGroupSelect -> bind_columns(undef, \($CalculatedGroupID));

       while ($UsersGroupSelect -> fetch) {
          if (!$New) {
             if ($new_group != $CalculatedGroupID) {
                print ROSTER_LOG "ACTION_NEEDED: $UserName group assignment to $new_group from $CalculatedGroupID \n";
                if ($new_group == $LIO && ( ($CalculatedGroupID == 2) || ($CalculatedGroupID == 4 ) || ($CalculatedGroupID == 9) ) ) {
                    print ROSTER_LOG "WARNING: Found LIO.  Updating $UserName.  Changing to $LIO instead of $CalculatedGroupID assignment\n";
                    my $UsersGroupUpdate = $docdb_handle -> prepare("update UsersGroup set GroupID=? where EmailUserID=? ");
                     $UsersGroupUpdate->execute($new_group, $EmailID);
                }
             }
	     next;
          }
          #  Don't change  entries for docdbadm 
          if ($CalculatedGroupID == $docdbadm) {
              print ROSTER_LOG "INFO: $UserName already assigned $CalculatedGroupID skipping assignment\n";
              next; 
          }
          if (!$New) {
             print ROSTER_LOG "ACTION_NEEDED: Skipping $UserName group assignment to: $new_group  \n";
	     next;
          }

          #
          # NEW ENTRY
          #
          DocDB_AddMembership( $EmailID, $new_group);
          
       }
       #
       # Assign a group
       #
       if ($CalculatedGroupID == 0 && $new_group != 0) {
          if  ($new_group == 6) {
               print ROSTER_LOG "ACTION NEEDED: Need to assign group to $UserName \n";
          } 
          else {
               print ROSTER_LOG "INFO: About to assign $new_group for $UserName \n";
               DocDB_AddMembership( $EmailID, $new_group);
          }
       }
    }

    VerifyAllEmailUsersInUserGroups();
}

sub VerifyAllEmailUsersInUserGroups() {

   my ($UserGroupID, $EmailUserID, $GroupID);
   my $AllUserGroups = $docdb_handle -> prepare(
        "select UsersGroupID, EmailUserID, GroupID from UsersGroup");
   $AllUserGroups -> execute;
   $AllUserGroups -> bind_columns(undef, \($UserGroupID, $EmailUserID, $GroupID));

   while ($AllUserGroups -> fetch) {
       unless ($EmailUserID) {
          print ROSTER_LOG "ACTION_NEEDED:  No EmailUserID for $UserGroupID in the UsersGroup table\n";
          next;
       }
       unless ($GroupID) {
          print ROSTER_LOG "ACTION_NEEDED:  No GroupID for $UserGroupID in the UsersGroup table\n";
          next;
       }
       
       &DocDB_FetchEmailUserByID($EmailUserID);
       if ($DocDB_EmailUsers{$EmailUserID}{EMAILUSERID} == 0) {
          print ROSTER_LOG "ACTION_NEEDED:  Unknown EmailUserID:$EmailUserID for $UserGroupID in the UsersGroup table\n";
       }
   }
}

sub RemoveEmailUserIDFromUserGroups($$) { 
    my ($EmailUserID, $UserName) = @_;
  
    unless ($EmailUserID) {
       my ($emailid);
       my $email_list = $docdb_handle -> prepare(
          "select EmailUserID from EmailUser where UserName=?"); 
       $email_list-> execute($UserName);
       $email_list-> bind_columns(undef, \($emailid));
       if ($email_list-> fetch) {
           $EmailUserID = $emailid;
       }
    }
    
    if ($EmailUserID) {
       my ($rm_UsersGroupID, $rm_GroupID);
       my $UsersGroupSelect = $docdb_handle -> prepare(
             "select UsersGroupID, GroupID from UsersGroup RIGHT JOIN EmailUser ON UsersGroup.EmailUserID = EmailUser.EmailUserID where UsersGroup.EmailUserID = ? AND EmailAddress LIKE \(\"%@LIGO.ORG\"\)");
       $UsersGroupSelect ->execute($EmailUserID);
       $UsersGroupSelect -> bind_columns(undef, \($rm_UsersGroupID, $rm_GroupID));

       while ($UsersGroupSelect -> fetch) {
          &DocDB_FetchEmailUserByID($EmailUserID);
          my $fullname = $DocDB_EmailUsers{$EmailUserID}{FullName};
          print ROSTER_LOG "WARNING:  About to remove UsersGroupID:$rm_UsersGroupID: [EmailID=$EmailUserID, Name=$fullname, Group=$rm_GroupID]\n";
          my $remove_entry = $docdb_handle -> prepare(
             "DELETE from UsersGroup where UsersGroupID = ? "); 
          $remove_entry-> execute($rm_UsersGroupID);
       }
    }
    
}

1;
