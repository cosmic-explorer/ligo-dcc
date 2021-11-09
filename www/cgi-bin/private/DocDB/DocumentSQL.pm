
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

sub GetAllDocuments {
  my ($DocumentID);
  my $DocumentList    = $dbh->prepare(
     "select DocumentID,RequesterID,RequestDate,TimeStamp,Alias ".
     "from Document");
  my $MaxVersionQuery = $dbh->prepare("select DocumentID,max(VersionNumber) ".
                                     "from DocumentRevision ".
                                     "group by DocumentID;");

  my ($DocumentID,$RequesterID,$RequestDate,$TimeStamp);
  my ($MaxVersion);

  $DocumentList -> execute;
  $DocumentList -> bind_columns(undef, \($DocumentID,$RequesterID,$RequestDate,$TimeStamp,$Alias));
  %Documents = ();
  @DocumentIDs = ();
  while ($DocumentList -> fetch) {
    $Documents{$DocumentID}{DocID}     = $DocumentID;
    $Documents{$DocumentID}{Requester} = $RequesterID;
    $Documents{$DocumentID}{Date}      = $RequestDate;
    $Documents{$DocumentID}{TimeStamp} = $TimeStamp;
    $Documents{$DocumentID}{Alias}     = $Alias;
    push @DocumentIDs,$DocumentID;
  }

### Number of versions for each document

  $MaxVersionQuery -> execute;
  $MaxVersionQuery -> bind_columns(undef, \($DocumentID,$MaxVersion));
  while ($MaxVersionQuery -> fetch) {
    $Documents{$DocumentID}{NVersions} = $MaxVersion;
  }
};

sub FetchDocument {
  my ($DocumentID) = @_;

  my $DocumentList    = $dbh -> prepare("select DocumentID,RequesterID,RequestDate,TimeStamp,Alias ".
                                        "from Document where DocumentID=?");
  my $MaxVersionQuery = $dbh -> prepare("select MAX(VersionNumber) from ".
                                        "DocumentRevision where DocumentID=?");
  $DocumentList -> execute($DocumentID);

  $temptdoc = $DocumentID;
  my ($DocumentID,$RequesterID,$RequestDate,$TimeStamp,$Alias) = $DocumentList -> fetchrow_array;
  push @DebugStack,"From Database DocID: $DocumentID";
  if ($DocumentID) {
    $Documents{$DocumentID}{DocID}     = $DocumentID;
    $Documents{$DocumentID}{Requester} = $RequesterID;
    $Documents{$DocumentID}{Date}      = $RequestDate;
    $Documents{$DocumentID}{TimeStamp} = $TimeStamp;
    $Documents{$DocumentID}{Alias}     = $Alias;
    push @DocumentIDs,$DocumentID;

    $MaxVersionQuery -> execute($DocumentID);
    ($Documents{$DocumentID}{NVersions}) = $MaxVersionQuery -> fetchrow_array;
    return $DocumentID;
  } else {
    return 0;
  }
}

sub FetchDocumentFilenames {
    my ($DocRevID) = @_;
    my $Filenames = '';
    my $sth = $dbh -> prepare("select FileName from DocumentFile where DocRevID=\"$DocRevID\"");
    $sth -> execute;
    $sth->bind_columns(undef, \$fnames);
    while($sth->fetch()) {
       $Filenames = "$Filenames $fnames";
    }
    return $Filenames;
}

sub FetchDocumentAlias {
  my ($DocumentID) = @_;

  my $DocumentList = $dbh -> prepare("select Alias from Document where DocumentID=?");
  $DocumentList -> execute($DocumentID);
  my ($DocumentAlias) =  $DocumentList -> fetchrow_array;

  push @DebugStack,"From Database DocID: $DocumentID";

  if ($DocumentAlias) {
    return $DocumentAlias;
  } else {
    return "";
  }
}

sub FetchDocumentType {
  my ($DocumentID) = @_;

  my $DocumentList = $dbh -> prepare("select Alias from Document where DocumentID=?");
  $DocumentList -> execute($DocumentID);
  my ($DocumentAlias) =  $DocumentList -> fetchrow_array;

  push @DebugStack,"From Database DocID: $DocumentID";

  if ($DocumentAlias) {
      @chars = split("",$DocumentAlias);
    return $chars[0];
  } else {
    return "";
  }
}


sub GetDocumentIDByAlias {
  my ($DocumentAlias) = @_;

  if ($DocumentAlias eq "") { return 0; }

  my $DocumentList = $dbh -> prepare("select DocumentID from Document where Alias=?");
  $DocumentList -> execute($DocumentAlias);
  my ($DocumentID) =  $DocumentList -> fetchrow_array;

  return $DocumentID;
}


sub InsertDocument (%) {
  my %Params = @_;

  my $DocumentID    = $Params{-docid}         || 0;
  my $DocHash       = $Params{-dochash}       || "";
  my $RequesterID   = $Params{-requesterid}   || 0;
  my $DateTime      = $Params{-datetime};
  my $DocTypeID     = $Params{-doctypeid}     || 1;
  my $DocAlias      = $Params{-docnumber}     || 0;

  my $DocNextNumber = ();
  my $DocNumberStr = ();

  my $DocTypeShort = &FetchDocType($DocTypeID);
  my ($DocTypeAbbr) = ($DocTypeShort =~ /(\w{1})/);
  $DocNextNumber = &FetchNextDocNumber($DocTypeID);

  my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
  # formats the document number to <Type><Year><Number>
  $DocNumberStr = sprintf("%s%02d%05d", $DocTypeAbbr, ($Year - 100), $DocNextNumber);

  # Override all that if a docnumber is entered

  if ($DocAlias) {
      $DocNextNumber = $DocAlias;
      $DocNumberStr = sprintf($DocNextNumber);
  }
  unless ($DateTime) {
#    my ($Sec,$Min,$Hour,$Day,$Mon,$Year) = localtime(time);
    $Year += 1900;
    ++$Mon;
    $DateTime = "$Year-$Mon-$Day $Hour:$Min:$Sec";
  }

  my $Insert = $dbh -> prepare( "insert into Document (DocumentID, RequesterID, RequestDate, DocHash, Alias) values (?,?,?,?,?)");

  $Insert -> execute($DocumentID,$RequesterID,$DateTime,$DocHash,$DocNumberStr);
  $DocumentID = $Insert -> {mysql_insertid}; # Works with MySQL only

  &UpdateNextDocNumber($DocTypeID);

  return $DocumentID;
}


1;
