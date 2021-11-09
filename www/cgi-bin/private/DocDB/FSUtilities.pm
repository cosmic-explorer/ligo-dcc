#
#        Name: FSUtilities.pm
# Description: Routines to deal with files stored in the file system.
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

#  Functions in this file:
#
#  FullFile
#    Given a document ID, version number, and short file name,
#    returns the full path of the file.
#
#  FileSize
#    Returns the size of a file in human readable format
#
#  GetDirectory
#    Given a document ID and a version number, returns the name of the
#    directory where the document files are stored.
#
#  MakeDirectory
#    Given a document ID and a version number, makes the directory
#    where the document files are stored and any parent directories
#    that haven't been created. Safe to call on existing directories.
#
#  GetURLDir
#    The counterpart to GetDirectory, this function returns the base URL
#    where document files are stored
#
#  ProtectDirectory
#    Given a document ID, version number and the ID numbers of authorized
#    groups, this function will protect a directory from unauthorized
#    web access. (Writes and appropriate .htaccess file.) If no users IDs
#    are specified, it removes .htaccess (for public documents).
#
#  ProcessUpload
#    Retrieves a file uploaded by the user's browser and places the resulting
#    file in the correct place in the file system
#
#  ExtractArchive
#    Detects the type of archive and extracts it into the correct
#    location on the file system. Does NOT protect against archives
#    with files that have /../ in the directory name, so files can,
#    in theory, leak into other documents and/or revisions.

sub DocRevIDFromFullFile{
  my ($FullFile) = @_;

  require "SiteConfig.pm";
  my $DocRevID;

  if (grep /$web_root/, $FullFile) {
      ($Major,$DocAlias,$Version,$FileName) = ($FullFile =~ /(\d{4})\/(\S+)\/(\d{3})\/(\S+)/); # Search for 1234/A123456/789, DocDB patternprint DEBUG  "\n Major: $Major ";
#       print DEBUG  "\n DocAlias: $DocAlias";
#       print DEBUG  "\n Version: $Version";
#       print DEBUG  "\n FileName: $FileName";
       $DocID    = GetDocumentIDByAlias($DocAlias);
       $DocID    = int($DocID);
       $DocRevID = FetchRevisionByDocumentAndVersion($DocID, $Version);
  }

  return $DocRevID;
}

sub FullFile {
  my ($DocumentID,$Version,$ShortFile) = @_;

  my $FullFile = &GetDirectory($DocumentID,$Version).$ShortFile;

  return $FullFile;
}

sub FileSize {
  my ($File) = @_;

  my $RawSize = (-s $File);
  my $Size;

  if (-e $File) {
    if ($RawSize > 1024*1024*1024) {
      $Size = sprintf "%8.1f GB",$RawSize/(1024*1024*1024);
    } elsif ($RawSize > 1024*1024) {
      $Size = sprintf "%8.1f MB",$RawSize/(1024*1024);
    } elsif ($RawSize > 1024) {
      $Size = sprintf "%8.1f kB",$RawSize/(1024);
    } else {
      $Size = "$RawSize bytes";
    }
  } else {
    $Size = "file is not accessible";
  }

  return $Size;
}

sub GetDirectory { # Returns a directory name

  require "DocumentSQL.pm";

  my ($documentID,$version) = @_;

  # Any change in formats must be made in GetURLDir too

  my $hun_dir = sprintf "%4.4d/",int($documentID/1000);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d/",$version;

  if ($UseAliasAsFileName) {
    my $documentAlias = FetchDocumentAlias($documentID);
    if ($documentAlias ne "") {
       $sub_dir = sprintf "$documentAlias/";
    }
  }

  my $new_dir = $file_root.$hun_dir.$sub_dir.$ver_dir;

  return $new_dir;
}

sub MakeDirectory { # Makes a directory, safe for existing directories
  require "DocumentSQL.pm";

  my ($documentID,$version) = @_;

  my $hun_dir = sprintf "%4.4d/",int($documentID/1000);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d/",$version;

  if ($UseAliasAsFileName) {
    my $documentAlias = FetchDocumentAlias($documentID);
    if ($documentAlias ne "") {
       $sub_dir = sprintf "$documentAlias/";
    }
  }

  my $new_dir = $file_root.$hun_dir.$sub_dir.$ver_dir;
  
  mkdir  $file_root.$hun_dir,oct 777; #FIXME something more reasonable
  mkdir  $file_root.$hun_dir.$sub_dir,oct 777;
  mkdir  $file_root.$hun_dir.$sub_dir.$ver_dir,oct 777;

  return $new_dir; # Returns directory name
}

