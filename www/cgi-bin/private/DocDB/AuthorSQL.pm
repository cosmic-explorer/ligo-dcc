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


sub ClearAuthors{
  $HaveAllAuthors = 0;
  %Authors = ();
}

sub GetAuthors { # Creates/fills a hash $Authors{$AuthorID}{} with all authors
  if ($HaveAllAuthors) {
     return;
  }
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID);
  my $people_list  = $dbh -> prepare("select AuthorID,FirstName,MiddleInitials,LastName,Active,InstitutionID from Author"); 
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID));
  while ($people_list -> fetch) {
    $Authors{$AuthorID}{AUTHORID}  =  $AuthorID;
    if ($MiddleInitials) {
      $Authors{$AuthorID}{FULLNAME}  = "$FirstName $MiddleInitials $LastName";
      $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName $MiddleInitials";
    } elsif ($FirstName) {
      $Authors{$AuthorID}{FULLNAME}  = "$FirstName $LastName";
      $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName";
    } else {
      $Authors{$AuthorID}{FULLNAME}  = "$LastName";
      $Authors{$AuthorID}{Formal}    = "$LastName";
    }
    $Authors{$AuthorID}{LastName}      = $LastName;
    $Authors{$AuthorID}{FirstName}     = $FirstName;
    $Authors{$AuthorID}{ACTIVE}        = $Active;
    $Authors{$AuthorID}{InstitutionID} = $InstitutionID;
  }

  GetAuthorsEmailUserID();

  $HaveAllAuthors = 1;
}

#
# GetAuthorsEmailUserID has to be called after GetAuthors
#
sub GetAuthorsEmailUserID { # Creates/fills a hash $Authors{$AuthorID}{EmailUserID} with all authors
  my ($AuthorID,$EmailUserID);
  my $people_list  = $dbh -> prepare(
     "select AuthorID,EmailUserID from EmailUser"); 
  $people_list -> execute;
  $people_list -> bind_columns(undef, \($AuthorID,$EmailUserID));
  while ($people_list -> fetch) {
    $Authors{$AuthorID}{EmailUserID}      = $EmailUserID;
  }
}

sub GetAuthorsByAuthorGroup { # Creates/fills a hash $AuthorGroups{$AuthorGroupID}{}
  my ($AuthorGroupID) = @_;

  GetAuthors();

  my $group_list  = $dbh -> prepare(
     "select AuthorID from AuthorGroupList where AuthorGroupID = ?"); 
  $group_list -> execute($AuthorGroupID);
  $group_list -> bind_columns(undef, \($AuthorID));
 
  %AuthorsInGroup = ();

  while ($group_list -> fetch) {
    $AuthorsInGroup{$AuthorID}{AUTHORID}  =  $AuthorID;
    $AuthorsInGroup{$AuthorID}{FULLNAME}  = $Authors{$AuthorID}{FULLNAME}; 
    $AuthorsInGroup{$AuthorID}{Formal}    = $Authors{$AuthorID}{Formal};
    $AuthorsInGroup{$AuthorID}{LastName}      = $Authors{$AuthorID}{LastName};
    $AuthorsInGroup{$AuthorID}{FirstName}     = $Authors{$AuthorID}{FirstName};
    $AuthorsInGroup{$AuthorID}{ACTIVE}        = $Authors{$AuthorID}{ACTIVE};
    $AuthorsInGroup{$AuthorID}{InstitutionID} = $Authors{$AuthorID}{InstitutionID}; 
  }

  %Authors = ();
  %Authors = %AuthorsInGroup;

}

sub GetAuthorGroupList{ # Creates/fills a hash $AuthorGroups{$AuthorGroupID}{}
  my ($AuthorGroupID,$AuthorGroupName, $Description);
  my $group_list  = $dbh -> prepare(
     "select AuthorGroupID, AuthorGroupName, Description from AuthorGroupDefinition"); 
  $group_list -> execute;
  $group_list -> bind_columns(undef, \($AuthorGroupID, $AuthorGroupName, $Description));
  %AuthorGroups = ();
  while ($group_list -> fetch) {
    $AuthorGroups{$AuthorGroupID}{AuthorGroupID}   = $AuthorGroupID;
    $AuthorGroups{$AuthorGroupID}{AuthorGroupName} = $AuthorGroupName;
    $AuthorGroups{$AuthorGroupID}{Description}     = $Description;
  }
}

