
# Description: Subroutines to provide links for files, groups of
#              files and archives.
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

sub FileListByRevID {
    require "MiscSQL.pm";
    my ($DocRevID) = @_;

    my @FileIDs    = &FetchDocFiles($DocRevID);
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    my $Version    = $DocRevisions{$DocRevID}{VERSION};

    print "<div id=\"Files\">\n";
    print "<dl>\n";
    print
"<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Files in Document:</span></dt>\n";

    if (@FileIDs) {
        @RootFiles  = ();
        @OtherFiles = ();
        foreach my $FileID (@FileIDs) {
            if ( $DocFiles{$FileID}{ROOT} ) {
                push @RootFiles, $FileID;
            }
            else {
                push @OtherFiles, $FileID;
            }
        }
        if (@RootFiles) {
            print "<dd class=\"FileList\">\n";
            &FileListByFileID(@RootFiles);
            print "</dd>\n";
        }
        if (@OtherFiles) {
            print "<dd class=\"FileList\"><em>Other Files:</em>\n";
            &FileListByFileID(@OtherFiles);
            print "</dd>\n";
        }
        unless ($Public) {
            my $ArchiveLink = &ArchiveLink( $DocumentID, $Version );

            #print "<dd class=\"FileList\"><em>$ArchiveLink</em></dd>\n";
        }
    }
    else {
        print "<dd>None</dd>\n";
    }
    print "</dl>\n";
    print "</div>\n";
    &ICSLink;
    PnPLink($DocRevID);

}

sub ICSLink {
    my $DocumentAlias = FetchDocumentAlias($DocumentID);
    $DocumentAlias =~ /^D/
      && print "<!-- ICS/JIRA Link for Drawings and Assemblies -->
   <div id=\"ICSLink\">
      <dl>
         <dt class=\"InfoHeader\">
            <span class=\"InfoHeader\">ICS/JIRA Record:</span>
         </dt>
         <dd class=\"FileList\">
            <ul><li>ICS_LINK</li></ul>
         </dd>
     </dl>
   </div>
   <!-- We only show the ICSLink div if it's a 'D' document. -->
   <script>
      DisplayICSLink();
   </script>
<!-- END of D Document ICS/JIRA specific code. -->
"
}

sub PnPLink ($) {

    my ($DocRevID) = @_;

    require "DocumentReviewSQL.pm";
    require "SecuritySQL.pm";

    if ( hasReviewState($DocRevID) && ($Public != 1)) {
        $ReviewState = $DocRevisions{$DocRevID}{ReviewState};
        $ReviewDate  = $DocRevisions{$DocRevID}{ReviewStamp};
        $ReviewActor = $DocRevisions{$DocRevID}{ReviewActor};
        $ActorString = FetchNameFromEmployeeNumber($ReviewActor);

        $ReviewStateMsg =
            $ReviewStates{$ReviewState} . " on "
          . $ReviewDate . " by "
          . $ActorString;

        print "<div id=\"PnP_Link\">\n";
        print "<dl>\n";
        print
"<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Publications & Presentations Status:</span></dt>\n";
        print "<dd>$ReviewStateMsg</dd>\n";
        print "</dl>\n";
        print "</div>\n";
    }
}

sub ShortFileListByRevID {
    require "MiscSQL.pm";
    my ($DocRevID) = @_;

    my @FileIDs    = &FetchDocFiles($DocRevID);
    my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
    my $Version    = $DocRevisions{$DocRevID}{VERSION};

    @RootFiles = ();
    foreach $File (@FileIDs) {
        if ( $DocFiles{$File}{ROOT} ) {
            push @RootFiles, $File;
        }
    }
    if (@RootFiles) {
        &ShortFileListByFileID(@RootFiles);
    }
    else {
        print "None<br/>\n";
    }
}

sub FileListByFileID {
    require "Sorts.pm";

    my (@Files) = @_;
    unless (@Files) {
        return;
    }

    @Files = sort FilesByDescription @Files;

    print "<ul>\n";
    foreach my $FileID (@Files) {
        my $DocRevID   = $DocFiles{$FileID}{DOCREVID};
        my $Version    = $DocRevisions{$DocRevID}{VERSION};
        my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
        my $Link       = FileLink(
            {
                -docid       => $DocumentID,
                -version     => $Version,
                -shortname   => $DocFiles{$FileID}{NAME},
                -description => $DocFiles{$FileID}{DESCRIPTION}
            }
        );
        print "<li>$Link</li>\n";
    }
    print "</ul>\n";
}

