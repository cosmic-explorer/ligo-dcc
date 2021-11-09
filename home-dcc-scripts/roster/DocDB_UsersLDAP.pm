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

%FormerGroupMembers = ();

sub DocDB_GetFormerGroupMembers($)  {
    my ($GroupID) = @_;


    my ($AuthorID, $EmailUserID, $EmailAddress, $FirstName, $LastName, $Username, $RemoteUsername, $RemoteUserID, $EmployeeNumber, $InstitutionID);
    my $member_list  = $docdb_handle -> prepare(
        "SELECT Author.AuthorID, EmailUser.EmailUserID,  FirstName, LastName, EmailUser.Username, 
                RemoteUser.RemoteUserName, RemoteUser.RemoteUserID, RemoteUser.EmailAddress, EmployeeNumber, InstitutionID FROM Author 
                JOIN EmailUser ON EmailUser.AuthorID = Author.AuthorID 
                JOIN RemoteUser ON EmailUser.EmailUserID = RemoteUser.EmailUserID 
                WHERE EmailUser.EmailUserID IN 
                     (SELECT EmailUserID From UsersGroup 
                      WHERE GroupID = ?)");

    $member_list -> execute($GroupID) or print ROSTER_LOG "MYSQL ERROR2: $DBI::errstr\n";
     
    $member_list -> bind_columns(undef, \($AuthorID, $EmailUserID, $FirstName, $LastName, $Username, $RemoteUsername, $RemoteUserID, $EmailAddress, $EmployeeNumber, $InstitutionID));

    while ($member_list -> fetch) {
          $FormerGroupMembers{$RemoteUserID}{EmployeeNumber} = $EmployeeNumber;
          $FormerGroupMembers{$RemoteUserID}{UserName}       = $Username;
          $FormerGroupMembers{$RemoteUserID}{FirstName}      = $FirstName;
          $FormerGroupMembers{$RemoteUserID}{LastName}       = $LastName;
          $FormerGroupMembers{$RemoteUserID}{EmailForward}   = $EmailAddress;
          $FormerGroupMembers{$RemoteUserID}{RemoteUsername} = $RemoteUsername;
          $FormerGroupMembers{$RemoteUserID}{InstitutionID}  = $InstitutionID;
          $FormerGroupMembers{$RemoteUserID}{AuthorID}       = $AuthorID;
          $FormerGroupMembers{$RemoteUserID}{EmailUserID}    = $EmailUserID;
          $FormerGroupMembers{$RemoteUserID}{VERIFIED}       = 0;
    }

    print Dumper(\%FormerGroupMembers);

}

sub DocDB_VerifyIfActive() {

   # Remove EmailUser the UsersGroup if it's not in the (source) Members
   # list

   # $NewID here is the employeeNumber
   foreach my $NewID (keys %Members) {
        # Search remoteuser in FormerGroupMembers table
        # Compare employeeNumber, email forwarding address, 
        # ?? username, first name, lastname
        $FOUND = 0;

        my $NewRemoteUser     = $Members{$NewID}{RemoteUser};
        my $NewEmployeeNumber = $Members{$NewID}{MEMBERID};
        my $NewEmailForward   = $Members{$NewID}{EmailForward};
        my $NewUserName       = $Members{$NewID}{UserName};

        # $FormerID here is the RemoteUserID
        foreach my $FormerID (keys %FormerGroupMembers) {
             my $EmployeeNumber = $FormerGroupMembers{$FormerID}{EmployeeNumber};
             my $RemoteUsername = $FormerGroupMembers{$FormerID}{RemoteUsername};
             my $EmailForward   = $FormerGroupMembers{$FormerID}{EmailForward};
             my $Username       = $FormerGroupMembers{$FormerID}{UserName};
             my $InstID         = $FormerGroupMembers{$FormerID}{InstitutionID};

             if ( $RemoteUsername =~ m/\@LIGO.ORG/i &&
                  $InstID == $KAGRA_Institution ) {
                 $FormerGroupMembers{$FormerID}{VERIFIED} = 1;
             } 

             if (lc $RemoteUsername eq lc $NewRemoteUser) {
 
                 my $FirstName      = $FormerGroupMembers{$FormerID}{FirstName};
                 my $LastName       = $FormerGroupMembers{$FormerID}{LastName};
                 my $AuthorID       = $FormerGroupMembers{$FormerID}{AuthorID};
                 my $EmailUserID    = $FormerGroupMembers{$FormerID}{EmailUserID};
                 
                 if ( ($EmployeeNumber != $NewEmployeeNumber) && !($FormerGroupMembers{$FormerID}{VERIFIED})) {
                        #Fix the EmployeeNumber in the database
                     print "$NewRemoteUser : employee number $NewEmployeeNumber doesn't match with $EmployeeNumber\n";
                     my $EmployeeNumberUpdate = $docdb_handle -> prepare(
                        "UPDATE EmailUser set EmployeeNumber=? where EmailUserID =? ");
                     $EmployeeNumberUpdate ->execute($NewEmployeeNumber, $EmailUserID);
                 }

                 if ( lc $EmailForward ne lc $NewEmailForward ) {
                      #Update the EmailForward in the database
                      print "$NewRemoteUser : email forward $NewEmailForward doesn't match with $EmailForward\n";
                      my $EmailForwardUpdate = $docdb_handle -> prepare(
                            "UPDATE EmailUser set EmailAddress=? where EmailUserID =? ");
                      $EmailForwardUpdate ->execute($NewEmailForward, $EmailUserID);
                 }

                 if ( lc $Username ne lc $NewUserName ) {
                      #Send email to dcc-help that there needs to be 
                      #a name change to be done
                      print "ERROR $NewRemoteUser : username $NewUserName doesn't match with $Username\n";
                      
                      #Most likely, the names would be different also
                      #
                      # Update the database using :
                      # $Members{$uid}{FirstName}
                      # $Members{$uid}{LastName}
                      # $Members{$uid}{FULLNAME}
                      # $Members{$uid}{Formal} 

                 }
                 $Members{$NewID}{ACTIVE}       = 1;
                 $Members{$NewID}{New}          = 0;
                 $Members{$NewID}{DocDB_EmailID} = $EmailUserID;
                 $Members{$NewID}{DocDB_AuthorID}= $AuthorID;
                 $Members{$NewID}{VERIFIED} = 1;  

                 $FormerGroupMembers{$FormerID}{VERIFIED} = 1;
                 $FOUND = 1;
                 break;
            }
        }
    }
    
    print "NEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEWNEW\n";
    print Dumper(\%Members);
}



sub DocDB_RemoveUnverifiedMembers() {
    my ($GroupID) = @_;

   # Go through the FormerGroupMembers list and remove the KAGRA membership for non-verified members
   foreach my $FormerID (keys %FormerGroupMembers) {

      my $EmailUserID    = $FormerGroupMembers{$FormerID}{EmailUserID};
      my $AuthorID       = $FormerGroupMembers{$FormerID}{AuthorID};
      my $Username       = $FormerGroupMembers{$FormerID}{UserName};
      my $EmployeeNumber = $FormerGroupMembers{$FormerID}{EmployeeNumber};

      if (!($FormerGroupMembers{$FormerID}{VERIFIED})){
          print "Removing $Username from $GroupID\n";
          DocDB_RemoveMembership($EmailUserID, $GroupID);
      }
   }
}

sub DocDB_CheckIfExists() {

   # Go through the "New" accounts if they're already in the database
   foreach my $MemberID (keys %Members) {

      if ($Members{$MemberID}{NewEntry}) {
          my $RemoteUser   = $Members{$MemberID}{RemoteUser};
          my $EmailAddress = $Members{$MemberID}{EmailForward};
          my $RemoteUserID = 0;
          my $EmailUserID  = 0;

          print ROSTER_LOG "INFO:  About to check RemoteUser Table for $RemoteUser, $EmailAddress \n";

          my $query = qq(select RemoteUserID, EmailUserID from RemoteUser where EmailAddress LIKE ("$EmailAddress") and RemoteUserName LIKE ("$RemoteUser"));
          my $remoteuser_list  = $docdb_handle -> prepare($query);
          $remoteuser_list -> execute();
          $remoteuser_list -> bind_columns(undef, \($RemoteUserID, $EmailUserID));

          if ($remoteuser_list -> fetch) {
              print ROSTER_LOG "INFO: Found RemoteUser $RemoteUser : $RemoteUserID, $EmailUserID \n";
              $Members{$MemberID}{NewEntry} = 0;
              $Members{$MemberID}{DocDB_EmailID} = $EmailUserID;  
              $Members{$MemberID}{VERIFIED} = 1;  
          }
      }
}

}

sub DocDB_AddNewMemberships() {
    my ($GroupID) = @_;

   # Go through the FormerGroupMembers list and remove the KAGRA membership for non-verified members
   foreach my $MemberID (keys %Members) {

      if ($Members{$MemberID}{NewMember}) {
          my $EmailUserID  = $Members{$MemberID}{DocDB_EmailID};
          if ($EmailUserID) {
               DocDB_AddMembership ($EmailUserID, $GroupID);
          }
          else {
               print ROSTER_LOG "EmailUserID = 0 for $Members{$MemberID}{FULLNAME}\n";
               $EmailUserID = DocDB_AddEmailUser( $Members{$MemberID}{UserName},
                                                  $Members{$MemberID}{FULLNAME},
                                                  $Members{$MemberID}{EmailForward},
                                                  $Members{$MemberID}{VERIFIED}, 
                                                  $Members{$MemberID}{DocDB_AuthorID},
                                                  $Members{$MemberID}{MEMBERID} );
               $Members{$MemberID}{DocDB_EmailID} = $EmailUserID;
               DocDB_AddMembership ($EmailUserID, $GroupID);
         }
      }
   }
}


sub DocDB_AddNewAuthors() {
   require "DocDB_InstitutionSQL.pm";  
   &DocDB_GetInstitutions();

   foreach my $MemberID (keys %Members) {
       
      if ($Members{$MemberID}{NewEntry}) {

          my $FirstName = $Members{$MemberID}{FirstName};
          my $LastName  = $Members{$MemberID}{LastName};
          my $InstName  = $Members{$MemberID}{InstitutionName};
          my $InstID = DocDB_GetInstitutionIDByShortName($InstName);
         print ROSTER_LOG "AddNewAuthors for $FirstName $LastName $InstName $InstID\n";
           
          my $AuthorID = DocDB_AddAuthor2($FirstName, $LastName, $InstID, $MemberID); 

          $Members{$MemberID}{VERIFIED} = 1;  
          $Members{$MemberID}{DocDB_AuthorID} = $AuthorID;
      }

   }
}

sub DocDB_AddNewEmailUsers() {

   foreach my $MemberID (keys %Members) {
      if ($Members{$MemberID}{NewEntry}) {

          my $UserName = $Members{$MemberID}{UserName};
          my $FullName = $Members{$MemberID}{FULLNAME};
          my $EmailAddress = $Members{$MemberID}{EmailForward};
          my $AuthorID = $Members{$MemberID}{DocDB_AuthorID};  
          my $EmailUserID = DocDB_AddEmailUser($UserName, $FullName, $EmailAddress, 1, $AuthorID, $MemberID);
           
          $Members{$MemberID}{VERIFIED} = 1;  
          $Members{$MemberID}{DocDB_EmailID} = $EmailUserID;
      }
   }
}


sub DocDB_AddNewRemoteUsers() {

   foreach my $MemberID (keys %Members) {
      if ($Members{$MemberID}{NewEntry}) {

          my $RemoteUser   = $Members{$MemberID}{RemoteUser};
          my $EmailAddress = $Members{$MemberID}{EmailForward};
          my $EmailUserID  = $Members{$MemberID}{DocDB_EmailID};
          AddRemoteUserName ($EmailUserID, $RemoteUser, $EmailAddress);
           
          $Members{$MemberID}{VERIFIED} = 1;  
          
      }
   }
}


sub DocDB_AddMembership($$) {

    my ($EmailUserID, $GroupID) = @_;

    my $UserGroupID = 0;
    print ROSTER_LOG 
    "INFO: About to add Membership ($EmailUserID, $GroupID)\n";

    my $query = qq(select UsersGroupID from UsersGroup where EmailUserID = $EmailUserID and GroupID = $GroupID);
    my $usersgroup_list  = $docdb_handle -> prepare( $query );
    $usersgroup_list -> execute();
    $usersgroup_list -> bind_columns(undef, \($UsersGroupID));

    if ($usersgroup_list -> fetch) {
         print ROSTER_LOG "INFO:  Found membership in Add UsersGroup Table for $EmailUserID $GroupID\n";
    }
    else {
         print ROSTER_LOG "INFO:  About to add Group assignment $GroupID for EmailUserID  $EmailUserID\n";
         my $UsersGroupInsert = $docdb_handle -> prepare("insert into UsersGroup (EmailUserID, GroupID) values (?,?)");
         $UsersGroupInsert->execute($EmailUserID, $GroupID) or print ROSTER_LOG "ERROR:  Unable to add $EmailUsersID to group $GroupID in UserGroup Table";
    }
}

sub DocDB_UpdateUsersGroup() {
    #  Values from the SecurityGroup table
    my $LIGO_LAB = 9;
    my $LSC      = 4;
    my $LVC      = 2;
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

       
       my $new_group = $GroupID;

       if ($new_group == 0) {
           $new_group = $LVC;
       }
 
       # Check if this person is in the administrative group
       if ($PositionCode) {
          if ($PositionCode == 7 || $PositionCode == 8) {
          } else {
             $new_group = $LSC;
          }
       }

       if ($inLIGO) {
           $new_group = $LIGO_LAB;
       } elsif ($inGEO) {
           $new_group = $LSC;
       } elsif ($inVIRGO) {
           $new_group = $LVC;
       }

       #
       # Check if this user already has an entry in the UsersGroup table
       #
       my ($CalculatedGroupID);
       my $UsersGroupSelect = $docdb_handle -> prepare("select GroupID from UsersGroup where EmailUserID= ?");
       $UsersGroupSelect->execute($EmailID);
       $UsersGroupSelect -> bind_columns(undef, \($CalculatedGroupID));

       while ($UsersGroupSelect -> fetch) {
          if (!$New) {
             if ($new_group != $CalculatedGroupID) {
                print ROSTER_LOG "ACTION_NEEDED: Skipping $UserName group assignment to $new_group from $CalculatedGroupID \n";
             }
	     next;
          }
          #  Don't change  entries for docdbadm 
          if ($CalculatedGroupID == $docdbadm) {
              print ROSTER_LOG "INFO: $UserName already assigned $CalculatedGroupID skipping assignment\n";
              next; 
          }
          if ($CalculatedGroupID > $LIGO_LAB) {
             print ROSTER_LOG "INFO: $UserName already assigned $CalculatedGroupID skipping assignment\n";
             next;
          }
          #
          #  Only update if the value is different
          #
          if ($new_group > $CalculatedGroupID) {
              print ROSTER_LOG "WARNING:  Updating $UserName from $CalculatedGroupID to $new_group\n";
              my $UsersGroupUpdate = $docdb_handle -> prepare("update UsersGroup set GroupID=? where EmailUserID=? ");
              $UsersGroupUpdate->execute($new_group, $EmailID);
          }
          else {
              if ($new_group != $CalculatedGroupID) {
                  print ROSTER_LOG "ACTION_NEEDED:  Did NOT Update $UserName from $CalculatedGroupID to $new_group\n";
              }
          }
       }
       unless ($CalculatedGroupID){
          if (!$New) {
             print ROSTER_LOG "ACTION_NEEDED: Skipping $UserName group assignment to: $new_group \n";
	     next;
          }

          #
          # NEW ENTRY
          #
          DocDB_AddMembership( $EmailID, $new_group);
          
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



1;
