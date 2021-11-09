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

sub ClearSecurityGroups {
  $HaveAllSecurityGroups = 0;
  %SecurityGroups = ();
  %GroupsHierarchy = ();
}

sub GetSecurityGroups { # Creates/fills a hash $SecurityGroups{$GroupID}{} with all authors
  if ($HaveAllSecurityGroups) {
    return;
  }
   
  push @DebugStack,"Getting all security groups";
  
  my ($GroupID,$Name,$Description,$CanCreate,$CanAdminister,$CanView,$CanConfig,$TimeStamp,$DisplayInList);
  my $GroupList  = $dbh -> prepare(
     "select GroupID,Name,Description,CanCreate,CanAdminister,CanView,CanConfig,TimeStamp,DisplayInList from SecurityGroup"); 
  $GroupList -> execute;
  $GroupList -> bind_columns(undef, \($GroupID,$Name,$Description,$CanCreate,$CanAdminister,$CanView,$CanConfig,$TimeStamp,$DisplayInList));
  %SecurityGroups = ();
  while ($GroupList -> fetch) {
    $SecurityGroups{$GroupID}{NAME}          = $Name;
    $SecurityGroups{$GroupID}{Description}   = $Description;
    $SecurityGroups{$GroupID}{CanAdminister} = $CanAdminister;
    $SecurityGroups{$GroupID}{CanConfig}     = $CanConfig;
    $SecurityGroups{$GroupID}{CanCreate}     = $CanCreate;
    $SecurityGroups{$GroupID}{CanView}       = $CanView;
    $SecurityGroups{$GroupID}{TimeStamp}     = $TimeStamp;
    $SecurityGroups{$GroupID}{DisplayInList} = $DisplayInList;
    $SecurityIDs{$Name} = $GroupID;
  }
  
  my ($HierarchyID,$ChildID,$ParentID);
  my $HierarchyList  = $dbh -> prepare(
     "select HierarchyID,ChildID,ParentID,TimeStamp from GroupHierarchy"); 
  $HierarchyList -> execute;
  $HierarchyList -> bind_columns(undef, \($HierarchyID,$ChildID,$ParentID,$TimeStamp));
  %GroupsHierarchy = ();
  while ($HierarchyList -> fetch) {
    $GroupsHierarchy{$HierarchyID}{Child}     = $ChildID;
    $GroupsHierarchy{$HierarchyID}{Parent}    = $ParentID;
    $GroupsHierarchy{$HierarchyID}{TimeStamp} = $TimeStamp;
  }
  
  $HaveAllSecurityGroups = 1;
}

sub FetchSecurityGroup ($) {
  my ($GroupID) = @_;
  my ($Name,$Description,$CanCreate,$CanAdminister,$TimeStamp,$DisplayInList);
  my $GroupList  = $dbh -> prepare(
     "select Name,Description,CanCreate,CanAdminister,CanView,CanConfig,TimeStamp,DisplayInList from SecurityGroup where GroupID=?"); 
  
  if ($SecurityGroups{$GroupID}{TimeStamp}) { 
    return;
  }
    
  $GroupList -> execute($GroupID);
  $GroupList -> bind_columns(undef, \($Name,$Description,$CanCreate,$CanAdminister,$CanView,$CanConfig,$TimeStamp,$DisplayInList));
  while ($GroupList -> fetch) {
    $SecurityGroups{$GroupID}{NAME}          = $Name;
    $SecurityGroups{$GroupID}{Description}   = $Description;
    $SecurityGroups{$GroupID}{CanAdminister} = $CanAdminister;
    $SecurityGroups{$GroupID}{CanConfig}     = $CanConfig;
    $SecurityGroups{$GroupID}{CanCreate}     = $CanCreate;
    $SecurityGroups{$GroupID}{CanView}       = $CanView;
    $SecurityGroups{$GroupID}{TimeStamp}     = $TimeStamp;
    $SecurityGroups{$GroupID}{DisplayInList} = $DisplayInList;
    $SecurityIDs{$Name} = $GroupID;
  }
  
  my ($HierarchyID,$ChildID,$ParentID);
  my $HierarchyList  = $dbh -> prepare(
     "select HierarchyID,ChildID,ParentID,TimeStamp from GroupHierarchy where ParentID=? or ChildID=?"); 
  $HierarchyList -> execute($GroupID,$GroupID);
  $HierarchyList -> bind_columns(undef, \($HierarchyID,$ChildID,$ParentID,$TimeStamp));
  while ($HierarchyList -> fetch) {
    $GroupsHierarchy{$HierarchyID}{Child}     = $ChildID;
    $GroupsHierarchy{$HierarchyID}{Parent}    = $ParentID;
    $GroupsHierarchy{$HierarchyID}{TimeStamp} = $TimeStamp;
 }

}

