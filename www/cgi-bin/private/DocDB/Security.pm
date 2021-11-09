#
#        Name: $RCSfile: Security.pm,v $
# Description: Routines to determine various levels of access to documents
#              and the database based on usernames, doc numbers, etc.
#
#    Revision: $Revision: 1.31.4.8 $
#    Modified: $Author: vondo $ on $Date: 2007/09/20 19:53:14 $
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

sub CanAccessRevision ($;$) { # Can the user access (with current security) this version
  my ($DocRevID,$EmailUserID) = @_;
  require "RevisionSQL.pm";

  FetchDocRevisionByID ($DocRevID);
  my $Version =  $DocRevisions{$DocRevID}{Version};
  my $DocID   =  $DocRevisions{$DocRevID}{DOCID};
  return CanAccess($DocID, $Version, $EmailUserID);
}


sub CanAccess ($;$$) { # Can the user access (with current security) this version
  my ($DocumentID,$Version,$EmailUserID) = @_;

  require "RevisionSQL.pm";
  require "SecuritySQL.pm";
  require "AuthorSQL.pm";

## FIXME: Allow -docrevid, or -docid and -version, same for other routines

  GetSecurityGroups();

#  open (DEBUG, ">>/tmp/debug");
  #print DEBUG "CanAccess $DocumentID, $Version, $EmailUserID\n"; 
  unless ($EmailUserID) {
     $EmailUserID = FetchEmailUserIDFromRemoteUser();
  }

  my $DocRevID = FetchRevisionByDocumentAndVersion($DocumentID,$Version);

#  
# MCA: Check if the Submitter is trying to access the document
#
  FetchDocRevisionByID($DocRevID);

  my $SubmitterID = $DocRevisions{$DocRevID}{Submitter};
  my $AuthorID = FetchAuthorIDFromEmailUserID($EmailUserID);


  FetchAuthor($AuthorID);
  my $Active = $Authors{$AuthorID}{ACTIVE};

  #print DEBUG "$AuthorID Active = $Active\n";
  if ( $Active == 0  && !$Public) {
       #print DEBUG "Author $AuthorID no longer active\n";
       return 0;
  }

  if ($SubmitterID == 0 && !$Public) {
    #print DEBUG " if ($SubmitterID == 0) \n";
    return 0;
  }
  if ($Documents{$DocumentID}{Requester} == 0 && !$Public) {
    #print DEBUG "if ($Documents{$DocumentID}{Requester})\n"; 
    return 0;
  }
      
  if ($SubmitterID == $AuthorID) {
     #print DEBUG "if ($SubmitterID == $AuthorID)\n"; 
     return 1;
  }
  if ($Documents{$DocumentID}{Requester} == $AuthorID ) {
     #print DEBUG "if $Documents{$DocumentID}{Requester} == $AuthorID )\n"; 
    return 1;
  }

  unless ($DocRevID) { # Document doesn't exist
     #print DEBUG "unless ($DocRevID) \n";
    return 0;
  }
  if ($Documents{$DocumentID}{NVersions} eq "") { # Bad documents (no revisions)
    #print  DEBUG "if ($Documents{$DocumentID}{NVersions} eq \"\")\n"; 
    return 0;
  }

  my @GroupIDs = GetRevisionSecurityGroups($DocRevID);
  unless (@GroupIDs) {
     #print  DEBUG "unless (@GroupIDs)\n"; 
     return 1;             # Public documents
  }

# See if the access group is "Authorship"
  if (isAuthorshipAccess(@GroupIDs)) {

      if (isEmailUserAnAuthor($EmailUserID, $DocRevID)) { 
          return 1; 
      }
  }
  
  if (CanAdminister($EmailUserID)) {
      #print DEBUG "CanAdminister\n"; 
      return 1;
  }

# See what group(s) current (or assumed) user belongs to

  my @UsersGroupIDs = ();

  if ($EmailUserID) {
    @UsersGroupIDs = FetchUserGroupIDs($EmailUserID);
  } else {
    @UsersGroupIDs = FetchUserGroupIDs($GLOBAL_EMAILUSER);
  }


      #print DEBUG "UserGroupIDs @UsersGroupIDs\n"; 

# See if current user is in the list of groups who can access this document

  my $access = 0;
  foreach my $UserGroupID (@UsersGroupIDs) {
    unless ($SecurityGroups{$UserGroupID}{CanView}) {
      next;
    }

    foreach my $GroupID (@GroupIDs) {
      if ($UserGroupID == $GroupID) {
        $access = 1;                           # User checks out
        last;
      }
    }
  }
  if ($access) {
     return $access;
  }

# See if current users child groups can access this document

  my @HierarchyIDs = keys %GroupsHierarchy;
  foreach my $UserGroupID (@UsersGroupIDs) { # Groups user belongs to
    unless ($SecurityGroups{$UserGroupID}{CanView}) {
      next;
    }
    foreach my $ID (@HierarchyIDs) {         # All Hierarchy entries
      my $ParentID = $GroupsHierarchy{$ID}{Parent};
      my $ChildID  = $GroupsHierarchy{$ID}{Child};
      unless ($SecurityGroups{$ChildID}{CanView}) {
        next;
      }
      if ($ParentID == $UserGroupID) {    # We've found a valid "child" of one of our groups.
        foreach my $GroupID (@GroupIDs) { # See if the child can access the document
          if ($GroupID == $ChildID) {
            $access = 1;
            last;
          }
        }
      }
    }
  }

  #close (DEBUG);

  return $access;
}