sub ShortFileListByFileID {    # FIXME: Make special case of FileListByFileID
    require "Sorts.pm";

    my (@Files) = @_;

    @Files = sort FilesByDescription @Files;

    foreach my $FileID (@Files) {
        my $DocRevID   = $DocFiles{$FileID}{DOCREVID};
        my $Version    = $DocRevisions{$DocRevID}{VERSION};
        my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
        my $Link       = FileLink(
            {
                -maxlength   => 20,
                -format      => "short",
                -docid       => $DocumentID,
                -version     => $Version,
                -shortname   => $DocFiles{$FileID}{NAME},
                -description => $DocFiles{$FileID}{DESCRIPTION}
            }
        );
        print "$Link<br/>\n";
    }
}

sub FileLink ($) {
    my ($ArgRef) = @_;

    my $DocumentID = exists $ArgRef->{-docid}     ? $ArgRef->{-docid}     : 0;
    my $Version    = exists $ArgRef->{-version}   ? $ArgRef->{-version}   : 0;
    my $ShortName  = exists $ArgRef->{-shortname} ? $ArgRef->{-shortname} : "";
    my $Description =
      exists $ArgRef->{-description} ? $ArgRef->{-description} : "";
    my $MaxLength = exists $ArgRef->{-maxlength} ? $ArgRef->{-maxlength} : 60;
    my $MaxExt    = exists $ArgRef->{-maxext}    ? $ArgRef->{-maxext}    : 4;
    my $Format = exists $ArgRef->{-format} ? $ArgRef->{-format} : "long";

    require "FSUtilities.pm";
    require "FileUtilities.pm";
    require "DocumentSQL.pm";

    my $ShortFile = CGI::escape($ShortName);
    my $BaseURL   = GetURLDir( $DocumentID, $Version );
    my $FileSize  = FileSize( FullFile( $DocumentID, $Version, $ShortName ) );

    $FileSize =~ s/^\s+//;    # Chop off leading spaces

    my $PrintedName = $ShortName;
    if ($MaxLength) {
        $PrintedName = AbbreviateFileName(
            -filename  => $ShortName,
            -maxlength => $MaxLength,
            -maxext    => $MaxExt
        );
    }

    my $URL = $BaseURL . $ShortFile;

    #  my $URL = "/".FullDocumentID($DocumentID, $Version)."/pdf";

    if (   $UserValidation eq "certificate"
        || $Preferences{Options}{AlwaysRetrieveFile} )
    {
        $URL =
            $RetrieveFile
          . "?docid="
          . $DocumentID
          . "&amp;version="
          . $Version
          . "&amp;filename="
          . $ShortFile;
    }

    my $Link = "";

    if ( $Format eq "short" ) {
        if ($Description) {
            return "<a href=\"$URL\" title=\"$ShortName\">$Description</a>";
        }
        else {
            return "<a href=\"$URL\" title=\"$ShortName\">$PrintedName</a>";
        }
    }
    else {
        if ($Description) {
            return
"<a href=\"$URL\" title=\"$ShortName\">$Description</a> ($PrintedName, $FileSize)";
        }
        else {
            return
"<a href=\"$URL\" title=\"$ShortName\">$PrintedName</a> ($FileSize)";
        }
    }
}

sub ArchiveLink {
    my ( $DocumentID, $Version ) = @_;

    my @Types = ("tar.gz");
    if ($Zip) { push @Types, "zip"; }

    @Types = sort @Types;

    my $link = "Get all files as \n";
    @LinkParts = ();
    foreach my $Type (@Types) {
        push @LinkParts,
"<a href=\"$RetrieveArchive?docid=$DocumentID\&amp;version=$Version\&amp;type=$Type\">$Type</a>";
    }
    $link .= join ', ', @LinkParts;
    $link .= ".";

    return $link;
}