sub isSecurityGroupInHierarchy {
  my ($GroupID) = @_;

  my ($ChildID, $ParentID);
  my ($HierarchyID);
  my $HierarchyList  = $dbh -> prepare(
     "select HierarchyID, ChildID, ParentID from GroupHierarchy where ParentID=? or ChildID=?"); 
  $HierarchyList -> execute($GroupID, $GroupID);
  $HierarchyList -> bind_columns(undef, \($HierarchyID, $ChildID, $ParentID));

  if ($HierarchyList -> fetch) {
     &FetchSecurityGroup ($ChildID);
     if ($SecurityGroups{$ChildID}{DisplayInList} == 2) { return 0; } 
     return 1;
  } else {
     return 0;
  }

}


sub GetRevisionSecurityGroups {
  my ($DocRevID) = @_;
  
  if ($RevisionSecurities{$DocRevID}{DocRevID}) {
    return @{$RevisionSecurities{$DocRevID}{GROUPS}};
  }
    
  my @groups = ();
  my ($RevSecurityID,$GroupID);
  my $GroupList = $dbh->prepare(
    "select RevSecurityID,GroupID from RevisionSecurity where DocRevID=?");
  $GroupList -> execute($DocRevID);
  $GroupList -> bind_columns(undef, \($RevSecurityID,$GroupID));
  while ($GroupList -> fetch) {
    push @groups,$GroupID;
  }
  $RevisionSecurities{$DocRevID}{DocRevID} = $DocRevID;
  $RevisionSecurities{$DocRevID}{GROUPS}   = [@groups];
  return @{$RevisionSecurities{$DocRevID}{GROUPS}};
}

sub GetRevisionModifyGroups {
  my ($DocRevID) = @_;
  
  if ($RevisionModifies{$DocRevID}{DocRevID}) {
    return @{$RevisionModifies{$DocRevID}{GROUPS}};
  }
    
  my @groups = ();
  my ($RevModifyID,$GroupID);
  my $GroupList = $dbh->prepare(
    "select RevModifyID,GroupID from RevisionModify where DocRevID=?");
  $GroupList -> execute($DocRevID);
  $GroupList -> bind_columns(undef, \($RevModifyID,$GroupID));
  while ($GroupList -> fetch) {
    push @groups,$GroupID;
  }
  $RevisionModifies{$DocRevID}{DocRevID} = $DocRevID;
  $RevisionModifies{$DocRevID}{GROUPS}   = [@groups];
  return @{$RevisionModifies{$DocRevID}{GROUPS}};
}

sub SecurityLookup {
  my ($User) = @_;
  
  my $GroupName = $dbh->prepare("select Name from SecurityGroup where lower(Name) like lower(?)");
  $GroupName -> execute($User);

  my ($Name) = $GroupName -> fetchrow_array; 
  
  return $Name;
}

sub FetchEmailUserIDFromEmailAddress($) {
  my ($EmailAddress) = @_;

  my $query = qq( select EmailUserID from EmailUser where EmailAddress like ("$EmailAddress"));

  my $UserFetch =  $dbh->prepare($query);
  $UserFetch -> execute();
  my ($EmailUserID) = $UserFetch -> fetchrow_array;

  return $EmailUserID;
}

sub FetchEmailUserIDFromRemoteUser() {
  require "Utilities.pm";
  our $GLOBAL_EMAILUSER;

  my $RemoteUser = &remote_user || &authnz_remote_user;
  my $EmailUserID = $GLOBAL_EMAILUSER || 0;

  if (defined $RemoteUser && length $RemoteUser > 0) {
     my $query = qq( select EmailUserID from RemoteUser where RemoteUserName like ("$RemoteUser"));

     my $UserFetch =  $dbh->prepare($query);
     $UserFetch -> execute();
     $EmailUserID = $UserFetch -> fetchrow_array;
  }

  return $EmailUserID;
}


sub FetchEmailUserIDFromRemoteUserName($) {
  require "Utilities.pm";
  my ($RemoteUser) =  @_;

  my $query = qq( select EmailUserID from RemoteUser where RemoteUserName like ("$RemoteUser"));

  my $UserFetch =  $dbh->prepare($query);
  $UserFetch -> execute();
  my ($EmailUserID) = $UserFetch -> fetchrow_array;

  return $EmailUserID;
}