sub MakeLinkDirectory { # Makes a directory, safe for existing directories
  require "DocumentSQL.pm";

  my ($documentID,$version) = @_;

  unless ($version) {
     $version = 0;
  }
  my $hun_dir = sprintf "%4.4d/",int($documentID/1000);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d",$version;

  if ($UseAliasAsFileName) {
    my $documentAlias = FetchDocumentAlias($documentID);
    if ($documentAlias ne "") {
       $sub_dir = sprintf "$documentAlias/";
    }
  }

  my $orig_dir = $file_root.$hun_dir.$sub_dir.$ver_dir;
  unless (-d $orig_dir) {
     &syslog_err("MakeLinkDirectory: directory does not exist: $orig_dir");
  }
  my $new_dir  = $public_root.$hun_dir.$sub_dir.$ver_dir;

  mkdir  $public_root.$hun_dir,oct 777; #FIXME something more reasonable
  mkdir  $public_root.$hun_dir.$sub_dir,oct 777;
  if (-l $new_dir) {
     unlink $new_dir or
        warn "MakeLinkDirectory: Could not unlink directory ".$new_dir &&
        &syslog_err("MakeLinkDirectory: Could not unlink directory ".$new_dir);
  }
  symlink $orig_dir, $new_dir or
     warn "MakeLinkDirectory: Cannot symlink $orig_dir to $new_dir" &&
     &syslog_err("MakeLinkDirectory: Cannot symlink $orig_dir to $new_dir");
  
  return $new_dir; # Returns directory name
}


sub UnlinkDirectory { # Makes a directory, safe for existing directories
  require "DocumentSQL.pm";

  my ($documentID,$version) = @_;

  my $hun_dir = sprintf "%4.4d/",int($documentID/1000);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d",$version;

  if ($UseAliasAsFileName) {
    my $documentAlias = FetchDocumentAlias($documentID);
    if ($documentAlias ne "") {
       $sub_dir = sprintf "$documentAlias/";
    }
  }

  my $new_dir  = $public_root.$hun_dir.$sub_dir.$ver_dir;

  if (-l $new_dir) {
     unlink $new_dir or
        warn "UnlinkDirectory: Could not unlink directory ".$new_dir &&
        &syslog_err("UnlinkDirectory: Could not unlink directory ".$new_dir);
  } else {
     &syslog_err("UnlinkDirectory: Symlink not found: ".$new_dir);
  }
}

sub GetURLDir { # Returns a directory name
  require "DocumentSQL.pm";

  my ($documentID,$version) = @_;

  # Any change in formats must be made in MakeDirectory too

  my $hun_dir = sprintf "%4.4d/",int($documentID/1000);
  my $sub_dir = sprintf "%6.6d/",$documentID;
  my $ver_dir = sprintf "%3.3d/",$version;

  if ($UseAliasAsFileName) {
    my $documentAlias = FetchDocumentAlias($documentID);
    if ($documentAlias ne "") {
       $sub_dir = sprintf "$documentAlias/";
    }
  }

  my $new_dir = $web_root.$hun_dir.$sub_dir.$ver_dir;

  return $new_dir;
}

