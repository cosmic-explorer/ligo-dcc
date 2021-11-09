#
# Description: Routines to create HTML elements for authors and institutions
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

sub FirstAuthor ($;$) {
  my ($DocRevID,$ArgRef) = @_;
  my $Institution = exists $ArgRef->{-institution} ? $ArgRef->{-institution} : $FALSE;

  require "AuthorSQL.pm";
  require "AuthorUtilities.pm";
  require "Sorts.pm";

  FetchDocRevisionByID($DocRevID);

  my $FirstID = FirstAuthorID( {-docrevid => $DocRevID} );
  unless ($FirstID) {return "None";}
  my @AuthorRevIDs = GetRevisionAuthors($DocRevID);

  my $AuthorLink = AuthorLink($FirstID);
  if ($#AuthorRevIDs) {$AuthorLink .= " <i>et al.</i>";}
  elsif (FirstAuthorGroup($DocRevID) ne "None") {$AuthorLink .= " <i>et al.</i>";}

  if ($Institution) {
    FetchInstitution($Authors{$FirstID}{InstitutionID});
    $AuthorLink .= "<br/><em>".
                   $Institutions{$Authors{$FirstID}{InstitutionID}}{SHORT}.
                   "</em>";
  }  
  return $AuthorLink; 
}

sub FirstAuthorGroup ($;$) {
  my ($DocRevID,$ArgRef) = @_;

  require "AuthorSQL.pm";
  require "AuthorUtilities.pm";
  require "Sorts.pm";

  FetchDocRevisionByID($DocRevID);

  my $FirstID = FirstAuthorGroupID( {-docrevid => $DocRevID} );

  unless ($FirstID) {return "None";}

  FetchAuthorGroup($FirstID);
  my @AuthorGroupRevIDs = GetAuthorGroups($DocRevID);

  my $AuthorGroupLink = ();
  my $index = 0;
  foreach my $AuthorGroupRevID (@AuthorGroupRevIDs) {
      $AuthorGroupLink .= AuthorGroupLink($AuthorGroupRevID);
      if ($index != $#AuthorGroupRevIDs) {
          $AuthorGroupLink .= " <i>, </i>";
      }
      $index++;
  }

  return $AuthorGroupLink; 
}

sub AuthorListByAuthorRevID {
  my ($ArgRef) = @_;

  my @AuthorRevIDs = exists $ArgRef->{-authorrevids} ? @{$ArgRef->{-authorrevids}} : ();
  my @AuthorGroupRevIDs = exists $ArgRef->{-authorgrouprevids} ? @{$ArgRef->{-authorgrouprevids}} : ();
  my $Format       = exists $ArgRef->{-format}       ?   $ArgRef->{-format}        : "long";
#  my $ListFormat  = exists $ArgRef->{-listformat}  ?   $ArgRef->{-listformat}  : "dl";
#  my $ListElement = exists $ArgRef->{-listelement} ?   $ArgRef->{-listelement} : "short";
#  my $LinkType    = exists $ArgRef->{-linktype}    ?   $ArgRef->{-linktype}    : "document";
#  my $SortBy      = exists $ArgRef->{-sortby}      ?   $ArgRef->{-sortby}      : "";
  
  require "AuthorUtilities.pm";
  require "Sorts.pm";
  
  @AuthorRevIDs = sort AuthorRevIDsByOrder @AuthorRevIDs;
  my @AuthorIDs = AuthorRevIDsToAuthorIDs({ -authorrevids => \@AuthorRevIDs, });

  my @AuthorGroupIDs = AuthorGroupRevIDsToAuthorGroupIDs({ -authorgrouprevids => \@AuthorGroupRevIDs, });
  
  my $HTML;
  if ($Format eq "long") {
    $HTML = AuthorListByID({ -listformat => "dl", -authorids => \@AuthorIDs, -authorgroupids => \@AuthorGroupIDs});
  } elsif ($Format eq "short") {
    $HTML = AuthorListByID({ -listformat => "br", -authorids => \@AuthorIDs, -authorgroupids => \@AuthorGroupIDs});
  }
  
  print $HTML;
  
}

sub AuthorListByID {
  my ($ArgRef) = @_;
  my @AuthorIDs   = exists $ArgRef->{-authorids}   ? @{$ArgRef->{-authorids}}  : ();
  my @AuthorGroupIDs   = exists $ArgRef->{-authorgroupids}   ? @{$ArgRef->{-authorgroupids}}  : ();
  my $ListFormat  = exists $ArgRef->{-listformat}  ?   $ArgRef->{-listformat}  : "dl";
#  my $ListElement = exists $ArgRef->{-listelement} ?   $ArgRef->{-listelement} : "short";
  my $LinkType    = exists $ArgRef->{-linktype}    ?   $ArgRef->{-linktype}    : "document";
  my $SortBy      = exists $ArgRef->{-sortby}      ?   $ArgRef->{-sortby}      : "";
  my $ListingType = exists $ArgRef->{-listingtype} ? $ArgRef->{-listingtype} : ""; ##### VK 09-04-13
  
  require "AuthorSQL.pm";
  require "Sorts.pm";
  require "AuthorSQL.pm"; ###

  foreach my $AuthorID (@AuthorIDs) {
    FetchAuthor($AuthorID);
  }

  foreach my $AuthorGroupID (@AuthorGroupIDs) {
    FetchAuthorGroup($AuthorGroupID);
  }

  if ($SortBy eq "name") {
    @AuthorIDs = sort byLastName     @AuthorIDs;
  }

 #my ($HTML,$StartHTML,$EndHTML,$StartElement,$EndElement,$StartList,$EndList,$NoneText);
  my ($HTML,$StartHTML,$EndHTML,$StartElement,$EndElement,$StartList,$EndList,$NoneText,$MailStart,$MailEnd);
  
  if (scalar(@AuthorIDs) > 0) {
  require "DocumentSQL.pm"; # get alias
  my $DocAlias = FetchDocumentAlias($DocumentID);

  if ($ListFormat eq "dl") {
    #$StartHTML .= '<div id="Authors"><dl>';
    $StartHTML .= '<div id="Authors">';
    $StartHTML .= '<dl>';
   #$StartHTML .= '<dt class="InfoHeader"><span class="InfoHeader">Authors:</span></dt>';
    $StartHTML .= '<dt class="InfoHeader"><span class="InfoHeader">Authors:';
    ##########
    # "Contact all authors" in Authors heading - VK 06-2013
    @all_emails = ();
    foreach my $AuthorID (@AuthorIDs) {
      my $mail = GetAuthorEmail($AuthorID);
      if ($mail) {
        push @all_emails, $mail;
      } else {
        $AuthorEmailAddress = '';
      }
    }
    $full_list = join ',', map qq($_), @all_emails;
    $contact_all = " <a href=\"mailto:$full_list\?Subject\=DCC document LIGO\-$DocAlias\"><img src=\"".$ImgURLPath."/mail-all.png\" title\=\"Contact all authors\" alt\=\"Send email to all authors\"></a>";

    if (scalar(@all_emails) > 1) {
      $StartHTML .= $contact_all;
    }
    $StartHTML .= '</span></dt>';
    $EndHTML    = '</dl></div>';
    $StartList  = '<ul>';
    $EndList    = '</ul>';
    $StartElement = '<li>';
    $EndElement   = '</li>';
    $NoneText     = '<div id="Authors"><dl><dt class="InfoHeader"><span class="InfoHeader">Authors:</span></dt>None<br/></dl>';
  } else {  #$ListFormat eq "br"
    $StartHTML  = '<div>';
    $EndHTML    = '</div>';
    $EndElement = '<br/>';
    $NoneText   = 'None<br/>';
  }  
  # per bugzilla #514
  # if on a public page and there is an AuthorGroup, do not list individual authors.
  unless ($Public && @AuthorGroupIDs) {
    if (@AuthorIDs) {
       require "DocumentSQL.pm"; ###
       my $DocAlias = FetchDocumentAlias($DocumentID); ###
           $HTML .= $StartHTML;
           $HTML .= $StartList;
           $MailStart = ' <a href=\'mailto:';      ###
          #$MailSubject = '?Subject=DCC document LIGO-'.$DocAlias; ###
          ##### VK 09-04-13:
           if ($ListingType eq "speaker") {
              $MailSubject = '';
              $MailEnd = '\'><img src=\''.$ImgURLPath.'/mail.png\' title=\'Contact this speaker\' alt=\'Send email to this speaker\'></a>';
           } else {
              $MailSubject = '?Subject=DCC document LIGO-'.$DocAlias;
              $MailEnd = '\'><img src=\''.$ImgURLPath.'/mail.png\' title=\'Contact this author\' alt=\'Send email to this author\'></a>'; 
           }
           #####
          #$MailEnd = '\'><img src=\''.$ImgURLPath.'/mail.png\' title=\'Contact this author\' alt=\'Send email to this author\'></a>';  ###
           foreach my $AuthorID (@AuthorIDs) {
             my $mail = GetAuthorEmail($AuthorID);              ###
             if ($mail) {                                       ###
                 $AuthorEmailAddress = $MailStart.$mail.$MailSubject.$MailEnd; ###
             } else {                                           ###
                 $AuthorEmailAddress = '';                         ###
             }                                                  ###
            #$HTML .= $StartElement.AuthorLink($AuthorID,-type => $LinkType).$EndElement;
             $HTML .= $StartElement.AuthorLink($AuthorID,-type => $LinkType).$AuthorEmailAddress.$EndElement; ###
           }
           $HTML .= $EndList;
     } else {
       $HTML = $NoneText;
     }
     $HTML .= $EndHTML;
    } # if AuthorID
  } # unless

  if (@AuthorGroupIDs) {
   
    $StartHTML = '<div id="AuthorGroups"><dl>';
    $StartHTML .= '<dt class="InfoHeader"><span class="InfoHeader">Author Groups:</span></dt>';
    #$StartHTML .= '</dl>';
    #$EndHTML    = '</div>';
    $StartHTML .= '</span></dt>';
    $EndHTML    = '</dl></div>';
    $StartList  = '<ul>';
    $EndList    = '</ul>';
    $StartElement = '<li>';
    $EndElement   = '</li>';
    #    $NoneText     = '<div id="AuthorGroups"><dl><dt class="InfoHeader"><span class="InfoHeader">AuthorGroups:</span></dt>None<br/></dl>';
    $HTML .= $StartHTML;
    $HTML .= $StartList;
    foreach my $AuthorGroupID (@AuthorGroupIDs) {
      $HTML .= $StartElement.AuthorGroupLink($AuthorGroupID, -type => $LinkType).$EndElement;
    }
    $HTML .= $EndList;
    #close your fragments pple !!!
    $HTML .= $EndHTML;
  }
  PrettyHTML($HTML);
}

sub RequesterByID { 
require "AuthorSQL.pm"; ###
require "DocumentSQL.pm"; ###
my $DocAlias = FetchDocumentAlias($DocumentID); ###
  my ($RequesterID) = @_;

  my $AuthorLink   = &AuthorLink($RequesterID);
  my $EmailAddress = FetchEmail($RequesterID); ###
  print "<dt>Submitted by:</dt>\n";
  ###print "<dd>$AuthorLink</dd>\n";
  print "<dd>$AuthorLink";
  unless (!$EmailAddress) {
    print " <a href=\"mailto:$EmailAddress\?Subject\=DCC document LIGO\-$DocAlias\"><img src=\"".$ImgURLPath."/mail.png\" title=\"Contact\" alt\=\"Send email\"></a>";
  }
  print "</dd>\n";
}

sub SubmitterByID { 
require "AuthorSQL.pm"; ###
require "DocumentSQL.pm"; ###
my $DocAlias = FetchDocumentAlias($DocumentID); ###
  my ($RequesterID) = @_;
  
  my $AuthorLink   = &AuthorLink($RequesterID);
  my $EmailAddress = FetchEmail($RequesterID); ###
  print "<dt>Updated by:</dt>\n";
  ###print "<dd>$AuthorLink</dd>\n";
  print "<dd>$AuthorLink";
  unless (!$EmailAddress) {
    print " <a href=\"mailto:$EmailAddress\?Subject\=DCC document LIGO\-$DocAlias\"><img src=\"".$ImgURLPath."/mail.png\" title=\"Contact\" alt\=\"Send email\"></a>";
  }
  print "</dd>\n";
}

sub AuthorLink ($;%) {
  require "AuthorSQL.pm";
  
  my ($AuthorID,%Params) = @_;
  my $Format = $Params{-format} || "full"; # full, formal
  my $Type   = $Params{-type}   || "document"; # document, event
  
  FetchAuthor($AuthorID);
  FetchInstitution($Authors{$AuthorID}{InstitutionID});
  my $InstitutionName = $Institutions{$Authors{$AuthorID}{InstitutionID}}{LONG};
  unless ($Authors{$AuthorID}{FULLNAME}) {
    return "Unknown";
  }  
  my $Script;
  if ($Type eq "event") {
    $Script = $ListEventsBy;
  } else {
    $Script = $ListBy;
  }    
  
  my $Link;
  $Link = "<a href=\"$Script?authorid=$AuthorID\" title=\"$InstitutionName\">";
  if ($Format eq "full") {
    $Link .= $Authors{$AuthorID}{FULLNAME};
  } elsif ($Format eq "formal") {
    $Link .= $Authors{$AuthorID}{Formal};
  }
  $Link .= "</a>";
  
  return $Link;
}

sub AuthorGroupLink ($;%) {
  require "AuthorSQL.pm";
  
  my ($AuthorGroupID,%Params) = @_;
  my $Type   = $Params{-type}   || "document"; # document, event
  
  FetchAuthorGroup($AuthorGroupID);
  unless ($AuthorGroups{$AuthorGroupID}{AuthorGroupName}) {
    return "Unknown";
  }  
  my $Script;
  if ($Type eq "event") {
    $Script = $ListEventsBy;
  } elsif ($Type eq "author") {
    $Script = $ListAuthors;
  } else {
    $Script = $ListBy;
  }    
  
  my $Link;
  $Link = "<a href=\"$Script?authorgroupid=$AuthorGroupID\" >";
  $Link .= $AuthorGroups{$AuthorGroupID}{AuthorGroupName};
  $Link .= "</a>";
  
  return $Link;
}

sub PrintAuthorInfo {
  require "AuthorSQL.pm";

  my ($AuthorID) = @_;
  
  &FetchAuthor($AuthorID);
  &FetchInstitution($Authors{$AuthorID}{InstitutionID});
  my $link = &AuthorLink($AuthorID);
  
  print "$link\n";
  print " of ";
  print $Institutions{$Authors{$AuthorID}{InstitutionID}}{LONG};
}

sub AuthorsByInstitution { 
  my ($InstID) = @_;
  require "Sorts.pm";

  my @AuthorIDs = sort byLastName keys %Authors;

  print "<td><strong>$Institutions{$InstID}{SHORT}</strong>\n";
  print "<ul>\n";
  foreach my $AuthorID (@AuthorIDs) {
    if ($InstID == $Authors{$AuthorID}{InstitutionID}) {
      my $author_link = &AuthorLink($AuthorID);
      print "<li>$author_link</li>\n";
    }  
  }  
  print "</ul></td>";
}

sub AuthorsTable {
  require "Sorts.pm";
  require "MeetingSQL.pm";
  require "MeetingHTML.pm";

  my @AuthorIDs     = sort byLastName keys %Authors;
  my $NCols         = 4;
  my $NPerCol       = int (scalar(@AuthorIDs)/$NCols);
  my $UseAnchors    = (scalar(@AuthorIDs) >= 75);
  my $CheckEvent    = $TRUE;
  
  if (scalar(@AuthorIDs) % $NCols) {++$NPerCol;}

  print "<table class=\"CenteredTable MedPaddedTable\">\n";
  if ($UseAnchors ) {
    print "<tr><th colspan=\"$NCols\">\n";
    foreach my $Letter (A..Z) {
      print "<a href=\"#$Letter\">$Letter</a>\n";
    }
    print "</th></tr>\n";
  }
  
  print "<tr>\n";
  
  my $NThisCol       = 0;
  my $PreviousLetter = "";
  my $FirstPass       = 1; # First sub-list of column
  my $StartNewColumn  = 1;
  my $CloseLastColumn = 0;
  foreach my $AuthorID (@AuthorIDs) {
    $FirstLetter = substr $Authors{$AuthorID}{LastName},0,1;
    $FirstLetter =~ tr/[a-z]/[A-Z]/;
    if ($NThisCol >= $NPerCol && $FirstLetter ne $PreviousLetter) {
      $StartNewColumn = 1;
    }
    
    if ($StartNewColumn) {
      if ($CloseLastColumn) {
        print "</ul></td>\n";
      }
      print "<td>\n";
      $StartNewColumn = 0;
      $NThisCol = 0;
      $FirstPass = 1;
    }
      
    ++$NThisCol;
    
    if ($FirstLetter ne $PreviousLetter) { 
      $PreviousLetter = $FirstLetter;
      unless ($FirstPass) {
        print "</ul>\n";
      }  
      $FirstPass = 0;
      if ($UseAnchors) {
        print "<a name=\"$FirstLetter\" />\n";
        print "<strong>$FirstLetter</strong>\n";
      }
      print "<ul>\n";
    }  
    my $AuthorLink = AuthorLink($AuthorID, -format => "formal");
#    if ($CheckEvent) {
#      my %Hash = GetEventsByModerator($AuthorID);
#      if (%Hash) {
#        $AuthorLink .= ListByEventLink({ -authorid => $AuthorID });
#      }
#    }    

    print "<li>$AuthorLink</li>\n";
    $CloseLastColumn = 1;
  }  
  print "</ul></td></tr>";
  print "</table>\n";
}

sub AuthorScroll (%) {
  require "AuthorSQL.pm";
  require "Sorts.pm";
  
  my (%Params) = @_;
  
  my $All       =   $Params{-showall}   || 0;
  my $Multiple  =   $Params{-multiple}  || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Individuals";
  my $ExtraText =   $Params{-extratext} || "";
# RDW added this extra param for onchange
  my $OnChange  =   $Params{-onchange}  || "";
  my $OnBlur    =   $Params{-onblur}    || "";
  my $Required  =   $Params{-required}  || 0;
  my $Name      =   $Params{-name}      || "authors";
  my $Size      =   $Params{-size}      || 10;
  my $Disabled  =   $Params{-disabled}  || "";
  my @Defaults  = @{$Params{-default}};

  unless (keys %Author) {
    GetAuthors();
  }
    
  my @AuthorIDs = sort byLastName keys %Authors;
  my %AuthorLabels = ();
  my @ActiveIDs = ();
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE} || $All) {
      $AuthorLabels{$ID} = $Authors{$ID}{Formal};
      push @ActiveIDs,$ID; 
    } 
  }  
  if ($HelpLink) {
    my $ElementTitle = FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                                        -extratext => $ExtraText, );
