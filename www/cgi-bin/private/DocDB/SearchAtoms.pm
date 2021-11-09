#        Name: $RCSfile: SearchAtoms.pm,v $
# Description: Bits of code to do various searches. Some specific, some generic

#    Revision: $Revision: 1.6.12.7 $
#    Modified: $Author: vondo $ on $Date: 2007/10/30 02:51:51 $
#
# Author Eric Vaandering (ewv@fnal.gov)

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

%SearchWeights = ( # These weights are used to order documents from the simple search
                  "Number"          => 4,
                  "Author"          => 4,
                  "Topic"           => 3,
                  "DocType"         => 2,
                  "Event"           => 3,
                  "EventGroup"      => 2,
                  "File"            => 3,
                  "FileContent"     => 1,
                  "Revision"        => 3,
#                  "Title"           => 4,
#                  "Abstract"        => 3,
#                  "Keyword"         => 3,
#                  "RevisionNote"    => 2,
#                  "PubInfo"         => 3,
#                  "Age"             => 1, #  * (1-Age/MaxAge)
              );

sub TextSearch {
  my ($Field,$SearchMode,$Words) = @_;

  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();

  if ($SearchMode eq "anysub" || $SearchMode eq "allsub" || $SearchMode eq "anyword" || $SearchMode eq "allword") {
    my @Words = split /\s+/,$Words;
    foreach my $Word (@Words) {
      if ($SearchMode eq "anysub" || $SearchMode eq "allsub") {
        $Word =~ tr/[A-Z]/[a-z]/;
        push @Atoms,"LOWER($Field) like \"%$Word%\"";
      } elsif ($SearchMode eq "anyword" || $SearchMode eq "allword") {
        $Word =~ tr/[A-Z]/[a-z]/;
        push @Atoms,"LOWER($Field) REGEXP \"\[\[:<:\]\]$Word\[\[:>:\]\]\"";
      }
    }
  }

  if      ($SearchMode eq "anysub" || $SearchMode eq "anyword") {
    $Join = " OR ";
  } elsif ($SearchMode eq "allsub" || $SearchMode eq "allword") {
    $Join = " AND ";
  }

  $Phrase = join $Join,@Atoms;

  if ($Phrase) {$Phrase = "($Phrase)";}

  return $Phrase;
}

sub IDSearch {
  my ($Table,$Field,$SearchMode,@IDs) = @_;

  my $Phrase = "";
  my $Join;
  my $Delimit;
  my @Atoms = ();

  $Join = $SearchMode;

  foreach $ID (@IDs) {
    push @Atoms," $Field=$ID ";
  }

  $Phrase = join $Join,@Atoms;

  if ($Phrase) {$Phrase = "($Phrase)";}

  return $Phrase;
}

sub TopicSearch ($) {
  my ($ArgRef) = @_;

  my $Logic      = exists $ArgRef->{-logic}     ?   $ArgRef->{-logic}     : "AND";
  my $SubTopics  = exists $ArgRef->{-subtopics} ?   $ArgRef->{-subtopics} : $FALSE;
  my @InitialIDs = exists $ArgRef->{-topicids}  ? @{$ArgRef->{-topicids}} : ();

  require "TopicUtilities.pm";
  require "Utilities.pm";
  require "Sorts.pm";

  if ($Logic eq "AND" && $SubTopics) { # Break up and call recursively
    my %Revisions = ();
    foreach my $TopicID (@InitialIDs) {
      my %TopicRevisions = ();
      my @ChildIDs  = TopicAndSubTopics({-topicid => $TopicID});
      my @Revisions = TopicSearch({-logic => "OR", -topicids => \@ChildIDs});
      @Revisions = Unique(@Revisions);
      foreach my $DocRevID (@Revisions) {
        ++$Revisions{$DocRevID};
      }
    }
    my @Revisions = ();
    foreach my $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == scalar(@InitialIDs)) {
        push @Revisions,$DocRevID;
      }
    }
    return @Revisions;
  }

  # Other cases handled non-recursively

  my $List = $dbh -> prepare("select DocRevID from RevisionTopic where TopicID=?");

  my @TopicIDs = ();
  my @Revisions = ();
  my %Revisions = ();

  if ($Logic eq "OR" && $SubTopics) {
    foreach my $TopicID (@InitialIDs) {
      my @ChildIDs = TopicAndSubTopics({-topicid => $TopicID});
      push @TopicIDs,@ChildIDs;
    }
    @TopicIDs = Unique(@TopicIDs);
  } else {
    @TopicIDs = @InitialIDs;
  }

  foreach $TopicID (@TopicIDs) {
    $List -> execute($TopicID );
    $List -> bind_columns(undef, \($DocRevID));
    my %TopicRevisions = ();
    while ($List -> fetch) { # Make sure each topic only matches once
      ++$TopicRevisions{$DocRevID};
    }
    foreach $DocRevID (keys %TopicRevisions) {
      ++$Revisions{$DocRevID};
    }
  }

  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == $#TopicIDs+1) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }
  return @Revisions;
}