sub FetchAuthor { # Fetches an Author by ID, adds to $Authors{$AuthorID}{}
  my ($authorID) = @_;
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID);

  my $author_fetch  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active,InstitutionID ". 
     "from Author ". 
     "where AuthorID=?");
  if ($Authors{$authorID}{AUTHORID}) { # We already have this one
    return $Authors{$authorID}{AUTHORID};
  }
  
  $author_fetch -> execute($authorID);
  ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active,$InstitutionID) = $author_fetch -> fetchrow_array;
  $Authors{$AuthorID}{AUTHORID}  =  $AuthorID;
  if ($MiddleInitials) {
    $Authors{$AuthorID}{FULLNAME}  = "$FirstName $MiddleInitials $LastName";
    $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName $MiddleInitials";
  } else {
    $Authors{$AuthorID}{FULLNAME}  = "$FirstName $LastName";
    $Authors{$AuthorID}{Formal}    = "$LastName, $FirstName";
  }
  $Authors{$AuthorID}{LastName}      = $LastName;
  $Authors{$AuthorID}{FirstName}     = $FirstName;
  $Authors{$AuthorID}{ACTIVE}        = $Active;
  $Authors{$AuthorID}{InstitutionID} = $InstitutionID;
  
  return $Authors{$AuthorID}{AUTHORID};
}

