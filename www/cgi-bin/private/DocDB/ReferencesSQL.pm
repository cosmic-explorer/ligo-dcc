#
# Description: SQL access routings for authors and institutions
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:
#

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

sub InsertReferences (%) {
  my %Params = @_;
  my $DocRevID  =   $Params{-docrevid}   || "";
  #my $Order     =   $Params{-order}     || $FALSE;
  my @ReferenceIDs = @{$Params{-referenceids}};
  @ReferenceIDs = OrderPreservingUnique(@ReferenceIDs);

  #my $Count       = 0;
  #my $ReferenceOrder = 0;
  # my $Insert = $dbh->prepare("insert into RevisionAuthor (RevAuthorID, DocRevID, AuthorID, AuthorOrder) values (0,?,?,?)");
  my $Insert = $dbh->prepare("insert into RevisionReference (ReferenceID,DocRevID,JournalID,Volume,Page) values (0,?,?,?,?)");

  foreach my $ReferenceID (@ReferenceIDs) {
    if ($ReferenceID) {
     # if ($Order) {
     #      $ReferenceOrder = $Count;
     # }
      $JournalID = $RevisionReferences{$ReferenceID}{JournalID};
      $Volume = $RevisionReferences{$ReferenceID}{Volume};
      $Page = $RevisionReferences{$ReferenceID}{Page};
      $Insert -> execute($DocRevID,$JournalID,$Volume,$Page);
     # ++$Count;
    }
  }
  return 1;
  #return $Count;
}
1;