sub FetchAuthorIDFromEmailUserID($) {
  my ($EmailUserID) = @_;

  my $AuthorIDFetch=  $dbh->prepare("select AuthorID from EmailUser where EmailUserID=? ");
  $AuthorIDFetch -> execute($EmailUserID);
  my ($AuthorID) = $AuthorIDFetch -> fetchrow_array;

  return $AuthorID;
}

sub FetchEmailUserIDFromAuthorID($) {
  my ($AuthorID) = @_;

  my $EmailUserFetch =  $dbh->prepare("select EmailUserID from EmailUser where AuthorID=? ");
  $EmailUserFetch -> execute($AuthorID);
  my ($EmailUserID) = $EmailUserFetch -> fetchrow_array;

  return $EmailUserID;
}

sub FetchEmployeeNumberFromAuthorID($) {
  my ($AuthorID) = @_;

  my $EmployeeNumberFetch =  $dbh->prepare("select EmployeeNumber from EmailUser where AuthorID=? ");
  $EmployeeNumberFetch -> execute($AuthorID);
  my ($EmployeeNumber) = $EmployeeNumberFetch -> fetchrow_array;

  return $EmployeeNumber;
}

sub FetchNameFromEmployeeNumber($) {
  my ($EmployeeNumber) = @_;

  my $NameFetch =  $dbh->prepare("select Name from EmailUser where EmployeeNumber=? ");
  $NameFetch -> execute($EmployeeNumber);
  my ($Name) = $NameFetch -> fetchrow_array;

  return $Name;
}


sub isEmailUserAnAuthor($$) {
  my ($EmailUserID, $DocRevID) = @_;
  

  my ($AuthorID) = FetchAuthorIDFromEmailUserID($EmailUserID);
  
  if ($AuthorID) {
      my $DocRevFetch =  $dbh->prepare("select AuthorID from RevisionAuthor where DocRevID=? ");
      $DocRevFetch -> execute($DocRevID);
      my ($author);
      $DocRevFetch -> bind_columns(undef, \($author));
      while ($DocRevFetch -> fetch) {
         if ($author == $AuthorID) {
            return 1;
         }
      }

      # Now check if the Author is in the AuthorGroup

      $DocRevFetch =  $dbh->prepare("select AuthorGroupList.AuthorID ".
          "from RevisionAuthorGroup, AuthorGroupList, DocumentRevision ".
          "where RevisionAuthorGroup.DocRevID=? and DocumentRevision.DocRevID=? ".
          "and AuthorGroupList.AuthorID = ?".
          "and AuthorGroupList.AuthorGroupID = RevisionAuthorGroup.AuthorGroupID");
      $DocRevFetch -> execute($DocRevID, $DocRevID, $AuthorID);
      my ($authorgroupid);
      $DocRevFetch -> bind_columns(undef, \($authorgroupid));
      if ($DocRevFetch -> fetch) {
            return 1;
      }
  }
  
  return 0;
}

sub FetchSecurityGroupByName ($) {
  my ($Name) = @_;
  if ($SecurityIDs{$Name}) {
    return $SecurityIDs{$Name};
  }  

  my $GroupSelect = $dbh->prepare("select GroupID from SecurityGroup where lower(Name) like lower(?)");

  $GroupSelect -> execute($Name);

  my ($GroupID) = $GroupSelect -> fetchrow_array;
  if ($GroupID) {
    &FetchSecurityGroup($GroupID);
    $SecurityIDs{$Name} = $GroupID; # Case may not match with other one
  } else {
    return 0;
  }  
  return $GroupID;
}   

sub FetchUserGroupIDs ($) {
  my ($EmailUserID) = @_;

  my @UserGroupIDs = ();
  my $UserGroupID;
  
  if ($EmailUserID) {
    my $GroupList = $dbh->prepare("select GroupID from UsersGroup where EmailUserID=?");
    $GroupList -> execute($EmailUserID);
    $GroupList -> bind_columns(undef, \($UserGroupID));
    while ($GroupList -> fetch) {
      push @UserGroupIDs,$UserGroupID;
    }
  }
  
  return @UserGroupIDs;
}
  
