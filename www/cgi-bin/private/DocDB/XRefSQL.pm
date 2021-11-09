#
# Description: SQL routines related to cross-referencing documents
#
#      Author: Eric Vaandering (ewv@fnal.gov)
#    Modified:

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

sub InsertXRefs (%) {
  require "DocumentSQL.pm";
  my %Params = @_;

  my $DocRevID    =   $Params{-docrevid} || 0;
  my @DocumentIDs = @{$Params{-docids}};
  my @Documents   = @{$Params{-documents}};
  my $Count = 0;

  my $Insert = $dbh -> prepare("insert into DocXRef (DocXRefID, DocRevID, DocumentID) values (0,?,?)");

  foreach my $DocID (@DocumentIDs) {
    if (&FetchDocument($DocID) && $DocRevID) {
      $Insert -> execute($DocRevID,$DocID);
      ++$Count;
    } else {
      require "ResponseElements.pm";
      my $DocumentString = &FullDocumentID($DocID);
      push @WarnStack,"Unable to Cross-reference to $DocumentString: Does not exist";
    }
  }

  foreach my $Document (@Documents) {
    my $ExtProject = "";
    my $Version    = 0;
    my $DocID      = 0;
    my @Parts = split /\-/,$Document;
    foreach my $Part (@Parts) {
      if (grep /^v\d+$/,$Part) {
        $Version = $Part;
        $Version =~ s/v//;
      } elsif (int($Part) && !$DocID) { # Only take first one as DocID
        $DocID = $Part;
      } else {
        $ExtProject = $Part;
        $ExtProject =~ s/\s+//;
      }
    }

    if (!$ExtProject || $ExtProject eq $ShortProject) { # Check if it exists
      my $OK = 0;
      if ($DocRevID && $DocID && $Version) {
        unless (&FetchRevisionByDocumentAndVersion($DocID,$Version)) {
          push @WarnStack,"Document $DocID, version $Version does not exist. No cross-reference created.";
          next;
        }
        $OK = 1;
      } elsif ($DocRevID && $DocID && &FetchDocument($DocID)) {
        $OK = 1;
      } else {
        push @WarnStack,"Unable to Cross-reference to $Document: Does not exist or format is not 1234-v56";
        next;
      }
    }

    my $DocXRefID = 0;
    if ($DocID) {
      $Insert -> execute($DocRevID,$DocID);
      $DocXRefID = $Insert -> {mysql_insertid};
    }
    if ($DocXRefID && $Version) {
      my $Update = $dbh -> prepare("update DocXRef set Version=? where DocXRefID=?");
      $Update -> execute($Version,$DocXRefID);
    }
    if ($DocXRefID && $ExtProject) {
      my $Update = $dbh -> prepare("update DocXRef set Project=\"$ExtProject\" where DocXRefID=$DocXRefID");
      $Update -> execute();
    }
  }

  return $Count;
}

sub FetchInfoFromXRefID ($) {
  my ($XRefID) = (@_);

  my @DocIDs = ();

  my $List;

  if ($XRefID) {
    $List = $dbh -> prepare("select DocXRefID,DocRevID,DocumentID,Project,Version,TimeStamp ".
             "from DocXRef where DocXRefID=?");
    $List -> execute($XRefID);
  }
  if ($List) {
    my ($DocXRefID,$DocRevID,$DocumentID,$ExtProject,$Version,$TimeStamp);
    $List-> bind_columns(undef, \($DocXRefID,$DocRevID,$DocumentID,$ExtProject,$Version,$TimeStamp));

    while ($List -> fetch) {
      push @DocIDs,$DocumentID;
      $DocXRefs{$DocXRefID}{DocRevID}   = $DocRevID;
      $DocXRefs{$DocXRefID}{DocumentID} = $DocumentID;
      $DocXRefs{$DocXRefID}{Project}    = $ExtProject;
      $DocXRefs{$DocXRefID}{Version}    = $Version;
      $DocXRefs{$DocXRefID}{TimeStamp}  = $TimeStamp;
    }
  }

  return @DocIDs;
}

