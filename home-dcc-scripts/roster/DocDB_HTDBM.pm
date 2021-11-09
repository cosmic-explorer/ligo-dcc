#
# Description: Generate the htdbm files based on DocDB's UserGroup Table
#
#      Member: Melody C. Araya (maraya@ligo.caltech.edu)
#
# Notes:  
#     $DocDB_Groups{$GroupID}{GroupID}
#     $DocDB_Groups{$GroupID}{Name}


%DocDB_Groups = ();
%DocDB_UserGroups = ();

$HTDBM_COMMENT = "Fake password is NULL";
$HTDBMFILE = "group_files/htdbmgroups";


sub FetchAllGroups() {
   my ($GroupID, $GroupName);
   my $AllGroups = $docdb_handle -> prepare(
        "select GroupID, Name from SecurityGroup ");
   $AllGroups -> execute;
   $AllGroups -> bind_columns(undef, \($GroupID, $GroupName));

   while ($AllGroups -> fetch) {
      $DocDB_Groups{$GroupID}{GroupID} = $GroupID;
      $DocDB_Groups{$GroupID}{Name} = $GroupName;
   }
}

sub FetchAllUserGroups() {
   my ($UserGroupID, $EmailUserID, $GroupID);
   my $AllUserGroups = $docdb_handle -> prepare(
        "select UsersGroupID, EmailUserID, GroupID from UsersGroup");
   $AllUserGroups -> execute;
   $AllUserGroups -> bind_columns(undef, \($UserGroupID, $EmailUserID, $GroupID));

   while ($AllUserGroups -> fetch) {
      $DocDB_UserGroups{$UsersGroupID}{UsersGroupID} = $UsersGroupID;
      $DocDB_UserGroups{$UsersGroupID}{EmailUserID}  = $EmailUserID;
      $DocDB_UserGroups{$UsersGroupID}{GroupID}      = $GroupID;
      
   }
}

sub FetchAuthorGroup { # Fetches an Author by ID, adds to $AuthorGroups{$AuthorGroupID}{}
  my ($authorGroupID) = @_;
  my ($AuthorGroupID,$AuthorGroupName, $Description);

  my $authorgroup_fetch  = $docdb_handle -> prepare(
     "select AuthorGroupID, AuthorGroupName, Description from AuthorGroupDefinition ". 
     "where AuthorGroupID=?");
  if ($AuthorGroups{$authorGroupID}{AuthorGroupID}) { # We already have this one
    return $AuthorGroups{$authorGroupID}{AuthorGroupID};
  }
  
  $authorgroup_fetch -> execute($authorGroupID);
  ($AuthorGroupID,$AuthorGroupName, $Description) = $authorgroup_fetch -> fetchrow_array;
  $AuthorGroups{$AuthorGroupID}{AuthorGroupID}   = $AuthorGroupID;
  $AuthorGroups{$AuthorGroupID}{AuthorGroupName} = $AuthorGroupName;
  $AuthorGroups{$AuthorGroupID}{Description}     = $Description;
  
  return $AuthorGroups{$AuthorGroupID}{AuthorGroupID};
}


sub DocDB_GenerateHTDBMFiles(){
   require "ProjectGlobals.pm";

   &FetchAllGroups();

   $FirstEntry = 1;
 
   my ($EmailUserID, $UserName, $EmailAddress, $AuthorID);
   my $EmailUsers = $docdb_handle -> prepare(
        "select EmailUserID, Username, EmailAddress, AuthorID from EmailUser ");
   $EmailUsers -> execute;
   $EmailUsers -> bind_columns(undef, \($EmailUserID, $UserName, $EmailAddress, $AuthorID));

   system ("rm -rf $HTDBMFILE.*");

   while ($EmailUsers -> fetch) {
      my $GroupString = ();
      my $FirstGroup = 1;
      #
      # Now check the UsersGroup table to see if the email user is in any groups
      #
      my ($GroupID);
      my $ThisUser = $docdb_handle -> prepare(
        "select GroupID from UsersGroup where EmailUserID = ?");
      $ThisUser -> execute($EmailUserID);
      $ThisUser -> bind_columns(undef, \($GroupID));
      while ($ThisUser -> fetch) {
          if ($FirstGroup){
             $GroupString = $DocDB_Groups{$GroupID}{Name};
             $FirstGroup = 0;
          } else {
             $GroupString .= ",$DocDB_Groups{$GroupID}{Name}";
          }
      }
      
      my ($AuthorGroupID);
      my $ThisAuthor = $docdb_handle -> prepare(
        "select AuthorGroupID from AuthorGroupList where AuthorID = ?");
      $ThisAuthor -> execute($AuthorID);
      $ThisAuthor -> bind_columns(undef, \($AuthorGroupID));
      while ($ThisAuthor -> fetch) {
          &FetchAuthorGroup($AuthorGroupID);
          if ($FirstGroup){
             $GroupString = $AuthorGroups{$AuthorGroupID}{AuthorGroupName}.$AuthorsOnly_GroupSuffix;
             $FirstGroup = 0;
          } else {
             $GroupString .= ",$AuthorGroups{$AuthorGroupID}{AuthorGroupName}"."$AuthorsOnly_GroupSuffix";
          }
      }

      if ($GroupString) {
          $GroupString .= ",$UserName";
          if ($FirstEntry) {
              print ROSTER_LOG "$EmailAddress  \"$GroupString:$HTDBM_COMMENT\"\n";
              system (
                 "htdbm -cbt $HTDBMFILE $EmailAddress NULL \"$GroupString:$HTDBM_COMMENT\"\n");
              $FirstEntry = 0;
          } else {
              print ROSTER_LOG "$EmailAddress  \"$GroupString:$HTDBM_COMMENT\"\n";
              system (
                 "htdbm -bt $HTDBMFILE $EmailAddress NULL \"$GroupString:$HTDBM_COMMENT\"");
          }
      }
   }

}

1;