#                                        -required => $Required, -extratext => $ExtraText, );
    print $ElementTitle,"\n";                                     
  }
  if ($Disabled) { # FIXME: Use Booleans
    print $query -> scrolling_list(-name => $Name, -values => \@ActiveIDs, 
                                   -labels => \%AuthorLabels,
                                   -size => 10, -multiple => $Multiple,
                                   -default => \@Defaults, -disabled);
  } else {
    print $query -> scrolling_list(-name => $Name, -id => $Name, 
                                   -values => \@ActiveIDs, 
                                   -onClick => $OnChange,
                                   -onBlur => $OnBlur,
                                   -labels => \%AuthorLabels,
                                   -size => 10, -multiple => $Multiple,
                                   -default => \@Defaults);
  }                                   
}

# Phil Ehrens fixed this. April 28, 2011.
sub AuthorJSList (%) {
  require "AuthorSQL.pm";
  require "Sorts.pm";
  require "Cookies.pm";
  GetPrefsCookie();
  my $mode = $_[0];
  my $All = 0; 

# here is the logic for deciding if it is All authors or only active authors.
# mode = 1 means it is a "search" author list, and 
#     SearchForm and DocumentDatabase (front page)
# mode = 2 means it is a "metadata" author list
#     DocumentAddForm  and SelectPrefs

  if($mode eq 1 && $UserPreferences{AuthorMode}  eq 'all'){ $All = 1;}
  if($mode eq 2 && $UserPreferences{AuthorMode2}  eq 'all'){ $All = 1;}
  unless (keys %Author) {
    GetAuthors();
  }
  my $script  = "\n<script>\n   var AuthorFormal = [";
  my @AuthorIDs = sort byLastName keys %Authors;
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE} || $All) {
      $script .= "\"$Authors{$ID}{Formal}\", ";
    }
  }
  # strip trailing boogers
  $script = substr($script, 0, -2);
  $script .= "];\n   var AuthorID = [";
  foreach my $ID (@AuthorIDs) {
    if ($Authors{$ID}{ACTIVE} || $All) {
       $script .= "$ID, ";
    }
  }
  # strip trailing boogers
  $script = substr($script, 0, -2);
  $script .= "];\n</script>\n";
  print $script;
}

