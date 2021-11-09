#        Name: $RCSfile: Search.pm,v $
# Description: Searching is done here, moved out of Search for XML
#              Three modes of presenting information:
#              1) mode=date (default, sorted by reverse date, modification date given)
#              2) mode=meeting (sorted by author, files are listed)
#              3) mode=conference (sorted by reverse date, conference fields shown)

#    Revision: $Revision: 1.1.4.6 $
#    Modified: $Author: vondo $ on $Date: 2007/12/31 16:03:23 $
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

sub LocalSearch ($) {
  my ($ArgRef) = @_;

  my %params    = exists $ArgRef->{-cgiparams} ? %{$ArgRef->{-cgiparams}} : ();
  my $NoXMLHead = exists $ArgRef->{-noxmlhead} ?   $ArgRef->{-noxmlhead}  : $FALSE;

  require "FSUtilities.pm";
  require "WebUtilities.pm";
  require "Utilities.pm";
  require "ResponseElements.pm";
  require "Security.pm";
  require "XMLOutput.pm";

  require "SearchAtoms.pm";

  require "AuthorSQL.pm";
  require "DocumentSQL.pm";
  require "MeetingSQL.pm";
  require "MiscSQL.pm";
  require "RevisionSQL.pm";
  require "SecuritySQL.pm";
  require "Security.pm";
  require "TopicSQL.pm";

  require "DocumentHTML.pm";

  require "DocumentUtilities.pm";

  ### Pull info out of params into local variables

  my $OutFormat = $params{outformat} || "HTML";

  $InnerLogic  = $params{innerlogic} || "OR";
  $OuterLogic  = $params{outerlogic} || "AND";

  $NumberSearch           = $params{numbersearch};
  $NumberSearchMode       = $params{numbersearchmode};
  $TitleSearch            = $params{titlesearch};
  $TitleSearchMode        = $params{titlesearchmode};
  $AbstractSearch         = $params{abstractsearch};
  $AbstractSearchMode     = $params{abstractsearchmode};
  $KeywordSearch          = $params{keywordsearch};
  $KeywordSearchMode      = $params{keywordsearchmode};
  $RevisionNoteSearch     = $params{revisionnotesearch};
  $RevisionNoteSearchMode = $params{revisionnotesearchmode};
  $PubInfoSearch          = $params{pubinfosearch};
  $PubInfoSearchMode      = $params{pubinfosearchmode};
  $FileSearch             = $params{filesearch};
  $FileSearchMode         = $params{filesearchmode};
  $FileDescSearch         = $params{filedescsearch};
  $FileDescSearchMode     = $params{filedescsearchmode};
  $FileContSearch         = $params{filecontsearch};
  $FileContSearchMode     = $params{filecontsearchmode};

  my $AuthorManual        = $params{authormanual};
     @RequesterSearchIDs  = split /\0/,$params{requestersearch};
     @AuthorSearchIDs     = split /\0/,$params{authors};
     @TypeSearchIDs       = split /\0/,$params{doctypemulti};

  my @TopicSearchIDs      = split /\0/,$params{topics};
  my $IncludeSubTopics    = $params{includesubtopics};
  if ($IncludeSubTopics) {
    $IncludeSubTopics = $TRUE;
  }

  push @DebugStack,"Searching for topics ".join ', ',@TopicSearchIDs;
  my @EventSearchIDs      = split /\0/,$params{events};
  my @EventGroupSearchIDs = split /\0/,$params{eventgroups};

  ### Parameters for simple search

  my $Simple     = $params{simple};
  my $SimpleText = $params{simpletext};

  ### Purify input (remove punctuation)

  $SimpleText         =~ s/[^\s\w+-\.]//go;
  $NumberSearch       =~ s/[^\s\w+-\.]//go;
  $TitleSearch        =~ s/[^\s\w+-\.]//go;
  $AbstractSearch     =~ s/[^\s\w+-\.]//go;
  $KeywordSearch      =~ s/[^\s\w+-\.]//go;
  $RevisionNoteSearch =~ s/[^\s\w+-\.]//go;
  $PubInfoSearch      =~ s/[^\s\w+-\.]//go;
  $FileSearch         =~ s/[^\s\w+-\.]//go;
  $FileDescSearch     =~ s/[^\s\w+-\.]//go;
  $FileContSearch     =~ s/[^\s\w+-\.]//go;

  GetTopics();
  GetSecurityGroups();

  $OutFormat =~ tr/[a-z]/[A-Z]/;
  if ($OutFormat eq 'XML') {
    unless ($NoXMLHead) {
      print XMLHeader();
    }
    NewXMLOutput();
  } else {
    print $query -> header( -charset => $HTTP_ENCODING );
    DocDBHeader("$Project Document Search Results","Search Results");
  }

  if ($SimpleText) { # Break up words and set parameters for rest of search
    @RequesterSearchIDs  = ();
    @AuthorSearchIDs     = ();
    @TypeSearchIDs       = ();
    @TopicSearchIDs      = ();
    @EventSearchIDs      = ();
    @EventGroupSearchIDs = ();
    @AliasSearchIDs      = ();

    my @Words = split /\s+/,$SimpleText;
    foreach my $Word (@Words) {
      push @AuthorSearchIDs    ,MatchAuthor(     {-either => $Word} );
      push @TypeSearchIDs      ,MatchDocType(    {-short  => $Word} );
      push @TopicSearchIDs     ,MatchTopic(      {-short  => $Word} );
      push @EventSearchIDs     ,MatchEvent(      {-short  => $Word} );
      push @EventGroupSearchIDs,MatchEventGroup( {-short  => $Word} );
    }
    @RequesterSearchIDs = @AuthorSearchIDs;

    $InnerLogic        = "OR";
    $OuterLogic        = "OR";
    $IncludeSubTopics  = $TRUE;

    $NumberSearch           = $SimpleText;
    $TitleSearch            = $SimpleText;
    $AbstractSearch         = $SimpleText;
    $KeywordSearch          = $SimpleText;
    $RevisionNoteSearch     = $SimpleText;
    $PubInfoSearch          = $SimpleText;
    $FileSearch             = $SimpleText;
    $FileDescSearch         = $SimpleText;
    $FileContSearch         = $SimpleText;
    $NumberSearchMode       = "anysub";
    $TitleSearchMode        = "anysub";
    $AbstractSearchMode     = "anysub";
    $KeywordSearchMode      = "anysub";
    $RevisionNoteSearchMode = "anysub";
    $PubInfoSearchMode      = "anysub";
    $FileSearchMode         = "anysub";
    $FileDescSearchMode     = "anysub";
    $FileContSearchMode     = "anysub";
  }

  if ($AuthorManual) { # Add these authors to list
    my @ManualAuthorIDs = ProcessManualAuthors($AuthorManual, {-warn => $TRUE} );
    if (@ManualAuthorIDs) {
      @AuthorSearchIDs = Unique(@AuthorSearchIDs,@ManualAuthorIDs);
    }
  }

  $Afterday   = $params{afterday};
  $Aftermonth = $params{aftermonth};
  $Afteryear  = $params{afteryear};
  if ($Afteryear && $Afteryear ne "----") {
    if ($Aftermonth eq "---") {$Aftermonth = "Jan";}
    if ($Afterday   eq "--")  {$Afterday   = "1";}
    $SQLBegin   = "$Afteryear-$ReverseAbrvMonth{$Aftermonth}-$Afterday";
  }

  $Beforeday   = $params{beforeday};
  $Beforemonth = $params{beforemonth};
  $Beforeyear  = $params{beforeyear};
  if ($Beforeyear && $Beforeyear ne "----") {
    if ($Beforemonth eq "---") {$Beforemonth = "Dec";}
    if ($Beforeday   eq "--")  {$Beforeday   = DaysInMonth($ReverseAbrvMonth{$Beforemonth},$Beforeyear);}
    $SQLEnd     = "$Beforeyear-$ReverseAbrvMonth{$Beforemonth}-$Beforeday";
  }

  my $Mode    = $params{mode};
  unless ($Mode eq "date" or $Mode eq "meeting" or $Mode eq "conference" or $Mode eq "title") {
    $Mode = "date";
  }

  ### Check parameters for errors

  my @DocumentIDs = ();
  my @DCCDocumentIDs = ();
  my @RevisionDocumentIDs = ();
  my @TopicDocumentIDs = ();
  my @ContentDocumentIDs = ();

  my ($SearchedNumbers,$SearchedRevisions,$SearchedTopics,$SearchedAuthors,$SearchedFiles,$SearchedTypes,$SearchedContent);

  unless ($InnerLogic eq "AND" || $InnerLogic eq "OR") {
    push @ErrorStack,"Inner logic must be either AND or OR.";
  }
  unless ($OuterLogic eq "AND" || $OuterLogic eq "OR") {
    push @ErrorStack,"Outer logic must be either AND or OR.";
  }

  if ($OutFormat eq 'HTML') {
    EndPage();
    print "<p>\n";
  }
  
  if ($NumberSearch) {
    $SearchedNumbers = 1;
    my $NumberPhrase  = TextSearch("Alias", $NumberSearchMode, $NumberSearch);
    my $DocumentQuery = "select DocumentID from Document where ";
    $DocumentQuery .= join $OuterLogic,$NumberPhrase;

    my %NumberDocumentIDs = ();
    my $document_list = $dbh -> prepare($DocumentQuery);
    $document_list -> execute();
    $document_list -> bind_columns(undef, \($DocumentID));

    while ($document_list -> fetch) {
       $NumberDocumentIDs{$DocumentID} = 1; # Hash removes duplicates
    }
    @DCCDocumentIDs = keys %NumberDocumentIDs;
  }

  if ($TitleSearch || $AbstractSearch || $KeywordSearch || $RevisionNoteSearch ||
      $PubInfoSearch || @RequesterSearchIDs || $SQLBegin    || $SQLEnd) {
    $SearchedRevisions = 1;
  ### Text search matches
    my $TitlePhrase        = TextSearch("DocumentTitle",  $TitleSearchMode,        $TitleSearch);
    my $AbstractPhrase     = TextSearch("Abstract",       $AbstractSearchMode,     $AbstractSearch);
    my $KeywordPhrase      = TextSearch("Keywords",       $KeywordSearchMode,      $KeywordSearch);
    my $RevisionNotePhrase = TextSearch("Note",           $RevisionNoteSearchMode, $RevisionNoteSearch);
    my $PubInfoPhrase      = TextSearch("PublicationInfo",$PubInfoSearchMode,      $PubInfoSearch);

  ### Other matches

    my $RequesterPhrase    = IDSearch("DocumentRevision","SubmitterID","OR",@RequesterSearchIDs);

    my $EndDatePhrase;
    my $StartDatePhrase;
    if ($SQLEnd) {
      $EndDatePhrase   = " RevisionDate<\"$SQLEnd\" ";
    }
    if ($SQLBegin) {
      $StartDatePhrase = " RevisionDate>\"$SQLBegin\" ";
    }

  ### Get Documents from DocumentRevision that match

    my @RevisionPhrases = ();
    my $RevisionQuery   = "select DocumentID,DocRevID from DocumentRevision where Obsolete=0 and ";

    if ($TitlePhrase       ) {push @RevisionPhrases,$TitlePhrase       ;}
    if ($AbstractPhrase    ) {push @RevisionPhrases,$AbstractPhrase    ;}
    if ($KeywordPhrase     ) {push @RevisionPhrases,$KeywordPhrase     ;}
    if ($RevisionNotePhrase) {push @RevisionPhrases,$RevisionNotePhrase;}
    if ($PubInfoPhrase     ) {push @RevisionPhrases,$PubInfoPhrase     ;}
    if ($RequesterPhrase   ) {push @RevisionPhrases,$RequesterPhrase   ;}
    if ($EndDatePhrase     ) {push @RevisionPhrases,$EndDatePhrase     ;}
    if ($StartDatePhrase   ) {push @RevisionPhrases,$StartDatePhrase   ;}

    $RevisionQuery .= join $OuterLogic,@RevisionPhrases;

    my %RevisionDocumentIDs = ();

    my $document_list = $dbh -> prepare($RevisionQuery);
       $document_list -> execute();
       $document_list -> bind_columns(undef, \($DocumentID, $DocRevID));

  ### List of documents found at this stage

    while ($document_list -> fetch) {
          if (CanAccessRevision($DocRevID)) {
              $RevisionDocumentIDs{$DocumentID} = 1; # Hash removes duplicates
          }
    }
    @RevisionDocumentIDs = keys %RevisionDocumentIDs;
  }

  ### Topics (if any)

  if (@TopicSearchIDs) {
    $SearchedTopics = 1; # Add -subtopics switch
    @TopicRevisions = TopicSearch({ -logic     => $InnerLogic, -topicids => \@TopicSearchIDs,
                                    -subtopics => $IncludeSubTopics,
                                 });
    push @DebugStack,"Found revisions ".join ', ',@TopicRevisions;
    @TopicDocumentIDs = ValidateRevisions(@TopicRevisions);

  }

  if (@EventSearchIDs && @EventGroupSearchIDs && !$SimpleText) { # Remove group if event is selected
    require "MeetingSQL.pm";
    GetConferences();
    my %EventGroupSearchIDs = ();
    foreach my $EventGroupSearchID (@EventGroupSearchIDs) {
      $EventGroupSearchIDs{$EventGroupSearchID} = 1;
    }
    foreach my $EventSearchID (@EventSearchIDs) {
      $EventGroupSearchIDs{$Conferences{$EventSearchID}{EventGroupID}} = 0;
    }
    @EventGroupSearchIDs = ();
    foreach my $EventGroupSearchID (keys %EventGroupSearchIDs) {
      if ($EventGroupSearchIDs{$EventGroupSearchID}) {
        push @EventGroupSearchIDs, $EventGroupSearchID;
      }
    }
  }

  my @EventDocumentIDs      = ();
  my @EventGroupDocumentIDs = ();

  if (@EventSearchIDs) {
    $SearchedEvents = 1;
    my @EventRevisions = EventSearch($InnerLogic,"event",@EventSearchIDs);
    @EventDocumentIDs = ValidateRevisions(@EventRevisions);
  }

  if (@EventGroupSearchIDs) {
    $SearchedEventGroups = 1;
    my @EventGroupRevisions = EventSearch($InnerLogic,"group",@EventGroupSearchIDs);
    @EventGroupDocumentIDs = ValidateRevisions(@EventGroupRevisions);
  }

  ### Authors (if any)

  if (@AuthorSearchIDs) {
    $SearchedAuthors = 1;
    @AuthorRevisions = AuthorSearch($InnerLogic,@AuthorSearchIDs);
    @AuthorDocumentIDs = ValidateRevisions(@AuthorRevisions);
  }

  ### Document types (if any)

  if (@TypeSearchIDs) {
    $SearchedTypes = 1;
    @TypeDocumentIDs = TypeSearch("OR",@TypeSearchIDs);
  }

  ### Files (if any)

  if ($FileSearch || $FileDescSearch) {
    $SearchedFiles = 1;
  ### Text search matches
    my $FilePhrase        = TextSearch("FileName",    $FileSearchMode,    $FileSearch);
    my $DescriptionPhrase = TextSearch("Description", $FileDescSearchMode,$FileDescSearch);

  ### Get Revisions from DocumentFile that match

    my @FilePhrases = ();
    my $FileQuery   = "select DocRevID from DocumentFile where ";

    if ($FilePhrase       ) {push @FilePhrases,$FilePhrase       ;}
    if ($DescriptionPhrase) {push @FilePhrases,$DescriptionPhrase;}

    $FileQuery .= join $OuterLogic,@FilePhrases;

    my %FileDocumentIDs = ();
    my @FileRevisions = ();
    my $DocRevID;
    my $revision_list = $dbh -> prepare($FileQuery);
       $revision_list -> execute();
       $revision_list -> bind_columns(undef, \($DocRevID));

  ### List of revisions found at this stage

    while ($revision_list -> fetch) {
      push @FileRevisions,$DocRevID;
    }
    @FileDocumentIDs = ValidateRevisions(@FileRevisions);
  }

  ### Optional content search

  if ($ContentSearch && $FileContSearch) {
    $SearchedContent = 1;
    my %ContentDocumentIDs = ();

    my $perlfectSearch = qq("$FileContSearch");

    $SearchString = "$ContentSearch $perlfectSearch $FileContSearchMode";
#    open SEARCH,"$ContentSearch $FileContSearchMode $FileContSearch |";

    open SEARCH," $SearchString |";

    while ($Line = <SEARCH>) {
        $TmpLine = $Line;
        if (( grep /$web_root/, $Line) || ( grep /$mirror_root/, $Line)){
             @Parts = split /\s*\"\s*/,$TmpLine; 

         foreach $Part (@Parts) {
             if ((grep /$web_root/, $Part) || ( grep /$mirror_root/, $Line)) {
	          ($Major,$DocID,$Version) = ($Part =~ /(\d{4})\/(\S+)\/(\d{3})\//); # Search for 1234/123456/789, DocDB pattern 
	         if ($DocID) {
                     if ($DocID  =~ m/^\d/) {
	                 $DocID   = int($DocID);
                         $ContentDocumentIDs{$DocID} = 1;
                     }
                     else {
                         my $DocAlias = $DocID;
                         $DocID = GetDocumentIDByAlias($DocAlias);
	                 $DocID   = int($DocID);
                         if ($DocID > 0) {
                             $ContentDocumentIDs{$DocID} = 1;
                         }
                     }
                 }
            } 
        } 
    }  
  
} 
close SEARCH; 

### ORIGINAL LINES
###    while (my $line = <SEARCH>) {
###      chomp $line;
###
###      my $DocumentID = int($line);
###      $ContentDocumentIDs{$DocumentID} = 1;
###    }
###    close SEARCH;
    @ContentDocumentIDs = keys %ContentDocumentIDs;
  }

  ### Fetch all info for documents that match all criteria

  if ($OuterLogic eq "OR") {
    push @DocumentIDs,@DCCDocumentIDs;
    push @DocumentIDs,@RevisionDocumentIDs;
    push @DocumentIDs,@TopicDocumentIDs;
    push @DocumentIDs,@EventDocumentIDs;
    push @DocumentIDs,@EventGroupDocumentIDs;
    push @DocumentIDs,@AuthorDocumentIDs;
    push @DocumentIDs,@FileDocumentIDs;
    push @DocumentIDs,@TypeDocumentIDs;
    push @DocumentIDs,@ContentDocumentIDs;
    @DocumentIDs = Unique(@DocumentIDs);  
  } elsif ($OuterLogic eq "AND") {
    my %TotalDocumentIDs = ();
    my $TotalSearches    = 0;
    my $DocID;
    if ($SearchedNumbers) {
      ++$TotalSearches;
      foreach $DocID (@DCCDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedRevisions) {
      ++$TotalSearches;
      foreach $DocID (@RevisionDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedTopics) {
      ++$TotalSearches;
      foreach $DocID (@TopicDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedEvents) {
      ++$TotalSearches;
      foreach $DocID (@EventDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedEventGroups) {
      ++$TotalSearches;
      foreach $DocID (@EventGroupDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedAuthors) {
      ++$TotalSearches;
      foreach $DocID (@AuthorDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedFiles) {
      ++$TotalSearches;
      foreach $DocID (@FileDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedTypes) {
      ++$TotalSearches;
      foreach $DocID (@TypeDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }
    if ($SearchedContent) {
      ++$TotalSearches;
      foreach $DocID (@ContentDocumentIDs) {
        ++$TotalDocumentIDs{$DocID};
      }
    }

  ### Which ones matched every search

    foreach $DocID (keys %TotalDocumentIDs) {
      if ($TotalDocumentIDs{$DocID} == $TotalSearches) {
        push @DocumentIDs,$DocID;
      }
    }
  }

  @DocumentIDs = Unique(@DocumentIDs);

  ### Calculate relevance

  AddSearchWeights({
    -numbers     => \@DCCDocumentIDs        ,
    -revisions   => \@RevisionDocumentIDs   ,
    -topics      => \@TopicDocumentIDs      ,
    -events      => \@EventDocumentIDs      ,
    -eventgroups => \@EventGroupDocumentIDs ,
    -authors     => \@AuthorDocumentIDs     ,
    -doctypes    => \@TypeDocumentIDs       ,
    -files       => \@FileDocumentIDs       ,
    -contents    => \@ContentDocumentIDs    ,
  });

  ### Set up fields and sorting

  my %FieldListOptions = (-default => "Default");
  my $SortBy           = "date";
  my $Reverse          = 1;

  if ($SimpleText) {
    $SortBy  = "relevance";
    $Reverse = $TRUE;
  } elsif ($Mode eq "title") {
    $SortBy  = "doctitle";
    $Reverse = $FALSE;
  } elsif ($Mode eq "conference") {
    $FieldListOptions{-default} = "Conference Mode";
    $SortBy  = "confdate";
  } elsif ($Mode eq "meeting") {
    $FieldListOptions{-default} = "Meeting Mode";
    $SortBy  = "firstauthor";
    $Reverse = 0;
  }

  ### Print table

  if ($OutFormat eq 'HTML') {
    my %FieldList = PrepareFieldList(%FieldListOptions);
    
    my $NumberOfDocuments = DocumentTable(-fieldlist => \%FieldList, -docids  => \@DocumentIDs,
                                          -sortby    => $SortBy,     -reverse => $Reverse);

    print "<strong>Number of documents found: ",int($NumberOfDocuments),"</strong><p/>\n";
  } else {
    foreach my $DocumentID (@DocumentIDs) {
      my $DocumentXML = DocumentXMLOut( {-docid => $DocumentID} );
      if ($DocumentXML) {
        $DocumentXML -> paste(last_child => $DocDBXML);
      }
    }
  }

  return;
}

1;
