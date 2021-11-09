#
# Description: Input and output routines related to cross-referencing documents
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


sub PrintXRefInfo ($) {
  require "XRefSQL.pm";
  require "DocumentHTML.pm";
  require "DocumentSQL.pm";
  require "RevisionSQL.pm";

  my ($DocRevID) = @_;

  my $DocumentLink    = ();
  my $DocumentID      = ();
  my $Version         = ();
  my $ExtProject      = ();
  my $CanAccess       = ();
  my $LastVersion     = ();
  my $ExternalDocDBID = ();
  my $PublicURL       = ();
  my $PrivateURL      = ();
  my $ThisDocID       = ();
  my $ThisVersion     = ();
  my $ThisLastVersion = ();
  my $DocumentID      = ();
  my @RawDocXRefIDs   = ();
  my @DocXRefIDs      = ();
  my %SeenDocument    = ();

### Find and print documents this revision links to
  my @DocXRefIDs = FetchXRefs(-docrevid => $DocRevID);


  if (@DocXRefIDs) {
    print "<div id=\"XRefs\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Related Documents:</span></dt>\n";
    #print "</dl>\n";
    print "<ul>\n";
    foreach $DocXRefID (@DocXRefIDs) {
       $DocumentLink = "";
       $DocumentID = $DocXRefs{$DocXRefID}{DocumentID};
       $Version    = $DocXRefs{$DocXRefID}{Version};
       $ExtProject = $DocXRefs{$DocXRefID}{Project};

# Roy Williams June 2010.
       $CanAccess = ();
       if ($Version){
          $CanAccess = CanAccess($DocumentID,$Version);
       } else {
          FetchDocument($DocumentID);
          $LastVersion = $Documents{$DocumentID}{NVersions};
          $CanAccess = CanAccess($DocumentID,$LastVersion);
       }
       if (!$CanAccess) {
          next;  # skip refs to docs that customer cannot see
       }
# end

       if ($ExtProject && $ExtProject ne $ShortProject) {
          $ExternalDocDBID = FetchExternalDocDBByName($ExtProject);
          $PublicURL  = $ExternalDocDBs{$ExternalDocDBID}{PublicURL};
          $PrivateURL = $ExternalDocDBs{$ExternalDocDBID}{PrivateURL};
          $DocumentLink  = "External document ";
          $DocumentLink .= "<a href=\"".$PublicURL."/ShowDocument?docid=$DocumentID";
          if ($Version =~ /\d+/) {
             $DocumentLink .= "&amp;version=$Version";
          }
          $DocumentLink .= "\">".$ExtProject."-doc-".$DocumentID;

          $DocumentLink .= "</a> (";
          $DocumentLink .= "<a href=\"".$PrivateURL."/ShowDocument?docid=$DocumentID";
          if ($Version =~ /\d+/) {
             $DocumentLink .= "&amp;version=$Version";
          }
          $DocumentLink .= "\">"."private link</a>)";
       } else {
          if ($Version =~ /\d+/) {
            $DocumentLink  = FullDocumentID($DocumentID,$Version).": ";
            $DocumentLink .= DocumentLink(-docid => $DocumentID, -version => $Version, -titlelink => $TRUE);
          } else {
            $DocumentLink  = FullDocumentID($DocumentID).": ";
            $DocumentLink .= DocumentLink(-docid => $DocumentID, -titlelink => $TRUE);
          }
       }
       print "<li>$DocumentLink</li>\n";
    }
    print "</ul>\n";
    print "</dl></div>\n"; ####
  }

### Find and print documents which link to this one


   $ThisDocID = $DocRevisions{$DocRevID}{DOCID};
   $ThisVersion = $DocRevisions{$DocRevID}{Version};
   $ThisLastVersion = ();
   FetchDocument($RefDocID);
   $ThisLastVersion = $Documents{$ThisDocID}{NVersions};

   @RawDocXRefIDs = ();

  if ($ThisLastVersion == $ThisVersion) {
      #print DEBUG "This is last version\n";
      @RawDocXRefIDs = FetchXRefs(-docid => $DocRevisions{$DocRevID}{DOCID});
  } else  {
      #print DEBUG "This is not last version $ThisVersion\n";
      @RawDocXRefIDs = FetchXRefs(-docid => $DocRevisions{$DocRevID}{DOCID},
                                 -version =>$DocRevisions{$DocRevID}{Version});
  }

   @DocXRefIDs = ();

  foreach $DocXRefID (@RawDocXRefIDs) { # Remove links to other projects, versions
     $ExtProject = $DocXRefs{$DocXRefID}{Project};
     $Version    = $DocXRefs{$DocXRefID}{Version};

    if ($ExtProject eq $ShortProject || !$ExtProject) {

      if ($Version) {
      	  if ($Version == $DocRevisions{$DocRevID}{Version}) {
             push @DocXRefIDs,$DocXRefID;
          }
      } else {

           my $DocRevID = $DocXRefs{$DocXRefID}{DocRevID};
           FetchDocRevisionByID($DocRevID);
           $RefDocID = $DocRevisions{$DocRevID}{DOCID};
           FetchDocument($RefDocID);
           $LastVersion = $Documents{$RefDocID}{NVersions};

      	  if ($LastVersion == $DocRevisions{$DocRevID}{Version}) {
             push @DocXRefIDs,$DocXRefID;
          }
      }
    }
  }

  #print DEBUG "Final Referenced DocXRefIDs: @DocXRefIDs\n";

  if (@DocXRefIDs) {
    print "<div id=\"XReffedBy\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Referenced by:</span></dt>\n";
    print "<ul>\n";
     %SeenDocument = ();
    foreach $DocXRefID (@DocXRefIDs) {
       $DocRevID = $DocXRefs{$DocXRefID}{DocRevID};
      FetchDocRevisionByID($DocRevID);
      if ($DocRevisions{$DocRevID}{Obsolete}) {
        next;
      }
       $DocumentID = $DocRevisions{$DocRevID}{DOCID};
       $Version    = $DocRevisions{$DocRevID}{Version};

# Roy Williams June 2010.
       $CanAccess = ();
      if ($Version){
        $CanAccess = CanAccess($DocumentID,$Version);
      } else {
        FetchDocument($DocumentID);
        $LastVersion = $Documents{$DocumentID}{NVersions};
        $CanAccess = CanAccess($DocumentID,$LastVersion);
      }
      if (!$CanAccess) {
        next;  # skip refs to docs that customer cannot see
      }
# end

      $DocumentLink = "";
      if ($DocumentID && !$SeenDocument{$DocumentID}) {
        if ($Version) {
           $DocumentLink  = FullDocumentID($DocumentID, $Version).": ";
           $DocumentLink .= DocumentLink(-docid => $DocumentID, -version => $Version, -titlelink => $TRUE);
        } else {
           $DocumentLink  = FullDocumentID($DocumentID).": ";
           $DocumentLink .= DocumentLink(-docid => $DocumentID, -titlelink => $TRUE);
        }
        print "<li>$DocumentLink</li>\n";
        $SeenDocument{$DocumentID} = $TRUE;
      }
    }
    print "</ul>\n";
    print "</dl></div>\n";
  }
}