sub ProtectDirectory { # Write (or delete) correct .htaccess file in directory
  require "EmailSecurity.pm";
  require "NotificationSQL.pm";
  require "RevisionSQL.pm";
  require "SecuritySQL.pm";
  require "AuthorSQL.pm";
  require "Utilities.pm";

  my ($documentID,$version,$docrevid,@GroupIDs) = @_;

  my $DocRevID = $docrevid;
#  my $DocRevID = FetchRevisionByDocumentAndVersion($documentID, $version);

  my @users = ();
  my %all_users = ();
  my @all_users = ();
  foreach $GroupID (@GroupIDs) {
    unless ($GroupID) {      #This would mean it's Public
        $GroupID = 1; 
    }
    push @users,$SecurityGroups{$GroupID}{NAME};
    $all_users{$GroupID} = 1; # Add user
    foreach $HierarchyID (keys %GroupsHierarchy) {
      if ($GroupsHierarchy{$HierarchyID}{Child} == $GroupID) {
        $all_users{$GroupsHierarchy{$HierarchyID}{Parent}} = 1;
      }
    }
  }

  # Now add the implicit group access: groups with Admin privilege
  &GetSecurityGroups;
 
  foreach my $eachGroupID (keys %SecurityGroups) {
      if ($SecurityGroups{$eachGroupID}{CanAdminister}) {
	    my $GroupName = $SecurityGroups{$eachGroupID}{NAME};
            push @all_users, $GroupName;
      }
  }

  foreach $GroupID (keys %all_users) {
    if ($GroupID == FetchSecurityGroupByName($AuthorsOnly_Group)) {
        my @EmailUserIDs = FetchEmailUserIDsBySecurityGroup($GroupID, $DocRevID); 
        foreach my $EmailUserID (@EmailUserIDs) {
            FetchEmailUser ($EmailUserID);
            my $UserName = $EmailUser{$EmailUserID}{Username};
            push @all_users, $UserName;
        }

        my @AuthorGroupIDs = GetAuthorGroups($DocRevID);
        foreach my $AuthorGroupID (@AuthorGroupIDs) {
            
            &FetchAuthorGroup($AuthorGroupID);
            my $HTDBM_AuthorGroupName = 
                $AuthorGroups{$AuthorGroupID}{AuthorGroupName}.$AuthorsOnly_GroupSuffix;
            push @all_users, $HTDBM_AuthorGroupName;
        }
    }
    else {
        push @all_users,$SecurityGroups{$GroupID}{NAME}
    }
  }

  my $AuthName = join ' or ',@users;

  my $directory = &GetDirectory($documentID,$version);
  if (@users) {
#    open HTACCESS,">$directory$htaccess";
#     print HTACCESS "<Limit GET>\n";
#     print HTACCESS "require group";

     foreach $user (@all_users) {
       if ($CaseInsensitiveUsers) {
	 $user =~ tr/[A-Z]/[a-z]/; #Make lower case
       }
     }

     FetchDocRevisionByID($DocRevID);
     
     # The user who updated the last version is given access to the file

     my $SubmitterID =  $DocRevisions{$DocRevID}{Submitter};
     my $EmailUserID =  FetchEmailUserIDFromAuthorID($SubmitterID); 
     FetchEmailUser ($EmailUserID);
     my $UserName = $EmailUser{$EmailUserID}{Username};

     if ($UserName) {
           push @all_users, $UserName;
     }

     # The user who originally created the document is given access to the file
     &FetchDocument($documentID);
     my $Requester = $Documents{$documentID}{Requester};
     my $RequesterEmailUserID =  FetchEmailUserIDFromAuthorID($Requester); 
     FetchEmailUser ($RequesterEmailUserID);
     my $RequesterName = $EmailUser{$RequesterEmailUserID}{Username};
     if ($RequesterName) {
           push @all_users, $RequesterName;
     }

     @all_users = Unique(@all_users); 
     
#     foreach $user (@all_users) {
#         print HTACCESS " $user";
#     }

#     print HTACCESS "\n";
#     print HTACCESS "</Limit>\n";
#    close HTACCESS;
  } else {
    unlink "$directory$htaccess"; # No users or public, remove .htaccess
  }
}

# After calling this you MUST test @ErrorStack for
# &FileNameSanityCheck() failure!
sub ProcessUpload ($$) {
    use File::Basename;
  my $test = "";
  my ($new_dir,$long_file) = @_;

  my $short_file = basename($long_file);
 
  &FileNameSanityCheck($short_file);
  open (OUTFILE,">$new_dir/$short_file");
  while ($bytes_read = read($long_file,$buffer,1024)) {
    print OUTFILE $buffer
  }
  close OUTFILE;

  unless (-s "$new_dir/$short_file") {
    push @WarnStack,"The file $short_file ($long_file) did not exist or was blank.";
  }
  return $short_file;
}