sub CanModify { # Can the user modify (with current security) this document
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";
  require "SecuritySQL.pm";

  GetSecurityGroups();
  my ($DocumentID,$Version) = @_;

  my $CanModify;
  if     ($Public)     {return 0;} # Public version of code, can't modify
  unless (CanCreate()) {return 0;} # User can't create documents, so can't modify

  FetchDocument($DocumentID);
  unless (defined $Version) { # Last version is default
    $Version = $Documents{$DocumentID}{NVersions};
  }

# See what group(s) current user belongs to

  my @UsersGroupIDs = FindUsersGroups();

  if (CanAdminister()) {
      return 1;
  }

  my @ModifyGroupIDs = ();
  if ($EnhancedSecurity) {
    my $DocRevID    = FetchRevisionByDocumentAndVersion($DocumentID,$Version);
#  
#   MCA: Check if the Submitter is trying to access the document
#
    FetchDocRevisionByID($DocRevID);
    my $SubmitterID = $DocRevisions{$DocRevID}{Submitter};
    if ($SubmitterID == $EmailUserID) {
       $CanModify = 1;
    }
    if ($Documents{$DocumentID}{Requester} == $EmailUserID) {
       $CanModify = 1;
    }

    @ModifyGroupIDs = GetRevisionModifyGroups($DocRevID);
    # See if the access group is "Authorship"
    if (isAuthorshipAccess(@ModifyGroupIDs)) {
        if (isEmailUserAnAuthor($EmailUserID, $DocRevID)) { 
            $CanModify = 1; 
         }
    }
  }

  # In the enhanced security model, if no one is explictly listed as being
  # able to modify the document, then anyone who can view it is allowed to.
  # This maintains backwards compatibility with DB entries from before.

  if (@ModifyGroupIDs && $EnhancedSecurity) {
    foreach my $UsersGroupID (@UsersGroupIDs) {
      foreach my $GroupID (@ModifyGroupIDs) { # Check auth. users vs. logged in user
        if ($UsersGroupID == $GroupID && $SecurityGroups{$GroupID}{CanCreate}) {
          $CanModify = 1;                           # User checks out
          last;
        }
      }
    }

    if (!$CanModify && $SuperiorsCanModify) {    # We don't have a winner yet, but keep checking
      my @HierarchyIDs = keys %GroupsHierarchy;  # See if current users children can modify this document
      foreach my $UserGroupID (@UsersGroupIDs) { # Groups user belongs to
        foreach my $ID (@HierarchyIDs) {         # All Hierarchy entries
          my $ParentID = $GroupsHierarchy{$ID}{Parent};
          my $ChildID  = $GroupsHierarchy{$ID}{Child};
          if ($ParentID == $UserGroupID) {          # We've found a "child" of one of our groups.
            foreach my $GroupID (@ModifyGroupIDs) { # See if the child can access the document
              if ($GroupID == $ChildID) {
                $CanModify = 1;
                last;
              }
            }
          }
        }
      }
    }
  } else { # No entries in the modify table or we're not using seperate view/modify lists
    $CanModify = CanAccess($DocumentID,$Version);
  }
  return $CanModify;
}

sub CanCreate { # Can the user create documents
  require "SecuritySQL.pm";

  my $Create = 0;

  if ($Public || $ReadOnly) {
    return $Create;
  }

# See what group(s) current user belongs to

  my @UsersGroupIDs = FindUsersGroups();
  push @DebugStack,"User belongs to groups ".join ', ',@UsersGroupIDs;

  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $UserGroupID (@UsersGroupIDs) {
    FetchSecurityGroup($UserGroupID);
    if ($SecurityGroups{$UserGroupID}{CanCreate} && $SecurityGroups{$UserGroupID}{CanView}) {
      $Create = 1;                           # User checks out
    }
  }
  push @DebugStack,"User can create: $Create";
  return $Create;
}

sub GroupCan { # Could be used in above, but we need to know without $Public and
               # such if the specified user is allowed to create or view documents
  my ($ArgRef) = @_;
  my $GroupID = exists $ArgRef->{-groupid} ? $ArgRef->{-groupid} : 0;
  my $Action  = exists $ArgRef->{-action}  ? $ArgRef->{-action}  : "view";

  if ($Action eq "view") {
    return $SecurityGroups{$GroupID}{CanView};
  } elsif ($Action eq "create") {
    return $SecurityGroups{$GroupID}{CanCreate};
  }

  return $FALSE;
}