sub FileUploadBox (%) {
    my (%Params) = @_;

    my $Type        = $Params{-type}        || "file";
    my $DescOnly    = $Params{-desconly}    || 0;
    my $AllowCopy   = $Params{-allowcopy}   || 0;
    my $MaxFiles    = $Params{-maxfiles}    || 0;
    my $AddFiles    = $Params{-addfiles}    || 0;
    my $DocRevID    = $Params{-docrevid}    || 0;
    my $Required    = $Params{-required}    || 0;
    my $FileSize    = $Params{-filesize}    || 60;
    my $FileMaxSize = $Params{-filemaxsize} || 250;

    my @FileIDs = @{ $Params{-fileids} };

    require "Sorts.pm";

    if ($DocRevID) {
        require "MiscSQL.pm";
        @FileIDs = &FetchDocFiles($DocRevID);
    }

    my @RootFiles  = ();
    my @OtherFiles = ();

    foreach my $FileID (@FileIDs) {
        if ( $DocFiles{$FileID}{ROOT} ) {
            push @RootFiles, $FileID;
        }
        else {
            push @OtherFiles, $FileID;
        }
    }

    @RootFiles  = sort FilesByDescription @RootFiles;
    @OtherFiles = sort FilesByDescription @OtherFiles;
    @FileIDs    = ( @RootFiles, @OtherFiles );
    my $NOrigFiles = scalar(@FileIDs);
    unless ($MaxFiles) {
        if (@FileIDs) {
            $MaxFiles = @FileIDs + $AddFiles;

        }
        elsif ($NumberUploads) {
            $MaxFiles = $NumberUploads;
        }
        elsif ( $UserPreferences{NumFiles} ) {
            $MaxFiles = $UserPreferences{NumFiles};
        }
        else {
            $MaxFiles = 1;
        }
    }

    my (
        $HelpLink,     $HelpText,     $FileHelpLink,
        $FileHelpText, $DescHelpLink, $DescHelpText
    );
    if ( $Type eq "file" ) {
        $HelpLink     = "fileupload";
        $HelpText     = "Local file upload";
        $FileHelpLink = "localfile";
        $FileHelpText = "File";
    }
    elsif ( $Type eq "http" ) {
        $HelpLink     = "httpupload";
        $HelpText     = "Upload by HTTP";
        $FileHelpLink = "remoteurl";
        $FileHelpText = "URL";
    }

    if ($DescOnly) {
        $HelpLink = "filechar";
        $HelpText = "Update File Characteristics";
    }

    $DescHelpLink = "description";
    $DescHelpText = "Description";

    my $BoxTitle = FormElementTitle(
        -helplink => $HelpLink,
        -helptext => $HelpText,
        -required => $Required
    );
    my $NumberofFiles;
    if ($DescOnly) {
       $NumberofFiles= $query ->hidden( -name => 'maxfiles', -value => $MaxFiles );
    } else {
       $NumberofFiles =  FormElementTitle(
		-helplink  => 'numberoffiles',
		-helptext  => 'Maximum Number of Files',
		-nobreak   => 1,
		-extratext => $query->popup_menu(
		    -name     => 'maxfiles',
		    -values   => [ "$MaxFiles", '10', '30', '100' ],
		    -default  => $MaxFiles,
		    -onChange => 'changeUploadSlots(event);'
		)
	    );
    }
    print <<"    EOD";

    <script src='/Static/js/dynUploadSlots.js'></script>

    <div>$BoxTitle</div>

    <p>
        When possible, please upload a .pdf version as the first and only 'Main' file.<br>
        Original source files (.ppt, .doc, etc.) should <b>not</b> be checked off as 'Main'.
    </p>

    <div>
        $NumberofFiles
    </div> 
    EOD

    my $MainHeader = FormElementTitle(
        -helplink => "main",
        -helptext => "Main?",
        -nocolon  => $TRUE,
        -nobold   => $TRUE
    );

    print "<table id='dynamicUploadSlots' class='LowPaddedTable LeftHeader'>\n";

    for ( my $i = 1 ; $i <= $MaxFiles ; ++$i ) {
        my $FileID      = shift @FileIDs;
        my $ElementName = "upload$i";
        my $DescName    = "filedesc$i";
        my $MainName    = "main$i";
        my $FileIDName  = "fileid$i";
        my $CopyName    = "copyfile$i";
        my $URLName     = "url$i";
        my $NewName     = "newname$i";

        # update, updatedb, add, or replace
        my $UpdateMode = $params{mode};

        if ( $UpdateMode eq "add" ) {
            $checkit = "";
        }
        elsif ( $i == 1 ) {
            if ( defined $DocFiles{$FileID}{ROOT} ) {
                $checkit = $DocFiles{$FileID}{ROOT};
            }
            else {
                $checkit = 'checked';
            }
        }
        else {
            $checkit = $DocFiles{$FileID}{ROOT};
        }

        my $FileHelp = FormElementTitle(
            -helplink => $FileHelpLink,
            -helptext => $FileHelpText
        );
        my $DescriptionHelp = FormElementTitle(
            -helplink => $DescHelpLink,
            -helptext => $DescHelpText
        );
        my $NewNameHelp = FormElementTitle(
            -helplink => "newfilename",
            -helptext => "New Filename"
        );
        my $MainHelp = FormElementTitle(
            -helplink => "main",
            -helptext => "Main?",
            -nocolon  => $TRUE,
            -nobold   => $TRUE
        );
        my $DefaultDesc = $DocFiles{$FileID}{DESCRIPTION};

        print "<tr><th></th><td> <span style='float: right;'>$MainHeader</span></td></tr>\n";
        $MainHeader = "&nbsp;";
        if ($DescOnly) {
            print "<tr>\n";
            print "<th>Filename:</th>";
            print "<td>\n";
            print $DocFiles{$FileID}{NAME};
            print $query ->hidden( -name => $FileIDName, -value => $FileID );
            print "</td>\n";
            print "</tr>\n";
        }
        else {
            print "<tr><th>\n";
            print $FileHelp;
            print "</th>\n";

            print "<td>\n";
            if ( $Type eq "file" ) {

                # Roy Williams Mar 2010
                print $query ->filefield(
                    -name      => $ElementName,
                    -id        => $ElementName,
                    -size      => $FileSize,
                    -maxlength => $FileMaxSize,
                    onChange   => 'validateFilename(this);'
                );
            }
            elsif ( $Type eq "http" ) {
                print $query ->textfield(
                    -name      => $URLName,
                    -size      => $FileSize,
                    -maxlength => $FileMaxSize
                );
            }
            print "</td>\n";
            print "</tr>\n";

            if ( $Type eq "http" ) {
                print "<tr><th>\n";
                print $NewNameHelp;
                print "</th>\n";

                print "<td>\n";
                print $query ->textfield(
                    -name      => $NewName,
                    -size      => $FileSize,
                    -maxlength => $FileMaxSize
                );
                print "</td>\n";
                print "</tr>\n";
            }
        }
        print "<tr><th>\n";
        print $DescriptionHelp;
        print "</th>\n";
        print "<td>\n";
        print $query ->textfield(
            -name      => $DescName,
            -size      => 60,
            -maxlength => 128,
            -default   => $DefaultDesc
        );
        print "<span style=\"float: right; padding: 0 1em;\">";
        print $query ->checkbox( -name => $MainName, -checked => $checkit,
            -label => '' );
        print "</span>";

        #print $MainHelp;
        print "</td></tr>\n";
        if ( $FileID && $AllowCopy && !$DescOnly ) {
            print "<tr><td>&nbsp;</td><td colspan=\"2\">\n";
            print
              "Copy <tt>$DocFiles{$FileID}{NAME}</tt> from previous version:";
            print $query ->hidden( -name => $FileIDName, -value => $FileID );
            print $query ->checkbox( -name => $CopyName, -label => '' );
            print "</td></tr>\n";
        }
    }
    if ( $AllowCopy && $NOrigFiles ) {
        print '<tr><td colspan="2">';
        print $query ->checkbox( -name => 'LessFiles', -label => '' );
        print FormElementTitle(
            -helplink => "LessFiles",
            -helptext => "New version has fewer files",
            -nocolon  => $TRUE,
            -nobold   => $TRUE
        );
        print "</td></tr>\n";
    }
    if ( $Type eq "http" ) {
        print "<tr><th>User:</th>\n";
        print "<td>\n";
        print $query ->textfield( -name => 'http_user', -size => 20,
            -maxlength => 40 );
        print "<b>&nbsp;&nbsp;&nbsp;&nbsp;Password:</b>\n";
        print $query ->password_field(
            -name      => 'http_pass',
            -size      => 20,
            -maxlength => 40
        );
        print "</td></tr>\n";
    }
    print "</table>\n";
}

sub ArchiveUploadBox (%) {
    my (%Params) = @_;

    my $Required = $Params{-required} || 0;    # short, long, full

    print "<table class=\"LowPaddedTable LeftHeader\">\n";
    print "<tr><td colspan=\"2\">";
    print FormElementTitle(
        -helplink => "filearchive",
        -helptext => "Archive file upload",
        -required => $Required
    );
    print "</td></tr> \n";
    print "<tr><th>Archive File:</th><td>\n";
    print $query ->filefield(
        -name      => "single_upload",
        -size      => 60,
        -maxlength => 250
    );

    print "<tr><th>Main file in archive:</th><td>\n";
    print $query ->textfield( -name => 'mainfile', -size => 70,
        -maxlength => 128 );

    print "<tr><th>Description of file:</th><td>\n";
    print $query ->textfield( -name => 'filedesc', -size => 70,
        -maxlength => 128 );
    print "</td></tr></table>\n";
}

1;
