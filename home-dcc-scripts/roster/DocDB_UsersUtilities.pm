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
#     $DocDB_Authors{$AuthorID}{Active}
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


%DocDB_Authors = ();
%DocDB_EmailUsers = ();



sub DocDB_AddNewAuthors() {
   require "DocDB_InstitutionSQL.pm";  
   &DocDB_GetInstitutions();

   foreach my $MemberID (keys %Members) {
       
      if ($Members{$MemberID}{NewEntry}) {

          my $FirstName = $Members{$MemberID}{FirstName};
          my $LastName  = $Members{$MemberID}{LastName};
          my $InstName  = $Members{$MemberID}{InstitutionName};
          my $InstID = DocDB_GetInstitutionIDByShortName($InstName);
           
          my $AuthorID = DocDB_AddAuthor2($FirstName, $LastName, $InstID, $MemberID); 

          $Members{$MemberID}{VERIFIED} = 1;  
          $Members{$MemberID}{DocDB_AuthorID} = $AuthorID;
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

    
    my $AuthorID = 0;
    $query = qq(select AuthorID from EmailUser where EmailUserID = $EmailUserID);
    my $author_list  = $docdb_handle -> prepare( $query );
    $author_list -> execute();
    $author_list -> bind_columns(undef, \($AuthorID));

    if ($author_list -> fetch) {
    	my $AuthorUpdate = $docdb_handle -> prepare("UPDATE Author SET Active=1 where AuthorID=? ");
    	$AuthorUpdate->execute($AuthorID);
    }
}



sub DocDB_RemoveMembership($$) {

    my ($EmailUserID, $GroupID) = @_;

    my $UserGroupID = 0;
    print ROSTER_LOG "INFO: About to remove Membership ($EmailUserID, $GroupID)\n";

    my $UsersGroupDelete = $docdb_handle -> prepare("DELETE from UsersGroup where GroupID=? and EmailUserID=?");

    $UsersGroupDelete->execute($GroupID, $EmailUserID) or print ROSTER_LOG "INFO:  Unable to delete $EmailUsersID to group $GroupID in UserGroup Table\n";

    my $query = qq(select UsersGroupID from UsersGroup where EmailUserID = $EmailUserID );
    my $usersgroup_list  = $docdb_handle -> prepare( $query );
    $usersgroup_list -> execute();
    $usersgroup_list -> bind_columns(undef, \($UsersGroupID));

    my $AuthorID = 0;
    if ($usersgroup_list -> fetch) {

        # Just make sure the Author is active  if there's at least 1 membership
        $query = qq(select AuthorID from EmailUser where EmailUserID = $EmailUserID);
        my $author_list  = $docdb_handle -> prepare( $query );
        $author_list -> execute();
        $author_list -> bind_columns(undef, \($AuthorID));

        my $ActiveAuthor = 0;
        if ($author_list -> fetch) {
             my $active_query = $docdb_handle -> prepare("SELECT Active from Author where AuthorID=?");
             $active_query -> execute();
             $active_query -> bind_columns(undef, \($ActiveAuthor));

             if ($active_query -> fetch) {

                 if ($ActiveAuthor == 0) {
       	             my $AuthorUpdate = $docdb_handle -> prepare("UPDATE Author SET Active=1 where AuthorID=? ");
    	             $AuthorUpdate->execute($AuthorID);
                 }
             } 
        }
    }
    else {

         print ROSTER_LOG "INFO:  Found NO memberships in UsersGroup Table for $EmailUserID\n";

        $query = qq(select AuthorID from EmailUser where EmailUserID = $EmailUserID);
        my $author_list  = $docdb_handle -> prepare( $query );
        $author_list -> execute();
        $author_list -> bind_columns(undef, \($AuthorID));

        if ($author_list -> fetch) {
       	    my $AuthorUpdate = $docdb_handle -> prepare("UPDATE Author SET Active=0 where AuthorID=? ");
    	    $AuthorUpdate->execute($AuthorID);
         }

    }
}



sub DocDB_FetchAuthorByID($)  {
    my ($AuthorID) = @_;

    my ($FirstName, $LastName, $InstID, $Active);
    my $author_list  = $docdb_handle -> prepare(
        "select FirstName, LastName, InstitutionID, Active from Author where AuthorID = ?");

    $author_list -> execute($AuthorID) or print ROSTER_LOG "MYSQL ERROR1: $DBI::errstr\n";
     
    $author_list -> bind_columns(undef, \($FirstName, $LastName, $InstID, $Active));
    if ($author_list -> fetch) {
        if ($InstID) {
            $DocDB_Authors{$AuthorID}{AUTHORID} = $AuthorID;
            $DocDB_Authors{$AuthorID}{LastName} = $LastName;
            $DocDB_Authors{$AuthorID}{FirstName} = $FirstName;
            $DocDB_Authors{$AuthorID}{InstitutionID} = $InstID;
            $DocDB_Authors{$AuthorID}{Active} = $Active;
        }
    }
    else {
        $AuthorID = ();
    } 

     return $AuthorID;
}

sub DocDB_FetchAuthorByName($$) {
    my ($FirstName, $LastName) = @_;

    my ($AuthorID, $InstID, $Active);
    my $author_list  = $docdb_handle -> prepare(
        "select AuthorID, InstitutionID, Active from Author where LastName = ? and FirstName = ?");

    $author_list -> execute($LastName, $FirstName) or print ROSTER_LOG "MYSQL ERROR2: $DBI::errstr\n";
     
    $author_list -> bind_columns(undef, \($AuthorID,$InstID,$Active));
    if ($author_list -> fetch) {
        if ($AuthorID && $InstID) {
            $DocDB_Authors{$AuthorID}{AUTHORID} = $AuthorID;
            $DocDB_Authors{$AuthorID}{LastName} = $LastName;
            $DocDB_Authors{$AuthorID}{FirstName} = $FirstName;
            $DocDB_Authors{$AuthorID}{InstitutionID} = $InstID;
            $DocDB_Authors{$AuthorID}{Active} = $Active;
        }
     }

     return $AuthorID;
}

#  Gets the Author ID based on the name and institution
sub DocDB_GetAuthorID($$$) {  
  my ($FirstName, $LastName, $InstID) = @_;

  my ($AuthorID);
  my $author_select = $docdb_handle -> prepare(
     "select AuthorID from Author where FirstName LIKE ? AND LastName LIKE ?"); 
  $author_select -> execute($FirstName, $LastName);
#     "select AuthorID from Author where FirstName LIKE ? AND LastName LIKE ? AND InstitutionID=?"); 
#  $author_select -> execute($FirstName, $LastName, $InstID);
  ($AuthorID) = $author_select-> fetchrow_array;

  return $AuthorID;
}


#  Gets the Author ID based on the username
sub DocDB_GetAuthorIDFromUserName($) {  
  my ($UserName) = @_;

  my $query = qq(select AuthorID from EmailUser where Username LIKE ("$UserName"));
  my ($AuthorID);
  my $author_select = $docdb_handle -> prepare($query);
  $author_select -> execute();
  $author_select -> bind_columns(undef, \($AuthorID));
  unless ($author_select-> fetch) {
      print ROSTER_LOG "ACTION_NEEDED: No AuthorID for $UserName in the EmailUser table\n";
  }

  return $AuthorID;
}

#  Gets the Author ID based on the username
sub DocDB_GetAuthorIDFromEmployeeNumber($) {  
  my ($EmployeeNumber) = @_;

  my $query = qq(select AuthorID from EmailUser where EmployeeNumber = $EmployeeNumber);
  my ($AuthorID);
  my $author_select = $docdb_handle -> prepare($query);
  $author_select -> execute();
  $author_select -> bind_columns(undef, \($AuthorID));
  unless ($author_select-> fetch) {
      print ROSTER_LOG "ACTION_NEEDED: No AuthorID for EmployeeNumber $EmployeeNumber in the EmailUser table\n";
  }

  return $AuthorID;
}

sub DocDB_FetchEmailUserByID($)  {
    my ($EmailUserID) = @_;

    my ($AuthorID, $UserName, $FullName);
    my $emailuser_list = $docdb_handle -> prepare(
        "select AuthorID, Username, Name from EmailUser where EmailUserID = ?");

    $emailuser_list -> execute($EmailUserID) or print ROSTER_LOG "MYSQL ERROR5: $DBI::errstr\n";
     
    $emailuser_list -> bind_columns(undef, \($AuthorID, $UserName, $FullName));
    if ($emailuser_list-> fetch) {
        $DocDB_EmailUsers{$EmailUserID}{EMAILUSERID} = $EmailUserID;
        $DocDB_EmailUsers{$EmailUserID}{AuthorID}    = $AuthorID;
        $DocDB_EmailUsers{$EmailUserID}{UserName}    = $UserName;
        $DocDB_EmailUsers{$EmailUserID}{FullName}    = $FullName;
    } else  {
        $DocDB_EmailUsers{$EmailUserID}{EMAILUSERID} = 0;
    }

}

sub AddRemoteUserName($$$) {
    my ($EmailUserID, $RemoteUserName, $EmailAddress) = @_;

    my $RemoteUserID = 0;
 
    print ROSTER_LOG "INFO:  About to add RemoteUser Table for $RemoteUserName, $EmailAddress : $EmailUserID\n";

    my $query = qq(select RemoteUserID from RemoteUser where EmailUserID=$EmailUserID and RemoteUserName LIKE ("$RemoteUserName") AND  EmailAddress LIKE ("$EmailAddress"));
    my $remoteuser_list  = $docdb_handle -> prepare( $query);
    $remoteuser_list -> execute();
    $remoteuser_list -> bind_columns(undef, \($RemoteUserID));

    if ($remoteuser_list -> fetch) {
        print ROSTER_LOG "INFO: Successfully found RemoteUser $RemoteUserName : $RemoteUserID \n";
        $Members{$MemberID}{NewEntry} = 0; 
    }
    else {
        my $remoteuser_add = $docdb_handle -> prepare("insert into RemoteUser (EmailUserID, RemoteUserName, EmailAddress) values ( ? , ? , ?)");
        $remoteuser_add ->execute($EmailUserID, $RemoteUserName, $EmailAddress) or print ROSTER_LOG "ERROR:  Unable to add $EmailUserID, $RemoteUserName in RemoteUser Table\n";
          
        # Find the RemoteUserID
        $query =qq(select RemoteUserID from RemoteUser where EmailUserID = $EmailUserID and RemoteUserName LIKE ("$RemoteUserName"));
        $remoteuser_list  = $docdb_handle -> prepare($query);
        $remoteuser_list -> execute(); 
        $remoteuser_list -> bind_columns(undef, \($RemoteUserID));
        $remoteuser_list -> fetch;
        print ROSTER_LOG "INFO: Successfully added RemoteUser $EmailAddress, $RemoteUserName : $RemoteUserID \n";
    }

    return $RemoteUserID;
}



sub DocDB_AddAuthor2($$$$) {
    my ($FirstName, $LastName, $Institution, $MemberID) = @_;

    my $AuthorID = 0;

    print ROSTER_LOG "INFO:  About to add 2  Author Table for $FirstName $LastName : $Institution, $MemberID\n";

    my $query = qq(select AuthorID from Author where FirstName LIKE ("$FirstName") AND LastName LIKE ("$LastName") AND InstitutionID = $Institution);
    my $author_list  = $docdb_handle -> prepare( $query );
    $author_list -> execute();
    $author_list -> bind_columns(undef, \($AuthorID));

    if ($author_list -> fetch) {
        print ROSTER_LOG "INFO:  Successfully found in Author Table for $FirstName $LastName from $Institution\n";
        $Members{$MemberID}{NewEntry} = 0; 
    }
    else {
         $AuthorID = DocDB_AddAuthor($FirstName, $LastName, $Institution);
    }

    return $AuthorID;
}


sub DocDB_AddAuthor($$$) {
    my ($FirstName, $LastName, $Institution) = @_;

    if ($Institution == NULL) {
        $Institution = 114;
    }
    print ROSTER_LOG "INFO:  About to add Author Table for $FirstName $LastName : $Institution\n";

    my $query = ();
    my ($AuthorID );
    my $author_list  = $docdb_handle -> prepare( "select AuthorID from Author where FirstName=? AND LastName=? AND InstitutionID=?");

    $author_list -> execute($FirstName, $LastName, $Institution);
    $author_list -> bind_columns(undef, \($AuthorID));

    if ($author_list -> fetch) {
        print ROSTER_LOG "INFO:  Successfully found in Author Table for $FirstName $LastName from $Institution\n";
    }
    else {

        $AuthorID = DocDB_FetchAuthorByName($FirstName, $LastName);
 
        if ($AuthorID) {
             # Author with First, Last name exists but has the wrong institution
            my $success = 1;

            $AuthorActive = $DocDB_Authors{$AuthorID}{Active};
            if (AuthorActive) {
                    print ROSTER_LOG "INFO:  Found but did not update institution $Institution in Author Table for $FirstName $LastName\n";
            }
            else {
                 my $author_update = $docdb_handle -> prepare("update Author set InstitutionID=? where FirstName=? and  LastName=? "); 
                $author_update -> execute ($Institution, $FirstName, $LastName) or $success = 0;

                if ($success) { 
                    print ROSTER_LOG "INFO:  Successfully updated institution $Institution in Author Table for $FirstName $LastName\n";
                }
            }

        }
        else {
            my $author_insert = $docdb_handle -> prepare("insert into Author (FirstName, LastName, InstitutionID) values ( ?, ?, ?)");
            my $success = 1;
            $author_insert -> execute ($FirstName, $LastName, $Institution) or $success = 0;

            if ($success) { 
                my $author_id = $docdb_handle ->{'mysql_insertid'};
                if ($author_id) {
                    $AuthorID = $author_id;
                    $DocDB_Authors{$AuthorID}{AUTHORID} = $author_id;
                    $DocDB_Authors{$AuthorID}{LastName} = $LastName;
                    $DocDB_Authors{$AuthorID}{FirstName} = $FirstName;
                    $DocDB_Authors{$AuthorID}{InstitutionID} = $Institution;
                    print ROSTER_LOG "INFO:  Successfully adding to Author Table for $FirstName $LastName : $Institution\n";
                }
                else {
                   print ROSTER_LOG "ERROR: Unable to find the author_id for Author($FirstName, $LastName, $Institution) \n";
                }
            } else {
                 print ROSTER_LOG "ERROR:  Unable to add $FirstName $LastName in Author Table\n";
            }
        }
              
    }
    return $AuthorID;
}

sub DocDB_AddEmailUser($$$$$$) {

    my ($UserName, $FullName, $EmailAddress, $VERIFIED, $AuthorID, $MemberID) = @_;

    my $EmailUserID = 0;

    print ROSTER_LOG 
    "INFO: About to add EmailUser ($UserName, $FullName, $EmailAddress, $VERIFIED, $AuthorID, $MemberID) \n";

    my $query = qq(select EmailUserID from EmailUser where EmailAddress LIKE ("$EmailAddress") );
    my $user_list  = $docdb_handle -> prepare( $query );
    $user_list -> execute();
    $user_list -> bind_columns(undef, \($EmailUserID));

    if ($user_list -> fetch) {
         print ROSTER_LOG "INFO:  Successfully found $UserName in EmailUser Table : $EmailAddress, $EmailUserID\n";
         $Members{$MemberID}{DocDB_EmailID} = $EmailUserID;
         $Members{$MemberID}{NewEntry} = 0;
    }
    else {

    my $query = qq(insert into EmailUser (Username, Name, EmailAddress, Verified, AuthorID, EmployeeNumber) values (\"$UserName\", \"$FullName\", \"$EmailAddress\", $VERIFIED, $AuthorID, $MemberID)); 
    my $email_insert = $docdb_handle -> prepare($query);
    my $success = 1;
    
    $email_insert -> execute () or $success = 0;
              
     if ($success) {
          my $email_id = $docdb_handle -> {'mysql_insertid'};
          if ($email_id) {
               $EmailUserID = $email_id;
               $DocDB_EmailUsers{$EmailUserID}{EMAILUSERID} = $email_id;
               $DocDB_EmailUsers{$EmailUserID}{AuthorID} = $AuthorID;
               $DocDB_EmailUsers{$EmailUserID}{FullName} = $FullName;
               $DocDB_EmailUsers{$EmailUserID}{UserName} = $UserName;
               $DocDB_EmailUsers{$EmailUserID}{Verified} = 1;
               $DocDB_EmailUsers{$EmailUserID}{EmployeeNumber} = $MemberID;

               $Members{$MemberID}{DocDB_EmailID} = $email_id;
               print ROSTER_LOG "INFO:  Successfully adding to EmailUser Table for $Username: $MemberID = $EmailUserID\n";
           } else {
               print ROSTER_LOG 
               "ERROR: Unable to find the email_id for EmailUser ($UserName, $FullName, $EmailAddress, $AuthorID, $MemberID) \n";
          }
     } else {
        print ROSTER_LOG 
        "ERROR: Unable to add to EmailUser ($UserName, $FullName, $EmailAddress, $AuthorID, $MemberID) \n";
    }
    }
   
     return $EmailUserID;
}

1;
