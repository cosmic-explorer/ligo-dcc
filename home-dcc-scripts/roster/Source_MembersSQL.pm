#
# Description: SQL access routines for the LVC members
#
#      Author: Melody C. Araya (maraya@ligo.caltech.edu)
#
#
# Notes:  
# 1.  The source tables have institution and organization tables.
#     Institutions is the DocDB table is actually the organization entries in the
#     Source tables.
# 2.  VIRGO members in the DocDB table will have VIRGO as their institution
# 3.  In GetMembersFromSourceTable, members which have the lsc attribute as "virgo"
#     are skipped.
#     All VIRGO members are added by querying the virgo source table.
# 4.  Source Member hash table
#     $Members{$MemberID}{MEMBERID}
#     $Members{$MemberID}{FULLNAME}
#     $Members{$MemberID}{Formal} 
#     $Members{$MemberID}{LastName}
#     $Members{$MemberID}{FirstName}
#     $Members{$MemberID}{UserName
#     $Members{$MemberID}{ACTIVE}  
#     $Members{$MemberID}{InstitutionName};    # Institution ShortName
#     $Members{$MemberID}{PositionCode};
#     $Members{$MemberID}{DocDB_EmailID}; 
#     $Members{$MemberID}{New}; 
# 
#

%Members = ();
%Institutions = ();
%Organizations = ();

$LIGO_LAB   = 9;
$LSC        = 4;
$VIRGO      = 55;
$EXTERNAL   = 6;
$LIO        = 56;
$CL_ID_LIGO = 2;
$AS_ID_LIO  = 109;