sub FetchEmailUserIDsBySecurityGroup ($;$) {
  require "Utilities.pm";

  my ($GroupID, $DocRevID) = @_;

  my @EmailUserIDs = ();
  my $EmailUserID;
  
  if ($GroupID) {
    if ($GroupID == &FetchSecurityGroupByName($AuthorsOnly_Group)) {
        if (defined $DocRevID) {
            my $List = $dbh -> prepare("select AuthorID from RevisionAuthor where DocRevID=?");
            $List -> execute($DocRevID);
            my $AuthorID;
            $List -> bind_columns(undef, \($AuthorID));
            while ($List -> fetch) {
                my $EmailUserID = FetchEmailUserIDFromAuthorID($AuthorID);
                push @EmailUserIDs,$EmailUserID;
            }
        }
    } else {
        my $List = $dbh -> prepare("select EmailUserID from UsersGroup where GroupID=?");
        $List -> execute($GroupID);
        $List -> bind_columns(undef, \($EmailUserID));
        while ($List -> fetch) {
          push @EmailUserIDs,$EmailUserID;
        }
    }
  }
  @EmailUserIDs = &Unique(@EmailUserIDs);
  return @EmailUserIDs;
}
  
sub InsertSecurity (%) {
  my %Params = @_;
  
  my $DocRevID  =   $Params{-docrevid}  || "";   
  my @ViewIDs   = @{$Params{-viewids}};
  @ViewIDs      = &Unique(@ViewIDs);
  my @ModifyIDs = @{$Params{-modifyids}};
  @ModifyIDs       = &Unique(@ModifyIDs);

  my $Count = 0;

  my $ViewInsert   = $dbh->prepare("insert into RevisionSecurity (RevSecurityID, DocRevID, GroupID) values (0,?,?)");
  my $ModifyInsert = $dbh->prepare("insert into RevisionModify   (RevModifyID,   DocRevID, GroupID) values (0,?,?)");
               
  unless ($DocRevID) {
    return $Count;
  }         
	                         
  foreach my $ViewID (@ViewIDs) {
    if ($ViewID) {
      $ViewInsert -> execute($DocRevID,$ViewID);
      ++$Count;
    }
  }  
      
  foreach my $ModifyID (@ModifyIDs) {
    if ($ModifyID && $EnhancedSecurity) {
      $ModifyInsert -> execute($DocRevID,$ModifyID);
      ++$Count;
    }
  }  
      
  return $Count;
}

sub UpdateRevisionPublicSecurity ($$$) {
  require "FSUtilities.pm";
  require "RevisionSQL.pm";

  my ($DocumentID, $Version, $QAcheck) = @_;
  my $DocRevID = FetchRevisionByDocumentAndVersion($DocumentID, $Version);

  my $Interim_Public_Group = FetchSecurityGroupByName($Public_Group);

  my ($RevSecurityID,$GroupID);

  # If QAcheck is set then remove all RevisionSecurity settings for this revision
  # to make it public.
 
  if ($QAcheck != 0) { 
      my $Remove_All = 0;
      my $GroupList = $dbh->prepare(
          "select RevSecurityID,GroupID from RevisionSecurity where DocRevID=?");

      $GroupList -> execute($DocRevID);

      $GroupList -> bind_columns(undef, \($RevSecurityID,$GroupID));

      while ($GroupList -> fetch) {
          if ($GroupID == $Interim_Public_Group) {
              $Remove_All = 1;
          }
      }

      if ($Remove_All) {
          $RevisionSecurityDelete = $dbh -> prepare(
              "delete from RevisionSecurity where DocRevID = ?");
          $RevisionSecurityDelete ->execute($DocRevID);
          MakeLinkDirectory($DocumentID, $Version);
      }
  } else {
      my $GroupList = $dbh->prepare(
          "select RevSecurityID,GroupID from RevisionSecurity where DocRevID=?");

      $GroupList -> execute($DocRevID);

      $GroupList -> bind_columns(undef, \($RevSecurityID,$GroupID));

      unless ($GroupList -> fetch) {
         my $insert_row = $dbh -> prepare (
            "insert into RevisionSecurity (GroupID, DocRevID) values (?, ?)");
         $insert_row -> execute ($Interim_Public_Group, $DocRevID) or
            warn "UpdateRevisionPublicSecurity: Couldn't execute statement: ".
            $insert_row->errstr;
      }
      UnlinkDirectory($DocumentID, $Version);
  }
}



sub isActiveUser($){
  my ($EmailUserID) = @_;
  
# GetSecurityGroups();
# # my @UsersGroupIDs = (); # @UsersGroupIDs = FetchUserGroupIDs($EmailUserID); 
  my $Active = 0;

  my $ActiveQuery = $dbh->prepare(
     "select Active from Author JOIN EmailUser ON EmailUser.AuthorID = Author.AuthorID WHERE EmailUser.EmailUserID=?");
  $ActiveQuery -> execute($EmailUserID);

  $ActiveQuery -> bind_columns(undef, \($Active));
  
  unless ($ActiveQuery -> fetch) {
     return 0;
  }


  return $Active;
}

1;