# Factored out for general use Phil Ehrens June 2011 %%%
# After calling this, test for @ErrorStack and if it's
# got entries, call &EndPage(-startpage => $TRUE) or
# Whatever is appropriate.
sub FileNameSanityCheck ($) {
  my ($short_file) = @_;
  push @DebugStack, "Shortfile is $short_file";
  # file name check ... Roy Williams Aug 2010 %%%
  if ($short_file =~ m/^([ \.\-~;]).*/) {
     push @ErrorStack,  "Filename $short_file is unacceptable: it cannot begin with '$1'. Please change the file name and try again.";
  } elsif ($short_file =~ m/(;|[^ #%\(\)\+,\-\.0-9:@A-Z\[\]\^_a-z~])/) {
     push @ErrorStack, "Filename $short_file has illegal character '$1'. Please change the file name and try again.";
  } elsif ($short_file !~ m/([A-Za-z0-9])/) {
     push @ErrorStack, "The Filename you provided has no alphanumeric characters. Please change the file name and try again.";
  }
  return "";
}

sub CopyFile ($$$$) {
  my ($NewDir,$ShortFile,$OldDocID,$OldVersion) = @_;
  my $OldDir = &GetDirectory($OldDocID,$OldVersion);
  my $OldFile = $OldDir."/".$ShortFile;
  push @DebugStack,"Copying $OldFile,$NewDir";
  system ("cp",$OldFile,$NewDir);
  return $ShortFile;
}

sub ExtractArchive {
  my ($Directory,$File) = @_;

  use Cwd;
  $current_dir = cwd();
  chdir $Directory or die "<p>Fatal error in chdir<p>\n";

  my $Command = "";
  chomp $File;
  if      (grep /\.tar$/,$File) {
    $Command = $Tar." xf ".$File;
  } elsif ((grep /\.tgz$/,$File) || (grep /\.tar\.gz$/,$File)) {
    if ($GTar) {
      $Command = $GTar." xfz ".$File;
    } elsif ($Tar && $GZip) {
      $Command = $GUnzip." -c ".$File." | ".$Tar." xf -";
    }
  } elsif (grep /\.zip$/,$File) {
    $Command = $Unzip." ".$File;
  }

  if ($Command) {
    print "Unpacking the archive with the command <tt>$Command</tt> <br>\n";
    system ($Command);
  } else {
    print "Could not unpack the archive; contact an
    <a href=\"mailto:$DBWebMasterEmail\">adminstrator</a>. <br>\n";
  }
  chdir $current_dir;
}

sub DownloadURLs (%) {
  use Cwd;
  require "WebUtilities.pm";

  my %Params = @_;

  my $TmpDir = $Params{-tmpdir} || "/tmp";
  my %Files    = %{$Params{-files}}; # Documented in FileUtilities.pm

  my $Status;
  $CurrentDir = cwd();
  chdir $TmpDir or die "<p>Fatal error in chdir<p>\n";

  my @Filenames = ();

  foreach my $FileKey (keys %Files) {
    if ($Files{$FileKey}{URL}) {
      my $URL = $Files{$FileKey}{URL};
      unless (&ValidFileURL($URL)) {
        push @ErrorStack,"The URL <tt>$URL</tt> is not well formed. Don't forget ".
                         "http:// on the front and a file name after the last /.";
      }
      my @Options = ();
      if ($Files{$FileKey}{User} && $Files{$FileKey}{Pass}) {
        push @DebugStack,"Using authentication";
        @Options = ("--http-user=".$Files{$FileKey}{User},
	            "--http-password=".$Files{$FileKey}{Pass});
      }

      # Allow for a new filename as supplied by the user

      if ($Files{$FileKey}{NewFilename}) {
        my @Parts = split /\//,$Files{$FileKey}{NewFilename};
        my $SecureFilename = pop @Parts;
        $Files{$FileKey}{NewFilename} = $SecureFilename;
        push @Options,"--output-document=".$Files{$FileKey}{NewFilename};
      }
      push @DebugStack,"Command is: ",join ' ',$Wget,"--quiet",@Options,$Files{$FileKey}{URL};
      my @Wget = split /\s+/,$Wget;
      $Status = system (@Wget,"--quiet",@Options,$Files{$FileKey}{URL});

      my @URLParts = split /\//,$Files{$FileKey}{URL};
      my $Filename;
      if ($Files{$FileKey}{NewFilename}) {
        $Filename = $Files{$FileKey}{NewFilename};
      } else {
        $Filename = CGI::unescape(pop @URLParts); # As downloaded, we hope
      }
      push @DebugStack, "Download ($Files{$FileKey}{URL}) status: $Status";
      if (-e "$TmpDir/$Filename") {
        push @Filenames,$Filename;
	delete $Files{$FileKey}{URL};
	$Files{$FileKey}{Filename} =  "$TmpDir/$Filename";
      } else {
        push @DebugStack,"Check for existence of $TmpDir/$Filename failed. Check unescape function.";
        push @WarnStack,"The URL $Files{$FileKey}{URL} did not exist, was not accessible or was not downloaded successfully.";
      }
    }
  }

  unless (@Filenames) {
    push @DebugStack,"No files were downloaded.";
    push @ErrorStack,"No files were downloaded.";
  }

  chdir $CurrentDir;
  return %Files;
}

sub MakeTmpSubDir {
  my $TmpSubDir = $TmpDir."/".(time ^ $$ ^ unpack "%32L*", `ps axww`);
  mkdir $TmpSubDir, oct 755 or die "Could not make temporary directory";
  return $TmpSubDir;
}

1;