sub GetMembersFromSourceTable { # Creates/fills a hash $Members{$MemberID}{} for all members

  my ($MemberID,$UserName,$FirstName,$LastName,$Active, $OrganizationID, $EmailForward);

  GetOrganizations();
  GetInstitutions();

  #
  # First, get the information from the members table: 
  #       id, userName, fName, lName, status, lsc (lsc-all or virgo)
  #
  # LSC members: Need their to find out their institutions through querying
  #              the mem_org table.   
  #              The entry in the InstitutionID in Members hash table is the 
  #              insitution's shortName.
  # VIRGO members:  Institution will be "VIRGO"


  my ($cl_id, $as_id, $af_id);

  my $query = qq(
     select p.pe_id, user_name, first_name, last_name, email_forward, cl_id, as_id, af_id from people p 
     left join memberships on p.pe_id = memberships.pe_id where p.pe_id in (
          select pe_id from memberships group by pe_id ORDER BY cl_id DESC)
  );
  

  my $people_list  = $myligo_handle -> prepare($query);
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($MemberID, $UserName, $FirstName, $LastName, $Email_Forward, $cl_id, $as_id, $af_id));
  $Active = TRUE;


  while ($people_list -> fetch) {
        $Members{$MemberID}{MEMBERID}  =  $MemberID;
        if ($FirstName) {
           $Members{$MemberID}{FULLNAME}  = "$FirstName $LastName";
           $Members{$MemberID}{Formal}    = "$LastName, $FirstName";
        } else {
           $Members{$MemberID}{FULLNAME}  = "$LastName";
           $Members{$MemberID}{Formal}    = "$LastName";
        }
        $Members{$MemberID}{LastName}      = $LastName;
        $Members{$MemberID}{FirstName}     = $FirstName;
        $Members{$MemberID}{UserName}      = $UserName;
        $Members{$MemberID}{PositionCode}  = 0;
        $Members{$MemberID}{EmailForward}  = $UserName."\@LIGO.ORG";
        #$Members{$MemberID}{EmailForward}  = $Email_Forward;
        $Members{$MemberID}{New}           = 0;
        $Members{$MemberID}{RemoteUser}    = $UserName."\@LIGO.ORG";
        $Members{$MemberID}{CL_ID}         = $cl_id;
        $Members{$MemberID}{AS_ID}         = $as_id;

        if ($cl_id == NULL) {$Active = FALSE;}

        $Members{$MemberID}{ACTIVE}        = $Active;


        # mysql> select * from classifications;
        # +-------+---------------+-----------+----------------------------+
        # | cl_id | cl_index_name | cl_status | cl_name                    |
        # +-------+---------------+-----------+----------------------------+
        # |     1 | LSC           | active    | LSC                        | 
        # |     2 | LIGOLab       | active    | LIGO Lab                   | 
        # |     3 | Support       | active    | Support                    | 
        # |     4 | Virgo         | active    | Virgo                      | 
        # |     5 | Collaborators | active    | Collaborators              | 
        # |     6 | NSF           | active    | NSF or External Committees | 
        # +-------+---------------+-----------+----------------------------+

        $Members{$MemberID}{GroupID}       = 0;
        if ($cl_id == $CL_ID_LIGO) {
        } 


        my $inst_code  = &GetInstitutionFromMemberInfo ($MemberID);

        print ROSTER_LOG "INFO: $UserName $cl_id $as_id $af_id $inst_code \n";
    
        if ($inst_code eq "NSF" && $Email_Forward !~ /nsf/i) {
            print ROSTER_LOG "WARNING: NSF Institution for $UserName: $Email_Forward\n";
        }

        $Members{$MemberID}{InstitutionName} = $inst_code;
        if ($cl_id == 1) {
            $Members{$MemberID}{GroupID} = $LSC; 
            $Members{$MemberID}{PositionCode} = GetPositionCodeFromMemberInfo ($MemberID);
        }
        elsif ($cl_id == 2) {
            $Members{$MemberID}{GroupID}   = $LIGO_LAB; 
            if ($as_id == $AS_ID_LIO) {
                $Members{$MemberID}{GroupID} = $LIO; 
            }
        }
        elsif ($cl_id == 4) {
            $Members{$MemberID}{GroupID} = $VIRGO; 
        }
        elsif ($cl_id == 6) {
            $Members{$MemberID}{GroupID} = $EXTERNAL; 
            $Members{$MemberID}{InstitutionName} = "NSF";
        }
        else {
          if (($inst_code eq "") && $Active) {
              print ROSTER_LOG "ERROR: No Institution Code for Active member $UserName: Will not be added to the system\n";
          }
          else {
              if ($Active) {
                 print ROSTER_LOG "WARNING: Using Institution (Not Organization) for $UserName ($inst_code)\n";
                 $Members{$MemberID}{InstitutionName} = $inst_code;
              }
          }
        }
     } 
 
}


sub GetOrganizations { # Creates/fills a hash $Organizations{$OrganizationID}{} for all Organizations
  if ($HaveAllOrganizations) {
    return;
  }  

  my ($OrganizationID,$ShortName,$LongName);

  my $org_list  = $myligo_handle -> prepare(
     "select as_id, as_acronim, as_name from associations"); 
  $org_list -> execute;
  $org_list -> bind_columns(undef, \($OrganizationID,$ShortName,$LongName));
  while ($org_list -> fetch) {
    $Organizations{$OrganizationID}{OrganizationID} = $OrganizationID;
    $Organizations{$OrganizationID}{SHORT}         = $ShortName;
    $Organizations{$OrganizationID}{LONG}          = $LongName;
  }
  $HaveAllOrganizations = 1;
}


sub FetchOrganization { # Fetches an Organization by ID
  my ($OrganizationID) = @_;
  if ($Organizations{$OrganizationID}{OrganizationID}) {
    return;
  }  
  
  my ($ShortName,$LongName);
  my $OrganizationFetch  = $myligo_handle -> prepare(
     "select ShortName,LongName from Organization where OrganizationID=?"); 
  $OrganizationFetch -> execute($OrganizationID);
  ($ShortName,$LongName) = $OrganizationFetch -> fetchrow_array;
  $Organizations{$OrganizationID}{OrganizationID} = $OrganizationID;
  $Organizations{$OrganizationID}{SHORT}         = $ShortName;
  $Organizations{$OrganizationID}{LONG}          =  $LongName;
}