sub ExternalDocDBLink ($) {
   my ($ArgRef) = @_;
   my $DocDBID = exists $ArgRef->{-docdbid} ? $ArgRef->{-docdbid} : 0;
   my $Link  = "<a href=\"$ExternalDocDBs{$DocDBID}{PublicURL}/DocumentDatabase\"";
      $Link .= "title=\"$ExternalDocDBs{$DocDBID}{Description}\">";
      $Link .= $ExternalDocDBs{$DocDBID}{Project};
      $Link .= '</a>';
   return $Link;
}

sub ExternalDocDBSelect (;%) {
   require "FormElements.pm";
   require "XRefSQL.pm";
   require "Sorts.pm";

   my (%Params) = @_;

   my $Disabled = $Params{-disabled} || "0";
   my $Multiple = $Params{-multiple} || "0";
   my $Required = $Params{-required} || "0";
   my $Format   = $Params{-format}   || "short";
   my @Defaults = @{$Params{-default}};
   my $OnChange = $Params{-onchange} || undef;

   my %Options = ();

   if ($Disabled) {
      $Options{-disabled} = "disabled";
   }
   if ($OnChange) {
      $Options{-onchange} = $OnChange;
   }

   &GetAllExternalDocDBs;
   my @ExternalDocDBIDs = keys %ExternalDocDBs;
   my %Labels = ();
   foreach my $ExternalDocDBID (@ExternalDocDBIDs) {
     if ($Format eq "full") {
        $Labels{$ExternalDocDBID} = $ExternalDocDBs{$ExternalDocDBID}{Project}.
        ":".$ExternalDocDBs{$ExternalDocDBID}{Description};
     } else {
        $Labels{$ExternalDocDBID} = $ExternalDocDBs{$ExternalDocDBID}{Project};
     }
  }

  my $ElementTitle = &FormElementTitle(-helplink => "extdocdb",
                                       -helptext => "Project",
                                       -required => $Required);

  print $ElementTitle;
  print $query -> scrolling_list(-name     => "externaldocdbs",
                                 -values   => \@ExternalDocDBIDs,
                                 -labels   => \%Labels,       -size    => 10,
                                 -multiple => $Multiple,      -default => \@Defaults,
                                 %Options);
}

1;