sub FetchAuthorGroup { # Fetches an Author by ID, adds to $AuthorGroups{$AuthorGroupID}{}
  my ($authorGroupID) = @_;
  my ($AuthorGroupID,$AuthorGroupName, $Description);

  my $authorgroup_fetch  = $dbh -> prepare(
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


sub FetchAuthorGroups { # Fetches all AuthorGroups and adds to $AuthorGroups{$AuthorGroupID}{}

  if ($HaveAllAuthorGroups) {
      return;
  }
  my ($AuthorGroupID,$AuthorGroupName, $Description);

  my $list = $dbh -> prepare(
     "select AuthorGroupID, AuthorGroupName, Description from AuthorGroupDefinition "); 
  $list -> execute;
  $list -> bind_columns(undef, \($AuthorGroupID,$AuthorGroupName, $Description));

  %AuthorGroups = ();

  while ($list -> fetch) {
      $AuthorGroups{$AuthorGroupID}{AuthorGroupID}   = $AuthorGroupID;
      $AuthorGroups{$AuthorGroupID}{AuthorGroupName} = $AuthorGroupName;
      $AuthorGroups{$AuthorGroupID}{Description}     = $Description;
  }
  
  $HaveAllAuthorGroups = 1;

}

sub GetAuthorList {
  my ($DocRevID) = @_;
  my @AuthorIDs = ();
  my ($AuthorID);

  my $AuthorList = $dbh->prepare(
    "select AuthorID from RevisionAuthor where DocRevID=?");
  $AuthorList -> execute($DocRevID);
  $AuthorList -> bind_columns(undef, \($AuthorID));
  while ($AuthorList -> fetch) {
    push @AuthorIDs,$AuthorID;
  }

  return @AuthorIDs;  
};

sub GetRevisionAuthors {
  my ($DocRevID) = @_;
  my @RevAuthorIDs = ();
  my ($RevAuthorID,$AuthorID,$AuthorOrder);
  my $AuthorList = $dbh->prepare(
    "select RevAuthorID,AuthorID,AuthorOrder from RevisionAuthor where DocRevID=?");
  $AuthorList -> execute($DocRevID);
  $AuthorList -> bind_columns(undef, \($RevAuthorID,$AuthorID,$AuthorOrder));
  while ($AuthorList -> fetch) {
    $RevisionAuthors{$RevAuthorID}{AuthorID}    = $AuthorID;
    $RevisionAuthors{$RevAuthorID}{AuthorOrder} = $AuthorOrder;    
    push @RevAuthorIDs,$RevAuthorID;
  }
# Roy Williams Nov 2010 %%%
#  @RevAuthorIDs = Unique(@RevAuthorIDs);
  @RevAuthorIDs = OrderPreservingUnique(@RevAuthorIDs);
  return @RevAuthorIDs;  
};

sub GetRevisionAuthorGroups {
  my ($DocRevID) = @_;

  my @RevAuthorGroupIDs = ();
  my ($RevAuthorGroupID,$AuthorGroupID);
  my $AuthorGroupList = $dbh->prepare(
    "select RevAuthorGroupID,AuthorGroupID from RevisionAuthorGroup where DocRevID=?");
  $AuthorGroupList -> execute($DocRevID);
  $AuthorGroupList -> bind_columns(undef, \($RevAuthorGroupID,$AuthorGroupID));

  while ($AuthorGroupList -> fetch) {

    $RevisionAuthorGroups{$RevAuthorGroupID}{AuthorGroupID}    = $AuthorGroupID;
    push @RevAuthorGroupIDs,$RevAuthorGroupID;
  }
  @RevAuthorGroupIDs = Unique(@RevAuthorGroupIDs);
  return @RevAuthorGroupIDs;  
}

sub GetAuthorGroups {
  my ($DocRevID) = @_;

  my @AuthorGroupIDs = ();
  my ($RevAuthorGroupID,$AuthorGroupID);
  my $AuthorGroupList = $dbh->prepare(
    "select RevAuthorGroupID,AuthorGroupID from RevisionAuthorGroup where DocRevID=?");
  $AuthorGroupList -> execute($DocRevID);
  $AuthorGroupList -> bind_columns(undef, \($RevAuthorGroupID,$AuthorGroupID));

  while ($AuthorGroupList -> fetch) {
    $RevisionAuthorGroups{$RevAuthorGroupID}{AuthorGroupID}    = $AuthorGroupID;
    push @AuthorGroupIDs,$AuthorGroupID;
  }
  @AuthorGroupIDs = Unique(@AuthorGroupIDs);
  return @AuthorGroupIDs;  
}

sub GetAuthorsFromAuthorGroup {
  my ($AuthorGroupID) = @_;

  my @AuthorIDs = ();

  my ($AuthorID);
  my $AuthorList = $dbh->prepare(
    "select AuthorID from AuthorGroupList where AuthorGroupID=?");
  $AuthorList -> execute($AuthorGroupID);
  $AuthorList -> bind_columns(undef, \($AuthorID));

  while ($AuthorList -> fetch) {
    push @AuthorIDs,$AuthorID;
  }
  @AuthorIDs = Unique(@AuthorIDs);
  return @AuthorIDs;  
}

sub GetAllRevisionAuthors {
  my ($DocRevID) = @_;
  my @RevAuthorIDs = ();
  my @RevAuthorGroupIDs  = ();
  
  #First get all the authors from the 
  @RevAuthorIDs = GetRevisionAuthors($DocRevID);
  @RevAuthorGroupIDs = GetRevisionAuthorGroups($DocRevID);
  
  foreach my $AuthorGroup (@RevAuthorGroupIDs) {
      my @RevAuthorIDsFromGroup = ();
      @RevAuthorIDsFromGroup = GetAuthorsFromAuthorGroup($AuthorGroup);
      push @RevAuthorIDs, @RevAuthorIDsFromGroup;
  }

  @RevAuthorIDs = Unique(@RevAuthorIDs);
  return @RevAuthorIDs;  
}


sub GetInstitutionAuthors { # Creates/fills a hash $Authors{$AuthorID}{} with authors from institution
  my ($InstitutionID) = @_;
  
  #FIXME: Make it call GetAuthor
  
  my @AuthorIDs = ();
  my ($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active);
  my $PeopleList  = $dbh -> prepare(
     "select AuthorID,FirstName,MiddleInitials,LastName,Active ".
     "from Author where InstitutionID=?"); 
  $PeopleList -> execute($InstitutionID);
  $PeopleList -> bind_columns(undef, \($AuthorID,$FirstName,$MiddleInitials,$LastName,$Active));
  while ($PeopleList -> fetch) {
    push @AuthorIDs,$AuthorID;
    $Authors{$AuthorID}{AUTHORID}   =  $AuthorID;
    if ($MiddleInitials) {
      $Authors{$AuthorID}{FULLNAME} = "$FirstName $MiddleInitials $LastName";
      $Authors{$AuthorID}{Formal}   = "$LastName, $FirstName $MiddleInitials";
    } else {
      $Authors{$AuthorID}{FULLNAME} = "$FirstName $LastName";
      $Authors{$AuthorID}{Formal}   = "$LastName, $FirstName";
    }
    $Authors{$AuthorID}{LastName}      =  $LastName;
    $Authors{$AuthorID}{FirstName}     =  $FirstName;
    $Authors{$AuthorID}{ACTIVE}        =  $Active;
    $Authors{$AuthorID}{InstitutionID} =  $InstitutionID;
  }
  return @AuthorIDs;
}

sub GetInstitutions { # Creates/fills a hash $Institutions{$InstitutionID}{} with all Institutions
  if ($HaveAllInstitutions) {
    return;
  }  

  my ($InstitutionID,$ShortName,$LongName);
  my $inst_list  = $dbh -> prepare(
     "select InstitutionID,ShortName,LongName from Institution"); 
  $inst_list -> execute;
  $inst_list -> bind_columns(undef, \($InstitutionID,$ShortName,$LongName));
  %Institutions = ();
  while ($inst_list -> fetch) {
    $Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
    $Institutions{$InstitutionID}{SHORT}         = $ShortName;
    $Institutions{$InstitutionID}{LONG}          = $LongName;
  }
  $HaveAllInstitutions = 1;
}

sub FetchInstitution { # Creates/fills a hash $Institutions{$InstitutionID}{} with all Institutions
  my ($InstitutionID) = @_;
  if ($Institutions{$InstitutionID}{InstitutionID}) {
    return;
  }  
  
  my ($ShortName,$LongName);
  my $InstitutionFetch  = $dbh -> prepare(
     "select ShortName,LongName from Institution where InstitutionID=?"); 
  $InstitutionFetch -> execute($InstitutionID);
  ($ShortName,$LongName) = $InstitutionFetch -> fetchrow_array;
  $Institutions{$InstitutionID}{InstitutionID} = $InstitutionID;
  $Institutions{$InstitutionID}{SHORT}         = $ShortName;
  $Institutions{$InstitutionID}{LONG}          =  $LongName;
}

sub GetExplicitAuthorDocuments($) { # Return a list of all documents the author is associated with
  require "RevisionSQL.pm";
  
  my ($AuthorID) = @_;   # FIXME: Using join, can simplify into one SQL statement?

  my $List = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from ".
              "DocumentRevision,RevisionAuthor where DocumentRevision.DocRevID=RevisionAuthor.DocRevID ".
              "and DocumentRevision.Obsolete=0 and RevisionAuthor.AuthorID=?"); 
  $List -> execute($AuthorID);
  
  my @DocumentIDs = ();
  my $DocumentID;
  $List -> bind_columns(undef, \($DocumentID));
  while ($List -> fetch) {
    push @DocumentIDs,$DocumentID;
  }

  return @DocumentIDs;
}  


sub GetAuthorDocuments($) { # Return a list of all documents the author is associated with
  require "RevisionSQL.pm";
  
  my ($AuthorID) = @_;   # FIXME: Using join, can simplify into one SQL statement?

  my $List = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from ".
              "DocumentRevision,RevisionAuthor where DocumentRevision.DocRevID=RevisionAuthor.DocRevID ".
              "and DocumentRevision.Obsolete=0 and RevisionAuthor.AuthorID=?"); 
  $List -> execute($AuthorID);
  
  my @DocumentIDs = ();
  my $DocumentID;
  $List -> bind_columns(undef, \($DocumentID));
  while ($List -> fetch) {
    push @DocumentIDs,$DocumentID;
  }

  my @AuthorGroups = ();

  my $groupList = $dbh -> prepare(
    "select AuthorGroupID from AuthorGroupList where AuthorID=?");
  $groupList -> execute($AuthorID);
  $groupList -> bind_columns(undef, \($AuthorGroupID));

  while ($groupList -> fetch) {
    push @AuthorGroups,$AuthorGroupID;
  }

  foreach  my $RevAuthorGroup (@AuthorGroups) { 
      my $doclist = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from ".
              "DocumentRevision,RevisionAuthorGroup where DocumentRevision.DocRevID=RevisionAuthorGroup.DocRevID ".
              "and DocumentRevision.Obsolete=0 and RevisionAuthorGroup.AuthorGroupID=?"); 
      $doclist -> execute($RevAuthorGroup);
  
      my $DocumentID;
      $doclist -> bind_columns(undef, \($DocumentID));
      while ($doclist -> fetch) {
         push @DocumentIDs,$DocumentID;
      }
  }

  @DocumentIDs = Unique(@DocumentIDs);

  return @DocumentIDs;
}  
 