sub AuthorGroupScroll (%) {
  require "AuthorSQL.pm";
  require "Sorts.pm";
  
  my (%Params) = @_;
  
  my $Multiple  =   $Params{-multiple}  || 0;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Author Groups";
  my $ExtraText =   $Params{-extratext} || "";
  my $Required  =   $Params{-required}  || 0;
  my $Name      =   $Params{-name}      || "authorgroups";
  my $Size      =   $Params{-size}      || 10;
  my @Defaults  = @{$Params{-default}};

  unless (keys %AuthorGroups) {
    GetAuthorGroupList();
  }
    
  my @AuthorGroupIDs = keys %AuthorGroups;
  my %AuthorGroupLabels = ();

  foreach my $ID (@AuthorGroupIDs) {
      $AuthorGroupLabels{$ID} = $AuthorGroups{$ID}{Description};
      push @ActiveGroupIDs,$ID; 
  }  
  if ($HelpLink) {
    my $ElementTitle = FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText,
                                        -extratext => $ExtraText, );
#                                        -required => $Required, -extratext => $ExtraText, );
    print $ElementTitle,"\n";                                     
  }

    print $query -> scrolling_list(-name => $Name, -values => \@AuthorGroupIDs, 
                                   -labels => \%AuthorGroupLabels,
                                   -size => 10, -multiple => $Multiple,
                                   -default => \@Defaults);
}