# mysql> describe affiliations;
# +----------------------+---------------------------+------+-----+---------+----------------+
# | Field                | Type                      | Null | Key | Default | Extra          |
# +----------------------+---------------------------+------+-----+---------+----------------+
# | af_id                | smallint(2) unsigned      | NO   | PRI | NULL    | auto_increment | 
# | af_index_name        | varchar(50)               | NO   | MUL |         |                | 
# | af_status            | enum('active','inactive') | NO   |     |         |                | 
# | af_name              | varchar(100)              | YES  |     | NULL    |                | 
# | af_screen_name       | varchar(50)               | YES  |     | NULL    |                | 
# | af_short_screen_name | varchar(30)               | YES  |     | NULL    |                | 
# | af_acronim           | varchar(10)               | YES  |     | NULL    |                | 
# +----------------------+---------------------------+------+-----+---------+----------------+

sub GetInstitutions { # Creates/fills a hash $Institutions {$InstitutionID}{} for all Institutions
  if ($HaveAllInstitutions) {
    return;
  }  

  my ($InstitutionID,$ShortName,$LongName, $Status);

  my $inst_list  = $myligo_handle -> prepare(
     "select af_id, af_acronim, af_name, af_status from affiliations"); 
  $inst_list -> execute;
  $inst_list -> bind_columns(undef, \($InstitutionID,$ShortName,$LongName,$Status));
  while ($inst_list -> fetch) {
      #if ($Status eq 'active') {
          $Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
          $Institutions{$InstitutionID}{SHORT}         = $ShortName;
          $Institutions{$InstitutionID}{LONG}          = $LongName;
      #}
  }
  $HaveAllInstitutions = 1;
}


