
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

# The %Files hash has the following possible fields:

#  Filename    -- The name of the file, already on the file system to be inserted
#  File        -- Contains file handle from CGI
#  CopyFileID  -- Copy physical file from a previous version
#  FileID      -- Duplicate file id entry from a previous version
#  Description -- Description of the file
#  Main        -- Boolean, is it a "main" file
# These settings apply only to URL uploads
#  URL         -- URL of the file
#  Pass        -- Password for wget
#  User        -- Username for wget
#  NewFilename -- New name of files (wget -O option)

sub AddFiles (%) {
  require "FileSQL.pm";
  require "MiscSQL.pm";
  require "FSUtilities.pm";

  my %Params = @_;

  my $DocRevID   = $Params{-docrevid};
  my $DateTime   = $Params{-datetime};
  my $ReplaceOld = $Params{-replaceold}; # Replace files of the same name
  my $OldVersion = $Params{-oldversion}; # For copying files from old version

  my %Files = %{$Params{-files}};

  push @DebugStack,"Adding files for DRI $DocRevID";

  my @FileIDs = (); my $FileID;
  unless ($DocRevID) {
    return @FileIDs;
  }

  my @Files = sort keys %Files;

  &FetchDocRevisionByID($DocRevID);
  my $Version    = $DocRevisions{$DocRevID}{Version};
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  &MakeDirectory($DocumentID,$Version);
  my $Directory = &GetDirectory($DocumentID,$Version);

  foreach my $File (@Files) {
    my $ShortName = "";
    if ($Files{$File}{Filename} && (-e $Files{$File}{Filename})) {
      push @DebugStack,"Used cp $Files{$File}{Filename} $Directory";
      my @Parts = split /\//,$Files{$File}{Filename};
      $ShortName = pop @Parts;
      system ("cp",$Files{$File}{Filename},$Directory);
    } elsif ($Files{$File}{File}) {
      push @DebugStack,"Trying to upload $File $Files{$File}{File} Main: $Files{$File}{Main}";
      $ShortName = &ProcessUpload($Directory,$Files{$File}{File});
    } elsif ($Files{$File}{CopyFileID}) {
      push @DebugStack,"Trying to copy $File $Files{$File}{CopyFileID} Main: $Files{$File}{Main}";
      $ShortName = &FetchFile($Files{$File}{CopyFileID});
      &CopyFile($Directory,$ShortName,$DocumentID,$OldVersion);
    } elsif ($Files{$File}{FileID}) {
      push @DebugStack,"Trying to duplicate $File $Files{$File}{CopyFileID} Main: $Files{$File}{Main}";
      my $OldFileID = $Files{$File}{FileID};
      &FetchFile($OldFileID);
      $ShortName = $DocFiles{$OldFileID}{Name};
      $DateTime  = $DocFiles{$OldFileID}{Date};
    } else { # else other methods
      push @DebugStack,"Don't understand method to insert file with key $File";
    }
    if ($ReplaceOld && $ShortName) {
      my $OldFileID = &ExistsFile($DocRevID,$ShortName);
      &DeleteFile(-fileid => $OldFileID);
    }

    if ($ShortName) {
      $FileID = &InsertFile(-docrevid    => $DocRevID, -datetime => $DateTime,
                            -filename    => $ShortName,
                            -main        => $Files{$File}{Main},
                            -description => $Files{$File}{Description});
      my $full_file = "$Directory$ShortName";
      system (" $IncrementalContentSearch \"$full_file\" > /dev/null &" );

      push @FileIDs,$FileID;
    }
  }
  return @FileIDs;
}

sub AddArchive (%) {
  require "FileSQL.pm";
  require "FSUtilities.pm";

  my %Params = @_;

  my $DocRevID = $Params{-docrevid};
  my $DateTime = $Params{-datetime};

  my %Archive = %{$Params{-archive}};

  push @DebugStack,"Adding archive for DRI $DocRevID";

  my @FileIDs = (); my $FileID;
  unless ($DocRevID) {
    return @FileIDs;
  }

  &FetchDocRevisionByID($DocRevID);
  my $Version    = $DocRevisions{$DocRevID}{Version};
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  &MakeDirectory($DocumentID,$Version);
  my $Directory = &GetDirectory($DocumentID,$Version);

  $ShortName = &ProcessUpload($Directory,$Archive{File});
  my $Status = &ExtractArchive($Directory,$ShortName); # FIXME No status yet
  if ($ShortName) {
    push @DebugStack,"Archive name: $ShortName";
    $FileID = &InsertFile(-docrevid    => $DocRevID, -datetime => $DateTime,
                          -filename    => $ShortName,
                          -main        => 0,
                          -description => "Document Archive");
    push @FileIDs,$FileID;
    if (-s "$Directory/$Archive{MainFile}") {
      push @DebugStack,"Main File: $Archive{MainFile}";
      $FileID = &InsertFile(-docrevid    => $DocRevID, -datetime => $DateTime,
                            -filename    => $Archive{MainFile},
                            -main        => 1,
                            -description => $Archive{Description});
      push @FileIDs,$FileID;
    } else {
      push @WarnStack,"The main file $main_file did not exist or was blank.";
    }
  }
  return @FileIDs;
}

sub AbbreviateFileName {

# Try to intelligently abbreivate a filename. Keep the extension if possible.

  my %Params = @_;

  my $FileName  = $Params{-filename};
  my $MaxLength = $Params{-maxlength} || 20;
  my $MaxExt    = $Params{-maxext}    || 4;

  my $ReturnString = $FileName;

  if (length($FileName) > $MaxLength) {
    my @Parts = split /\./,$FileName;
    my $Extension = pop @Parts;
    my $BaseFile = join '.',@Parts;
    if (length($Extension) > 0 && length($Extension) < 4) {
      $ReturnString  = substr $BaseFile,0,($MaxLength-length($Extension)-3);
      $ReturnString .= "...";
      $ReturnString .= $Extension;
    } else {
      my $StartString = substr $FileName,0,($MaxLength-$MaxExt-3);
      my $EndString   = substr $FileName,-$MaxExt,$MaxExt;
      $ReturnString = $StartString."...".$EndString;
    }
  }

  return $ReturnString;
}

# Removed function StreamFile, which created
# a dependency on File::MimeInfo, but which
# was unreachable code!!
# Phil Ehrens 10-30-2012

1;