sub AuthorTextEntry ($;@) {
  my ($ArgRef) = @_;

#  my $Disabled = exists $ArgRef->{-disabled} ?   $ArgRef->{-disabled} : "0";
  my $HelpLink  = exists $ArgRef->{-helplink}  ?   $ArgRef->{-helplink}  : "authormanual";
  my $HelpText  = exists $ArgRef->{-helptext}  ?   $ArgRef->{-helptext}  : "Individuals";           
  my $Name      = exists $ArgRef->{-name}      ?   $ArgRef->{-name}      : "authormanual";
  my $Required  = exists $ArgRef->{-required}  ?   $ArgRef->{-required}  : $FALSE;
  my $ExtraText = exists $ArgRef->{-extratext} ?   $ArgRef->{-extratext} : "";
  my @Defaults  = exists $ArgRef->{-default}   ? @{$ArgRef->{-default}}  : ();

  my $AuthorManDefault = "";

  foreach $AuthorID (@Defaults) {
    FetchAuthor($AuthorID);
    $AuthorManDefault .= "$Authors{$AuthorID}{Formal}\n" ;
  }  
  
  print FormElementTitle(-helplink => $HelpLink, -helptext  => $HelpText, 
                         -extratext => $ExtraText, );

# RDW added id attribute so that JS can find it
  print $query -> textarea (-name    => $Name, -id => $Name, 
                            -default => $AuthorManDefault,
                            -columns => 35,    -rows    => 10);
};

sub InstitutionEntryBox (;%) {
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "instentry", -helptext => "Short Name");
  print $query -> textfield (-name => 'shortdesc', 
                             -size => 30, -maxlength => 40,$Booleans);
  print "</td></tr>\n";

  print "<tr><td>\n";
  print FormElementTitle(-helplink => "instentry", -helptext => "Long Name");
  print $query -> textfield (-name => 'longdesc', 
                             -size => 40, -maxlength => 80,$Booleans);
  print "</td>\n";
  print "</tr></table>\n";
}

1;
