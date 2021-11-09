#
# Description: LDIF access routines 
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
#     $Members{$MemberID}{UserName}
#     $Members{$MemberID}{EmailForward}
#     $Members{$MemberID}{RemoteUser}
#     $Members{$MemberID}{ACTIVE}  
#     $Members{$MemberID}{InstitutionName};    # Institution ShortName
#     $Members{$MemberID}{PositionCode};
#     $Members{$MemberID}{DocDB_EmailID}; 
#     $Members{$MemberID}{DocDB_AuthorID}; 
#     $Members{$MemberID}{VERIFIED}; 
#     $Members{$MemberID}{New}; 
# 
#

use Net::LDAP;

%Members = ();
$ldap_base = 'ou=people,o=KAGRA-LIGO,o=CO,dc=gwastronomy-data,dc=cgca,dc=uwm,dc=edu';
#$ldap_base = 'ou=people,o=KAGRA-LIGO,dc=gwastronomy-data,dc=cgca,dc=uwm,dc=edu';
#$ldap_base = 'ou=people, o=KAGRA-LIGO, dc=gw-astronomy, dc=org';
#$ldap_base = 'o=KAGRA-LIGO, dc=gw-astronomy, dc=org';
#$ldap_base = 'dc=ligo, dc=org';
$ldap_attr =  'isMemberOf';
$ldap_pattern = "gw-astronomy:KAGRA-LIGO:members";
#$ldap_pattern = "CO:members:active";
$scope = "\@shibbi.pki.itc.u-tokyo.ac.jp";
#$scope = "\@ligo.org";

sub GetKAGRAMembersFromLDAP { # Creates/fills a hash $Members{$MemberID}{} for all members

   my @attr_list = {'eduPersonPrincipalName', 'cn', 'givenName', 'sn', 'mail', 'employeeNumber'};
#   my @attr_list = {'uid', 'cn', 'givenName', 'sn', 'mail'};
   my $query = "($ldap_attr=$ldap_pattern)";


   my $mesg = $ldap->search(base => $ldap_base, filter => "(|$query)");

   if ( $mesg->code ) { LDAPerror ("search", $mesg) }

   foreach my $entry ($mesg->entries) {

         my $uid = $entry->get_value( 'employeeNumber' );
         my $eduPrincipalName = $entry->get_value( 'eduPersonPrincipalName' );
         my $username = $eduPrincipalName;
         my $FirstName = $entry->get_value( 'givenName' );
         my $LastName = $entry->get_value( 'sn' );
         $username =~ s/$scope//g;
         $uid =~ s/KL/88/g;
         $Members{$uid}{MEMBERID}     = $uid;
         $Members{$uid}{UserName}     = $username;
         $Members{$uid}{FirstName}    = $FirstName;
         $Members{$uid}{LastName}     = $LastName;
         $Members{$uid}{FULLNAME}     = $entry->get_value( 'cn' );
         $Members{$uid}{EmailForward} = $entry->get_value( 'mail' );
         $Members{$uid}{RemoteUser}   = $eduPrincipalName;
         $Members{$uid}{InstitutionName} = "KAGRA";
#         $Members{$uid}{InstitutionName} = "KAGRA";
         $Members{$uid}{Formal}       = "$FirstName $LastName";
         $Members{$uid}{ACTIVE}       = 1;
         $Members{$uid}{GroupID}      = 37;
         $Members{$uid}{NewEntry}     = 1;
         $Members{$uid}{NewMember}    = 1;
         $Members{$uid}{VERIFIED}     = 0;  
         $Members{$uid}{DocDB_EmailID} = 0;
         $Members{$uid}{DocDB_AuthorID}= 0;
   }

}


sub LDAPerror {
   my ($from, $mesg) = @_;
   print "Return code: ", $mesg->code;
   print "\tMessage: "  , $mesg->error_name;
   print " :"           , $mesg->error_text;
   print "MessageID: "  , $mesg->mesg_id;
   print "\tDN: "       , $mesg->dn;
}


1;