sub GetAuthorDocuments_NoGroups($) { # Return a list of all documents the author is associated with
  require "RevisionSQL.pm";
  
  my ($AuthorID) = @_;   # FIXME: Using join, can simplify into one SQL statement?

  my $List = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from ".
              "DocumentRevision,RevisionAuthor where DocumentRevision.DocRevID=RevisionAuthor.DocRevID ".
              "and DocumentRevision.Obsolete=0 and RevisionAuthor.AuthorID=?"); 
  $List -> execute($AuthorID);
  
  my @DocumentIDs = ();
  my $DocumentID;
  $List -> bind_columns(undef, \($DocumentID));
  while ($List -> fetch) {
    push @DocumentIDs,$DocumentID;
  }

  return @DocumentIDs;
}  
 
sub GetAuthorGroupDocuments { # Return a list of all documents the author is associated with
  require "RevisionSQL.pm";
  
  my ($AuthorGroupID) = @_;   

  my $List = $dbh -> prepare("select DISTINCT(DocumentRevision.DocumentID) from ".
              "DocumentRevision,RevisionAuthorGroup ".
              "where DocumentRevision.DocRevID=RevisionAuthorGroup.DocRevID ".
              "and DocumentRevision.Obsolete=0 and RevisionAuthorGroup.AuthorGroupID=?"); 
  $List -> execute($AuthorGroupID);
  
  my @DocumentIDs = ();
  my $DocumentID;
  $List -> bind_columns(undef, \($DocumentID));
  while ($List -> fetch) {
    push @DocumentIDs,$DocumentID;
  }

  @DocumentIDs = Unique(@DocumentIDs);

  return @DocumentIDs;
}  