sub GetInstitutionFromMemberInfo ($) { #Fetches the Institution ShortName from the member_info
  my ($PE_ID) = @_;


     $primary_org = ();
     $max_fte = ();

     my ($cl_id, $as_id, $af_id);
     my $mem_query = $myligo_handle -> prepare( "select cl_id, as_id, af_id from memberships where pe_id=?");
     $mem_query -> execute($PE_ID);
     $mem_query -> bind_columns(undef, \($cl_id, $as_id, $af_id));


     my $num_orgs = 0;
     while ($mem_query -> fetch) {
         my $org = ();
         my $fte = ();
         if ($cl_id == 4) {
             $org = "VIRGO";
         } elsif ($cl_id == 6) {
             $org = "NSF";
         }
         else {
             if ($af_id) {
                 $org = $Institutions{$af_id}{SHORT};
             } else {
                 if ($as_id) {
                     $org = $Organizations{$as_id}{SHORT};
                     if ($org eq "LIGO-CIT") {$org = "CT"}
                     if ($org eq "LIGO-MIT") {$org = "LM"}
                     if ($org eq "LIGO-LLO") {$org = "LV"}
                     if ($org eq "LIGO-LHO") {$org = "LO"}
                     if ($org eq "NAOJ-TAMA") {$org = "NA"}
                     if ($org eq "IUCAA")    {$org = "IU"}
                     if ($org eq "IAP")      {$org = "IA"}
                     if ($org eq "PSURG")    {$org = "PU"}
                     if ($org eq "HWSLG")    {$org = "HC"}
                     if ($org eq "UOERG")    {$org = "OU"}
                     if ($org eq "CCRG")     {$org = "CL"}
                     if ($org eq "UTAGP")    {$org = "TA"}
                     if ($org eq "LSUERG")   {$org = "LU"}
                     if ($org eq "MSURG")    {$org = "MS"}
                     if ($org eq "SUBR")     {$org = "SO"}
                     if ($org eq "GECo")     {$org = "CO"}
                     if ($org eq "SAGWI")    {$org = "SA"}
                     if ($org eq "RAGLT")    {$org = "LE"}
                     if ($org eq "RIT")      {$org = "RI"}
                     if ($org eq "TULG")     {$org = "TR"}
                     if ($org eq "UF-LIGO")  {$org = "FA"}
                     if ($org eq "ERGWAG")   {$org = "ER"}
                     if ($org eq "UMISS")    {$org = "MI"}
                     if ($org eq "UMINN")    {$org = "MN"}
                     if ($org eq "MaGWG")    {$org = "MD"}
                     if ($org eq "GGWAG")    {$org = "ND"}
                     if ($org eq "SSU")      {$org = "SM"}
                     if ($org eq "MtGWA")    {$org = "MT"}
                     if ($org eq "URLG")     {$org = "RO"}
                     if ($org eq "SJS")      {$org = "SJ"}
                     if ($org eq "ANDREW")   {$org = "AU"}
                     if ($org eq "NUGWAG")   {$org = "NO"}
                     if ($org eq "MGWG")     {$org = "MU"}
                     if ($org eq "SUERG")    {$org = "SR"}
                     if ($org eq "UMASS")    {$org = "AM"}
                     if ($org eq "UTBRG")    {$org = "TC"}
                     if ($org eq "SANNIO")   {$org = "SN"}
                     if ($org eq "CaRT")     {$org = "CA"}
                     if ($org eq "CEGG")     {$org = "CH"}
                     if ($org eq "DCP-SLU")  {$org = "SE"}
                     if ($org eq "WSURG")    {$org = "WU"}
                     if ($org eq "UIBRG")    {$org = "BB"}
                     if ($org eq "EOTVOS")   {$org = "EU"}
                     if ($org eq "UWM")      {$org = "UW"}
                 }

             }
             my $fte_query = 
                 $myligo_handle -> prepare( "select ef_fte from lsc_efforts where pe_id=? and as_id=?");
             $fte_query -> execute($PE_ID, $as_id);
             $fte_query -> bind_columns(undef, \($fte));
             if ($fte_query -> fetch ) {
                 #print " $org = $fte ";
             } 
         }

         if ($num_orgs == 0) {
             $primary_org = $org;
             if ($fte) {
                $max_fte = $fte;
             }
         } else {
             if ($fte)  {
                 if ($fte > $max_fte) {
                     $primary_org = $org;
                     $max_fte = $fte;
                 } 
             }
         }        
         $num_orgs++;
     }

     return $primary_org;
}

sub Unique {
  my @Elements = @_;
  my %Hash = ();
  foreach my $Element (@Elements) {
    ++$Hash{$Element};
  }

  my @UniqueElements = keys %Hash;
  return @UniqueElements;
}


 

# mysql> select * from position_types;
# +-------+-------+-----------------------+
# | cl_id | pt_id | pt_name               |
# +-------+-------+-----------------------+
# |     1 |     1 | Faculty, Sr. Sci/Eng  | 
# |     1 |     2 | Scientist / Engineer  | 
# |     1 |     3 | Postdoctoral Scholar  | 
# |     1 |     4 | Technical Staff       | 
# |     1 |     5 | Graduate Student      | 
# |     1 |     6 | Undergraduate Student | 
# |     1 |     7 | Education & Outreach  | 
# |     2 |     8 | Administrative Staff  | 
# +-------+-------+-----------------------+

sub GetPositionCodeFromMemberInfo ($) { 
  my ($MemberID) = @_;
  
  my ($PositionCode);

  my $member_info_search = $myligo_handle -> prepare(
     "select pt_id from positions where pe_id=?");
  $member_info_search -> execute($MemberID);
  $member_info_search -> bind_columns(undef, \($PositionCode));
  
  $member_info_search -> fetch;
  return $PositionCode;
}


  

1;

