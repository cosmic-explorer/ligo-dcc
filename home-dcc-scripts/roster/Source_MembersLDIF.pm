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
#     $Members{$MemberID}{ACTIVE}  
#     $Members{$MemberID}{InstitutionName};    # Institution ShortName
#     $Members{$MemberID}{PositionCode};
#     $Members{$MemberID}{DocDB_EmailID}; 
#     $Members{$MemberID}{New}; 
# 
#

use Text::ParseWords;

%Members = ();
%Institutions = ();
%Organizations = ();

open (LDIF, "< LDIF.in");
$Scope = "\@shibbi.pki.itc.u-tokyo.ac.jp";

sub GetMembersFromLDIF { # Creates/fills a hash $Members{$MemberID}{} for all members

  my $i = 0;
  while (<LDIF>) {
    $i++;
    my ($line) = $_;
    my @words = ();

    chomp ($line);
    @words = split(",", $line);

    $Members{$i}{MEMBERID}     = $i;
    $Members{$i}{UserName}     = $words[0];
    $Members{$i}{FirstName}    = $words[1];
    $Members{$i}{LastName}     = $words[2];
    $Members{$i}{FULLNAME}     = $words[3];
    $Members{$i}{EmailForward} = $words[4];
    $Members{$i}{RemoteUser}   = $Members{$i}{UserName}.$Scope;
    $Members{$i}{InstitutionName} = "ICRR";
    $Members{$i}{ACTIVE}       = 1;
    $Members{$i}{GroupID}      = 37;
    print ROSTER_LOG "INFO: $i: @words : $Members{$i}{EmailForward}";
    print ROSTER_LOG ": $Members{$i}{RemoteUser}\n";
  }
 
}


1;