sub ProcessManualAuthors {
  my ($author_list,$ArgRef) = @_;
  my $Warn = exists $ArgRef->{-warn} ? $ArgRef->{-warn} : $FALSE;

  my $AuthorID;
  my @AuthorIDs = ();
  my @AuthorEntries = split /\n/,$author_list;
  
  # Fixed parsing of Roy's text-based author list
  # Phil Ehrens - January 6, 2011.
  foreach my $entry (@AuthorEntries) {
    my @parts = split /,/,$entry;
    # strip all the nasty leading and trailing spaces!
    my $last   = shift @parts;
    $last =~ s/^\s+//;
    $last =~ s/\s+$//;
    my $first  = shift @parts;
    $first =~ s/^\s+//;
    $first =~ s/\s+$//; 
#    my $initial = pop @parts;
#    $initial =~ s/^\s+//;
#    $initial =~ s/\s+$//;
    
    # skip blank lines 
    unless ($first || $last) { next };
    
    # do a fairly weak bad character test.
    my $test ="$first $last";
    if ($test =~ /[\~\`\!\$\%\^\*\{\}\?\;\:\=\<\>]/) {
      if ($Warn) {
        push @WarnStack, "Your author entry \'$entry\' has unexpected characters.";
      } else {      
        push @ErrorStack,"Your author entry \'$entry\' has unexpected characters.";
      }                   
      next;  
    }
 
    my $author_list_query = "select AuthorID from Author where FirstName = \"$first\" and LastName = \"$last\""; 
    my $author_list = $dbh -> prepare($author_list_query);
    my $fuzzy_list_query = "select AuthorID from Author where FirstName LIKE (\"$first%\") and LastName LIKE (\"$last%\")"; 
    my $fuzzy_list = $dbh -> prepare($fuzzy_list_query);


### Find exact match (initial or full name)

    $author_list -> execute() || die("\$!, ProcessManualAuthors");
    $author_list -> bind_columns(undef, \($AuthorID));
    @Matches = ();
    while ($author_list -> fetch) {
      push @Matches,$AuthorID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @AuthorIDs,$AuthorID;
      next;
    }
    
### Match initial if given initial or full name    
#    $author_list -> execute($initial,$last);   Bad Code!
#    $author_list -> execute();         # should be
#    $author_list -> bind_columns(undef, \($AuthorID));
#    @Matches = ();
#    while ($author_list -> fetch) {
#      push @Matches,$AuthorID;
#    }
#    if ($#Matches == 0) { # Found 1 exact match
#      push @AuthorIDs,$AuthorID;
#      next;
#    }
    
### Match full name if given initial
    
    $first =~ s/\.//g;    # Remove dots if any  
#    $first .= "%";        # Add SQL wildcard  # yes but already put in up there
    $fuzzy_list -> execute() || die("\$!, ProcessManualAuthors");   
    $fuzzy_list -> bind_columns(undef, \($AuthorID));
    @Matches = ();
    while ($fuzzy_list -> fetch) {
      push @Matches,$AuthorID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @AuthorIDs,$AuthorID;
      next;
    }
    
### Haven't found a match if we get down here

# FIXME: Remove error_stack when modifications done. 

    if ($Warn) {
      push @WarnStack, "No match was found for the author $entry.";
    } else {      
      push @ErrorStack,"No match was found for the author $entry, first name: $first, last name: $last. Please go back and try again.";
    }                   
  }
  return @AuthorIDs;
}

sub GetAuthorFromNames {
  my ($author_list,$ArgRef) = @_;
  my $Warn = exists $ArgRef->{-warn} ? $ArgRef->{-warn} : $FALSE;

  my $AuthorID;
  my @AuthorIDs = ();
  my @AuthorEntries = split /\n/,$author_list;
  
  # Fixed parsing of Roy's text-based author list
  # Phil Ehrens - January 6, 2011.
  foreach my $entry (@AuthorEntries) {
    push @ErrorStack, "$entry";
    my @parts = split("  ",$entry);
    # strip all the nasty leading and trailing spaces!
    my $last   = shift @parts;
    $last =~ s/^\s+//;
    $last =~ s/\s+$//;
    my $first  = shift @parts;
    $first =~ s/^\s+//;
    $first =~ s/\s+$//; 
#    my $initial = pop @parts;
#    $initial =~ s/^\s+//;
#    $initial =~ s/\s+$//;
    
    # skip blank lines 
    unless ($first || $last) { next };
    
    # do a fairly weak bad character test.
    my $test ="$first $last";
    if ($test =~ /[\~\`\!\$\%\^\*\{\}\?\;\:\=\<\>]/) {
      if ($Warn) {
        push @WarnStack, "Your author entry \'$entry\' has unexpected characters.";
      } else {      
        push @ErrorStack,"Your author entry \'$entry\' has unexpected characters.";
      }                   
      next;  
    }
 
    my $author_list_query = "select AuthorID from Author where FirstName = \"$first\" and LastName = \"$last\""; 
    my $author_list = $dbh -> prepare($author_list_query);
    my $fuzzy_list_query = "select AuthorID from Author where FirstName LIKE (\"$first%\") and LastName LIKE (\"$last%\")"; 
    my $fuzzy_list = $dbh -> prepare($fuzzy_list_query);


### Find exact match (initial or full name)

    $author_list -> execute() || die("\$!, ProcessManualAuthors");
    $author_list -> bind_columns(undef, \($AuthorID));
    @Matches = ();
    while ($author_list -> fetch) {
      push @Matches,$AuthorID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @AuthorIDs,$AuthorID;
      next;
    }
    
### Match initial if given initial or full name    
#    $author_list -> execute($initial,$last);   Bad Code!
#    $author_list -> execute();         # should be
#    $author_list -> bind_columns(undef, \($AuthorID));
#    @Matches = ();
#    while ($author_list -> fetch) {
#      push @Matches,$AuthorID;
#    }
#    if ($#Matches == 0) { # Found 1 exact match
#      push @AuthorIDs,$AuthorID;
#      next;
#    }
    
### Match full name if given initial
    
    $first =~ s/\.//g;    # Remove dots if any  
#    $first .= "%";        # Add SQL wildcard  # yes but already put in up there
    $fuzzy_list -> execute() || die("\$!, ProcessManualAuthors");   
    $fuzzy_list -> bind_columns(undef, \($AuthorID));
    @Matches = ();
    while ($fuzzy_list -> fetch) {
      push @Matches,$AuthorID;
    }
    if ($#Matches == 0) { # Found 1 exact match
      push @AuthorIDs,$AuthorID;
      next;
    }
    
### Haven't found a match if we get down here

# FIXME: Remove error_stack when modifications done. 

    if ($Warn) {
      push @WarnStack, "No match was found for the author $entry.";
    } else {      
      push @ErrorStack,"No match was found for the author $entry, first name: $first, last name: $last. Please go back and try again.";
    }                   
  }
  return @AuthorIDs;
}

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#sub SearchManualAuthors {
#  my ($author_list,$ArgRef) = @_;
#  my $Warn = exists $ArgRef->{-warn} ? $ArgRef->{-warn} : $FALSE;
#
#  my $AuthorID;
#  my @AuthorIDs = ();
#  my @AuthorEntries = split /\n/,$author_list;
#
#  my $author_list = $dbh -> prepare( "select AuthorID, FullName from Author "); 
#    $author_list -> execute($first,$last);
#    $author_list -> bind_columns(undef, \($AuthorID));
#    @Matches = ();
#    while ($author_list -> fetch) {
#      push @Authors,$AuthorID;
#    }
#  
#  foreach my $entry (@AuthorEntries) {
#
#      push @AuthorIDs,$AuthorID;
#    
#    if ($Warn) {
#      push @WarnStack, "No match was found for the author $entry.";
#    } else {      
#      push @ErrorStack,"No match was found for the author $entry. Please go back and try again.";
#    }                   
#  }
#  return @AuthorIDs;
#}
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%




sub MatchAuthor ($) {
  my ($ArgRef) = @_;
  my $Either = exists $ArgRef->{-either} ? $ArgRef->{-either} : "";
#  my $First = exists $ArgRef->{-first}  ? $ArgRef->{-first}  : "";
#  my $Last  = exists $ArgRef->{-last}   ? $ArgRef->{-last}   : "";
  
  my $AuthorID;
  my @MatchIDs = ();
  if ($Either) {
    $Either =~ tr/[A-Z]/[a-z]/;
    my $List = $dbh -> prepare(
       "select AuthorID from Author where LOWER(FirstName) like \"%$Either%\" or LOWER(LastName) like \"%$Either%\""); 
    $List -> execute();
    $List -> bind_columns(undef, \($AuthorID));
    while ($List -> fetch) {
      push @MatchIDs,$AuthorID;
    }
  }

#  @MatchIDs = &GetAuthorDocuments($AuthorID);
#  @MatchIDs = Unique(@MatchIDs);
  return @MatchIDs;
}

sub MatchAuthor_NoGroups ($) {
  my ($ArgRef) = @_;
  my $Either = exists $ArgRef->{-either} ? $ArgRef->{-either} : "";
#  my $First = exists $ArgRef->{-first}  ? $ArgRef->{-first}  : "";
#  my $Last  = exists $ArgRef->{-last}   ? $ArgRef->{-last}   : "";
  
  my $AuthorID;
  my @MatchIDs = ();
  if ($Either) {
    $Either =~ tr/[A-Z]/[a-z]/;
    my $List = $dbh -> prepare(
       "select AuthorID from Author where LOWER(FirstName) like \"%$Either%\" or LOWER(LastName) like \"%$Either%\""); 
    $List -> execute();
    $List -> bind_columns(undef, \($AuthorID));
    while ($List -> fetch) {
      push @MatchIDs,$AuthorID;
    }
  }

#  @MatchIDs = &GetAuthorDocuments_NoGroups($AuthorID);
#  @MatchIDs = Unique(@MatchIDs);
  return @MatchIDs;
}

sub InsertAuthors (%) {
  my %Params = @_;
  
  my $DocRevID  =   $Params{-docrevid}   || "";   
  my $Order     =   $Params{-order}      || $FALSE;   
  my @AuthorIDs = @{$Params{-authorids}};

# Roy Williams Nov 2010 %%%
#  @AuthorIDs = Unique(@AuthorIDs);
  @AuthorIDs = OrderPreservingUnique(@AuthorIDs);

  my $Count       = 0;
  my $AuthorOrder = 0;
  my $Insert = $dbh->prepare("insert into RevisionAuthor (RevAuthorID, DocRevID, AuthorID, AuthorOrder) values (0,?,?,?)");
                                 
  foreach my $AuthorID (@AuthorIDs) {
    if ($AuthorID) {
      if ($Order) {
        $AuthorOrder = $Count;
      }  
      $Insert -> execute($DocRevID,$AuthorID,$AuthorOrder);
      ++$Count;
    }
  }  
      
  return $Count;
}


sub InsertAuthorGroups (%) {
  my %Params = @_;
  
  my $DocRevID  =   $Params{-docrevid}   || "";   
  my @AuthorGroupIDs = @{$Params{-authorgroupids}};

  @AuthorGroupIDs = Unique(@AuthorGroupIDs);

  my $Count       = 0;
  my $Insert = $dbh->prepare("insert into RevisionAuthorGroup (RevAuthorGroupID, DocRevID, AuthorGroupID) values (0,?,?)");
                                 
  foreach my $AuthorGroupID (@AuthorGroupIDs) {
    if ($AuthorGroupID) {
      $Insert -> execute($DocRevID,$AuthorGroupID);
      ++$Count;
    }
  }  
      
  return $Count;
}

#########################
sub FetchEmail (%) {
  my ($RequesterID) = @_;

  my $get_email = $dbh->prepare("select EmailAddress from EmailUser where AuthorID=?");
  $get_email->execute($RequesterID);
  $get_email->bind_columns(undef, \($EmailAddress));
  @EmailAddress = ();
  while ($get_email->fetch) {
    push @EmailAddress,$EmailAddress;
  }
  return $EmailAddress[0]; 
}

sub GetAuthorEmail (%) {
  my ($AuthorID) = @_;

  my $get_email2 = $dbh->prepare("select EmailAddress from EmailUser where AuthorID=?");
  $get_email2->execute($AuthorID);
  $get_email2->bind_columns(undef, \($EmailAddress));
  @EmailAddress = ();
  while ($get_email2->fetch) {
    push @EmailAddress,$EmailAddress;
  }
    return $EmailAddress[0];
}
#########################

1;