sub EventSearch {
  my $List;
  my ($Logic,$Type,@IDs) = @_;
  if ($Type eq "event") {
    $List = $dbh -> prepare("select DocRevID from RevisionEvent where ConferenceID=?");
  } elsif ($Type eq "group") {
    $List = $dbh -> prepare(
      "select DocRevID from RevisionEvent,Conference ".
      "where RevisionEvent.ConferenceID=Conference.ConferenceID ".
      "and Conference.EventGroupID=?");
  }

  my %Revisions = ();
  my @Revisions = ();
  my $DocRevID;

  foreach $ID (@IDs) {
    $List -> execute($ID);
    $List -> bind_columns(undef, \($DocRevID));
    my %EventRevisions = ();
    while ($List -> fetch) { # Make sure each event only matches once
      ++$EventRevisions{$DocRevID};
    }
    foreach $DocRevID (keys %EventRevisions) {
      ++$Revisions{$DocRevID};
    }
  }
  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == scalar(@IDs)) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }

  return @Revisions;
}

sub AuthorSearch {
  my ($Logic,$IncludeAuthorGroups,@AuthorIDs) = @_;

  my $revtopic_list;
  $revauthor_list = $dbh -> prepare("select DocRevID from RevisionAuthor where AuthorID=?");


  my %Revisions = ();
  my @Revisions = ();
  my $DocRevID;

  foreach my $AuthorID (@AuthorIDs) {
    $revauthor_list -> execute($AuthorID);
    $revauthor_list -> bind_columns(undef, \($DocRevID));
    while ($revauthor_list -> fetch) {
      ++$Revisions{$DocRevID};
    }
 
    if ($IncludeAuthorGroups) {
        my @AuthorGroups = ();

        my $groupList = $dbh -> prepare(
            "select AuthorGroupID from AuthorGroupList where AuthorID=?");
        $groupList -> execute($AuthorID);
        $groupList -> bind_columns(undef, \($AuthorGroupID));
 
        while ($groupList -> fetch)  { 
          my $doclist = $dbh -> prepare("select  DocRevID from RevisionAuthorGroup where AuthorGroupID=?");
          $doclist -> execute($AuthorGroupID);
  
          $doclist -> bind_columns(undef, \($DocRevID));
          while ($doclist -> fetch) {
          ++$Revisions{$DocRevID};
          }
        }
    }
  }




  if ($Logic eq "AND") {
    foreach $DocRevID (keys %Revisions) {
      if ($Revisions{$DocRevID} == $#AuthorIDs+1) { # Require a match for each topic
        push @Revisions,$DocRevID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Revisions = keys %Revisions;
  }

  return @Revisions;
}

sub TypeSearch {
  my ($Logic,@TypeIDs) = @_;
  my $List = $dbh -> prepare("select DISTINCT(DocumentID) from DocumentRevision where DocTypeID=? and Obsolete=0");

  my %Documents = ();
  my @Documents = ();
  my $DocumentID;

  foreach my $TypeID (@TypeIDs) {
    $List -> execute($TypeID);
    $List -> bind_columns(undef, \($DocumentID));
    while ($List -> fetch) {
      ++$Documents{$DocumentID};
    }
  }
  if ($Logic eq "AND") {
    foreach $DocumentID (keys %Documents) {
      if ($Documents{$DocumentID} == scalar(@TypeIDs)) { # Require a match for each type
        push @Documents,$DocumentID;
      }
    }
  } elsif ($Logic eq "OR") {
    @Documents = keys %Documents;
  }

  return @Documents;
}

sub ValidateRevisions {
  require "RevisionSQL.pm";
  require "Security.pm";

  my (@RevisionIDs) = @_;
  my %DocumentIDs = ();
  my @DocumentIDs = ();

  foreach my $RevID (@RevisionIDs) {
    &FetchDocRevisionByID($RevID);
    unless ($DocRevisions{$RevID}{Obsolete}) { 
      if (CanAccessRevision($RevID)) {
          my $DocID = $DocRevisions{$RevID}{DOCID};
          $DocumentIDs{$DocID} = 1;
      }
    }
  }
  @DocumentIDs = keys %DocumentIDs;
  return @DocumentIDs;
}

sub AddSearchWeights ($) {
  my ($ArgRef) = @_;
  my @Numbers     = exists $ArgRef->{-numbers}     ? @{$ArgRef->{-numbers}}   : ();
  my @Revisions   = exists $ArgRef->{-revisions}   ? @{$ArgRef->{-revisions}}   : ();
  my @Topics      = exists $ArgRef->{-topics}      ? @{$ArgRef->{-topics}}      : ();
  my @Events      = exists $ArgRef->{-events}      ? @{$ArgRef->{-events}}      : ();
  my @EventGroups = exists $ArgRef->{-eventgroups} ? @{$ArgRef->{-eventgroups}} : ();
  my @Authors     = exists $ArgRef->{-authors}     ? @{$ArgRef->{-authors}}     : ();
  my @DocTypes    = exists $ArgRef->{-doctypes}    ? @{$ArgRef->{-doctypes}}    : ();
  my @Files       = exists $ArgRef->{-files}       ? @{$ArgRef->{-files}}       : ();
  my @Contents    = exists $ArgRef->{-contents}    ? @{$ArgRef->{-contents}}     : ();

  foreach my $DocumentID (@Revisions) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Numbers"};
  }
  foreach my $DocumentID (@Revisions) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Revision"};
  }
  foreach my $DocumentID (@Topics) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Topic"};
  }
  foreach my $DocumentID (@Events) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Event"};
  }
  foreach my $DocumentID (@EventGroups) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"EventGroup"};
  }
  foreach my $DocumentID (@Authors) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"Author"};
  }
  foreach my $DocumentID (@DocTypes) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"DocType"};
  }
  foreach my $DocumentID (@Files) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"File"};
  }
  foreach my $DocumentID (@Contents) {
     $Documents{$DocumentID}{Relevance} += $SearchWeights{"FileContent"};
  }
}

1;
