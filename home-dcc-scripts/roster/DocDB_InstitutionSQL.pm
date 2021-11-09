#
# Description: SQL routines to UPDATE the DocDB InstitutionTables
#
#      Member: Melody C. Araya (maraya@ligo.caltech.edu)
#
#
# Notes:  
# 1.  The source tables have institution and organization tables.
#     Institutions in the DocDB table is actually the organization entries in the
#     Source tables.

%DocDB_Institutions = ();
sub DocDB_UpdateInstitutionTable() {
  require "Source_MembersSQL.pm";  

  &GetOrganizations();
  
  foreach my $OrganizationID (keys %Organizations) {

      $source_short_name = $Organizations{$OrganizationID}{SHORT};  

      my ($InstitutionID, $ShortName, $LongName);
      my $inst_list  = $docdb_handle -> prepare(
          "select InstitutionID, ShortName, LongName from Institution where ShortName = ?"); 
      $inst_list -> execute($source_short_name);
      $inst_list -> bind_columns(undef, \($InstitutionID,$ShortName,$LongName));
      if ($inst_list -> fetch) {
          if ($ShortName && $LongName) {
#              print "Found $ShortName: $LongName\n";
              $DocDB_Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
              $DocDB_Institutions{$InstitutionID}{SHORT}         = $ShortName;
              $DocDB_Institutions{$InstitutionID}{LONG}          = $LongName;
          }
      }
      else {
          #
          # Add to the InstitutionTable
          #
          if ($ShortName && $LongName) {
              print  ROSTER_LOG "INFO: About to insert $ShortName: $LongName into Institution";

#              my $inst_insert = $docdb_handle -> prepare(
#                  "insert into Institution (ShortName, LongName) values (?, ?)" ); 
#              $inst_insert -> execute ($ShortName, $LongName);
#              my $InstID;
#              ($InstID) = $inst_insert -> fetch_array;
              $DocDB_Institutions{$InstitutionID}{InstitutionID} = $InstID;
              $DocDB_Institutions{$InstitutionID}{SHORT}         = $ShortName;
              $DocDB_Institutions{$InstitutionID}{LONG}          = $LongName;
          }
      }
  }

}

sub DocDB_GetInstitutions() {# Creates/fills a hash $DocDB_Institutions {$InstitutionID}{} for all Institutions

  if ($HaveAllInstitutions) {
    return;
  }  

  my ($InstitutionID,$ShortName,$LongName);

  my $inst_list  = $docdb_handle -> prepare(
     "select InstitutionID, ShortName, LongName from Institution"); 
  $inst_list -> execute;
  $inst_list -> bind_columns(undef, \($InstitutionID,$ShortName,$LongName));
  while ($inst_list -> fetch) {
    $DocDB_Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
    $DocDB_Institutions{$InstitutionID}{SHORT}         = $ShortName;
    $DocDB_Institutions{$InstitutionID}{LONG}          = $LongName;
  }
  $HaveAllInstitutions = 1;
}


sub DocDB_FetchInstitution($) {  #Fetchs an Insitution by ID 
  my ($InstitutionID) = @_;

  if ($Institutions{$InstitutionID}{InstitutionID}) {
    return;
  }  
  
  my ($ShortName,$LongName);
  my $InstitutionFetch  = $docdb_handle -> prepare(
     "select ShortName,LongName from Institution where InstitutionID=?"); 
  $InstitutionFetch -> execute($InstitutionID);
  ($ShortName,$LongName) = $InstitutionFetch -> fetchrow_array;
  $DocDB_Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
  $DocDB_Institutions{$InstitutionID}{SHORT}         = $ShortName;
  $DocDB_Institutions{$InstitutionID}{LONG}          =  $LongName;
}


sub DocDB_GetInstitutionIDByShortName($) {  #Fetchs an Insitution by ID 
  my ($ShortName) = @_;

  my ($InstitutionID);
  my $InstitutionFetch  = $docdb_handle -> prepare(
     "select InstitutionID from Institution where ShortName LIKE (\"$ShortName\")"); 
  $InstitutionFetch -> execute();
  ($InstitutionID) = $InstitutionFetch -> fetchrow_array;

  return $InstitutionID;
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
    elsif ($NewInstID == 219) {
        #$NewInstID: 219 = LIO = LIGO-India
        print ROSTER_LOG "WARNING: About to change institution for $AuthorID from $OldInstID to $NewInstID\n";
        my $inst_update = $docdb_handle -> prepare(
                   "update Author set InstitutionID=? WHERE AuthorID=?"); 
        my $success = 1;
        $inst_update -> execute ($NewInstID, $AuthorID) or $success = 0;
    }
}


1;