sub CanAdminister (;$) { # Can the user administer the database
  require "SecuritySQL.pm";
  my ($EmailUserID) = @_;

  unless ($EmailUserID) {
     $EmailUserID = FetchEmailUserIDFromRemoteUser();
  }
  
  GetSecurityGroups();

# See what group(s) current user belongs to


  my $Administer = 0;

  if ($Public || ($ReadOnly && !$ReadOnlyAdmin)) {
    return $Administer;
  }

  my @UsersGroupIDs = ();
  #my @UsersGroupIDs = FindUsersGroups();

  if ($EmailUserID) {
    @UsersGroupIDs = FetchUserGroupIDs($EmailUserID);
  } else {
    @UsersGroupIDs = FetchUserGroupIDs($GLOBAL_EMAILUSER);
  }

  my @GroupIDs = keys %SecurityGroups; # FIXME use a hash for direct lookup
  foreach my $UserGroupID (@UsersGroupIDs) {
    &FetchSecurityGroup($UserGroupID);
    if ($SecurityGroups{$UserGroupID}{CanAdminister}) {
      $Administer = 1;                           # User checks out
    }
  }
  return $Administer;
}

sub LastAccess { # Highest version user can access (with current security)
  require "DocumentSQL.pm";
  my ($DocumentID) = @_;
  my $Version = -1;
  &FetchDocument($DocumentID);
  my $tryver = $Documents{$DocumentID}{NVersions};
  while ($Version == -1 && $tryver <=> -1) {
    if (&CanAccess($DocumentID,$tryver)) {$Version = $tryver;}
    --$tryver;
  }
  return $Version;
}

sub isAuthorshipAccess(%) {
  my (@GroupIDs)  = @_;

  my ($AuthorsOnly_GroupID) = &FetchSecurityGroupByName($AuthorsOnly_Group);

  foreach my $GroupID (@GroupIDs) {
    
     if ($GroupID == $AuthorsOnly_GroupID) {
         return 1;
     }
  }
  return 0;
}

sub CanCertify() {
  require "SecuritySQL.pm";

  my @UsersGroupIDs = &FindUsersGroups();

  my ($CertifyGroupID) = &FetchSecurityGroupByName($Certify_Group);

  my @HierarchyIDs = keys %GroupsHierarchy; 

  #open (DEBUG, ">>/tmp/debug1");
  #print DEBUG "Hierarchy IDs : @HierarchyIDs \n"; 
  #print DEBUG "Certify GroupID : $CertifyGroupID\n"; 
  foreach my $GroupID (@UsersGroupIDs) {
     #print DEBUG "Testing: $GroupID\n"; 
     if ($GroupID == $CertifyGroupID) {
         return 1;
     }

     foreach my $ID (@HierarchyIDs) {
         my $ParentID  = $GroupsHierarchy{$ID}{Parent};
         my $ChildID = $GroupsHierarchy{$ID}{Child};

         #print DEBUG "ChildID : $ChildID\n"; 
         #print DEBUG "ParentID: $ParentID\n"; 
        
         if ($CertifyGroupID == $ChildID && $GroupID == $ParentID) {
            #print DEBUG "CAN CERTIFY : $ParentID\n"; 
            return 1;
         }
         #print DEBUG "-----\n"; 
     }
  }

#  close (DEBUG);

  return 0;
}

sub FindUsersGroups (;%) {
  require "Utilities.pm";
  require "Cookies.pm";
  require "SecuritySQL.pm";

  my (%Params) = @_;
  my $IgnoreCookie = $Params{-ignorecookie} || $FALSE;

  my @UsersGroupIDs  = ();
  if ($UserValidation eq "certificate") {
    require "CertificateUtilities.pm";
    @UsersGroupIDs = &FetchSecurityGroupsByCert();
  } elsif ($UserValidation eq "basic-user") {
    # Coming (maybe)
  } elsif ($UserValidation eq "kerberos") {
    # Note:  This is setting the global variable $EmailUserID 
    # to be used in SelectEmailPrefs and WatchDocument
    $EmailUserID = (&FetchEmailUserIDFromRemoteUser());
    @UsersGroupIDs = (&FetchUserGroupIDs($EmailUserID));
  } else {
    my $RemoteUser = &remote_user;
    if ($RemoteUser eq "") {
       $RemoteUser = &authnz_remote_user;
    } 
    @UsersGroupIDs = (&FetchSecurityGroupByName ($RemoteUser));
  }

  push @DebugStack,"Before limiting, user belongs to groups ".join ', ',@UsersGroupIDs;

  unless (@UsersGroupIDs) {
    $Public = 1;
  }

  @UsersGroupIDs = &Unique(@UsersGroupIDs);
  unless ($IgnoreCookie) {
    my @LimitedGroupIDs = &GetGroupsCookie();
    if (@LimitedGroupIDs) {
      @UsersGroupIDs = &Union(\@LimitedGroupIDs,@UsersGroupIDs);
    }
  }

  return @UsersGroupIDs;
}



1;
