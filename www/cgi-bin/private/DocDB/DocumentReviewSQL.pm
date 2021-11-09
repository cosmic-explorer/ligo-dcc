
# Copyright 2014 - Melody Araya

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

require "RevisionSQL.pm";

sub FetchDocumentReview  {
  my ($DocumentID, $VersionNumber) = @_;

  my $DocReview    = $dbh -> prepare("select DocReviewID, ReviewState, TimeStamp, EmployeeNumber ".
                                       "from DocumentReview WHERE DocumentID=? AND VersionNumber=? ".
                                       "ORDER BY TimeStamp DESC LIMIT 1");
  $DocReview -> execute($DocumentID, $VersionNumber);
  my ($DocReviewID, $ReviewState, $ReviewTimeStamp, $ReviewActor) = $DocReview -> fetchrow_array;


  if ($DocRevID && $DocReviewID) {
    $DocRevisions{$DocRevID}{ReviewID}     = $DocReviewID;
    $DocRevisions{$DocRevID}{ReviewState}  = $ReviewState;
    $DocRevisions{$DocRevID}{ReviewStamp}  = $ReviewTimeStamp;
    $DocRevisions{$DocRevID}{ReviewActor}  = $ReviewActor;
    

    return $ReviewState;
  }
  else {
    return 0;
  }
}
 

sub FetchDocumentReviewByDocRevID  {
  my ($DocRevID) = @_;

  FetchDocRevisionByID ($DocRevID);
  $DocumentID    = $DocRevisions{$DocRevID}{DOCID};
  $VersionNumber = $DocRevisions{$DocRevID}{Version};

  return FetchDocumentReview ($DocumentID, $VersionNumber);

}


sub hasReviewState {
  require "SQLUtilities.pm";

  my ($DocRevID) = @_;
    

  FetchDocumentReviewByDocRevID ($DocRevID);

  if ($DocRevisions{$DocRevID}{ReviewState} != NULL ) {
      if ($DocRevisions{$DocRevID}{ReviewState} != 0) {
         return 1;
      }
  }

  return 0; 
}
  
sub CheckFiles {
  my ($DocRevID) = @_;

  FetchDocRevisionByID ($DocRevID);
  $DocumentID    = $DocRevisions{$DocRevID}{DOCID};
  $VersionNumber = $DocRevisions{$DocRevID}{Version};

  return 0;
}



1;