sub FetchXRefs (%) {
  my %Params = (@_);

  my $DocRevID   = $Params{-docrevid} || 0;
  my $DocumentID = $Params{-docid}    || 0;
  my $Version    = $Params{-version}  || ();
  my $Sorted     = $Params{-sorted}  || 0;

  my @DocXRefIDs = ();
     %DocXRefs   = ();

  my $List;

  if ($DocRevID) {
    if ($Sorted) {
        $List = $dbh -> prepare("select DocXRefID,DocRevID,DocumentID,Project,Version,TimeStamp ".
             "from DocXRef where DocRevID=? order by DocXRefID");
    } else {
        $List = $dbh -> prepare("select DocXRefID,DocRevID,DocumentID,Project,Version,TimeStamp ".
                 "from DocXRef where DocRevID=?");
    }
    $List -> execute($DocRevID);
  } elsif ($DocumentID) {
    if ($Version) {
         $List = $dbh -> prepare("select DocXRef.DocXRefID,DocXRef.DocRevID,DocXRef.DocumentID,".
                  "DocXRef.Project,DocXRef.Version,DocXRef.TimeStamp ".
                  "from DocXRef,DocumentRevision where DocXRef.DocumentID=? and DocXRef.Version=? and ".
                  "DocumentRevision.DocRevID=DocXRef.DocRevID and DocumentRevision.Obsolete=0");
         $List -> execute($DocumentID, $Version);
    }
    else {
         $List = $dbh -> prepare("select DocXRef.DocXRefID,DocXRef.DocRevID,DocXRef.DocumentID,".
                  "DocXRef.Project,DocXRef.Version,DocXRef.TimeStamp ".
                  "from DocXRef,DocumentRevision where DocXRef.DocumentID=? and ".
                  "DocumentRevision.DocRevID=DocXRef.DocRevID and DocumentRevision.Obsolete=0");
         $List -> execute($DocumentID);
    }

  }
  if ($List) {
    my ($DocXRefID,$DocRevID,$DocumentID,$ExtProject,$Version,$TimeStamp);
    $List-> bind_columns(undef, \($DocXRefID,$DocRevID,$DocumentID,$ExtProject,$Version,$TimeStamp));

    while ($List -> fetch) {
      push @DocXRefIDs,$DocXRefID;
      $DocXRefs{$DocXRefID}{DocRevID}   = $DocRevID;
      $DocXRefs{$DocXRefID}{DocumentID} = $DocumentID;
      $DocXRefs{$DocXRefID}{Project}    = $ExtProject;
      $DocXRefs{$DocXRefID}{Version}    = $Version;
      $DocXRefs{$DocXRefID}{TimeStamp}  = $TimeStamp;
    }
  }

  return @DocXRefIDs;
}


sub ClearExternalDocDBs () {
  $HaveAllExternalDocDBs = 0;
  %ExternalDocDBs        = ();
  %ExternalProjects      = ();
}

sub GetAllExternalDocDBs () {
  if ($HaveAllExternalDocDBs) {
    my @ExternalDocDBIDs = keys %ExternalDocDBs;
    return @ExternalDocDBIDs;
  }
  %ExternalDocDBs = ();
  my @ExternalDocDBIDs = ();
  my ($ExternalDocDBID);

  my $List = $dbh -> prepare("select ExternalDocDBID from ExternalDocDB");
  $List -> execute();
  $List-> bind_columns(undef, \($ExternalDocDBID));
  while ($List -> fetch) {
    my $ID = FetchExternalDocDB($ExternalDocDBID);
    push @ExternalDocDBIDs,$ID;
  }
  $HaveAllExternalDocDBs = $TRUE;
  return @ExternalDocDBIDs;
}

sub FetchExternalDocDB ($) {
  my ($ExternalDocDBID) = @_;
  unless ($ExternalDocDBID) {
    return;
  }

  my $Fetch = $dbh->prepare("select Project,Description,PrivateURL,PublicURL,TimeStamp from ExternalDocDB where ExternalDocDBID=?");
  $Fetch -> execute($ExternalDocDBID);

  my ($Project,$Description,$PrivateURL,$PublicURL,$TimeStamp) = $Fetch -> fetchrow_array;
  if ($TimeStamp) {
    $ExternalDocDBs{$ExternalDocDBID}{Project}     = $Project;
    $ExternalDocDBs{$ExternalDocDBID}{Description} = $Description;
    $ExternalDocDBs{$ExternalDocDBID}{PrivateURL}  = $PrivateURL;
    $ExternalDocDBs{$ExternalDocDBID}{PublicURL}   = $PublicURL;
    $ExternalDocDBs{$ExternalDocDBID}{TimeStamp}   = $TimeStamp;
    $ExternalProjects{$Project}                    = $ExternalDocDBID;
    return $ExternalDocDBID;
  } else {
    return;
  }
}

sub FetchExternalDocDBByName ($) {
  my ($Name) = @_;
  unless ($Name) {
    return;
  }

  my $Fetch = $dbh->prepare("select ExternalDocDBID from ExternalDocDB where Project=?");
  $Fetch -> execute($Name);

  my ($ExternalDocDBID) = $Fetch -> fetchrow_array;
  if ($ExternalDocDBID) {
    my $ExternalDocDBID = FetchExternalDocDB($ExternalDocDBID);
    return $ExternalDocDBID;
  } else {
    return;
  }
}
1;
