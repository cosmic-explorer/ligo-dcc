#
#        Name: SecurityHTML.pm
# Description: Routines which supply HTML and form elements related to security
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

sub SecurityScroll (%) {
  require "SecuritySQL.pm";
  require "Sorts.pm";
  require "Scripts.pm";
  require "FormElements.pm";
  
  my (%Params) = @_;
  
  my $AddPublic =   $Params{-addpublic} || $FALSE;
  my $AddObsolete = $Params{-addobsolete} || $FALSE;
  my $HelpLink  =   $Params{-helplink}  || "";
  my $HelpText  =   $Params{-helptext}  || "Groups";
  my $Multiple  =   $Params{-multiple}; 
  my $Name      =   $Params{-name}      || "groups";
  my $Format    =   $Params{-format}    || "short";
  my $Size      =   $Params{-size}      || 16;
  my $Disabled  =   $Params{-disabled}  || $FALSE;
  my $Hierarchy =   $Params{-hierarchy} || $FALSE;
  my $ExtraText =   $Params{-extratext} || "";
  my @GroupIDs  = @{$Params{-groupids}};
  my @Default   = @{$Params{-default}};
  my $AddPublic =   $Params{-addpublic} || $FALSE;

  my %Options = ();
 
  if ($Disabled) {
    $Options{-disabled} = "disabled";
  }  

  &GetSecurityGroups;
  
  unless (@GroupIDs) {
    @GroupIDs = keys %SecurityGroups;
  }
    
  my %GroupLabels  = ();

  my @DisplayGroupIDs = ();
  foreach my $GroupID (@GroupIDs) {
    if ($Hierarchy ) {
        if ($SecurityGroups{$GroupID}{DisplayInList} == 1) {
            $GroupLabels{$GroupID} =  $SecurityGroups{$GroupID}{NAME};
            if ($Format eq "full") {
                $GroupLabels{$GroupID} .= " [".$SecurityGroups{$GroupID}{Description}."]";
            }
            push @DisplayGroupIDs, $GroupID;
         }
     }
     else {
        if ( ($SecurityGroups{$GroupID}{DisplayInList} == 2 )) {
           $GroupLabels{$GroupID} =  $SecurityGroups{$GroupID}{NAME};
            if ($Format eq "full") {
                $GroupLabels{$GroupID} .= " [".$SecurityGroups{$GroupID}{Description}."]";
            }
            push @DisplayGroupIDs, $GroupID;
         }
         else {
            if ($UserValidation eq "kerberos") {
                my $UserID = (&FetchEmailUserIDFromRemoteUser());
                my @UsersGroupIDs = ();
                @UsersGroupIDs = (&FetchUserGroupIDs($UserID));
                foreach my $UsersGroup (@UsersGroupIDs) {
                     if ($UsersGroup == $GroupID) {
                         $GroupLabels{$GroupID} = $SecurityGroups{$GroupID}{NAME};
                         if ($Format eq "full") {
                             $GroupLabels{$GroupID} .= " [".$SecurityGroups{$GroupID}{Description}."]";
                         }
                         push @DisplayGroupIDs, $GroupID;
                     }
                 }
             }
         }
     }
  }  
  
  if ($HelpLink) {  
    my $BoxTitle = &FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText, -extratext => $ExtraText);
    print $BoxTitle;
  }
  if ($Hierarchy && $AddPublic) { # Add dummy security code for "Public"
    my $ID = FetchSecurityGroupByName($Public_Group); 
    push @DisplayGroupIDs,$ID; 
    $GroupLabels{$ID} = $Public_Group;
  }
      
  if ($AddObsolete) { 
    my $ObsoleteID = FetchSecurityGroupByName($Obsolete_Group); 
    push @DisplayGroupIDs,$ObsoleteID; 
    $GroupLabels{$ObsoleteID} = "$Obsolete_Group";
  }

  if ($Hierarchy) {
    @DisplayGroupIDs = sort numerically @DisplayGroupIDs;
    if ($AddPublic){
      print $query -> scrolling_list(
            -name     => $Name,
            -values   => \@DisplayGroupIDs, 
            -labels   => \%GroupLabels, 
            -size     => $Size,
            -multiple => $Multiple,
            -onChange => "Javascript:security_list_deselector(this);",
            -default  => \@Default, %Options);
    } else {
      print $query -> scrolling_list(
            -name     => $Name,
            -values   => \@DisplayGroupIDs, 
            -labels   => \%GroupLabels, 
            -size     => $Size,
            -multiple => $Multiple,
            -default  => \@Default, %Options);
    }
  } else {
    my @SortedGroupIDsByLabel = ();
    
    # Too hard for me to parse, sorry.
    foreach $value (sort {lc $GroupLabels{$a} cmp lc $GroupLabels{$b}} keys %GroupLabels) {
      push (@SortedGroupIDsByLabel, $value );   
    }

    print $query -> scrolling_list(
          -name     => $Name,
          -values   => \@SortedGroupIDsByLabel, 
          -labels   => \%GroupLabels, 
          -size     => $Size,
          -multiple => $Multiple,
          -onChange => "Javascript:security_list_deselector(this);",
          -default  => \@Default, %Options);
    }
    $AddPublic = FALSE;
};


sub SecurityListByID {
  my (@GroupIDs) = @_;
  
  print "<div id=\"Viewable\">\n";
  if ($EnhancedSecurity) {
    print "<b>Viewable by:</b><br/>\n";
  } else {  
    print "<b>Accessible by:</b><br/>\n";
  }  
  
  print "<ul>\n";
  if (@GroupIDs) {
    foreach $GroupID (@GroupIDs) {
      print "<li>",SecurityLink({ -groupid => $GroupID, -check => "view", }),"</li>\n";
    }
  } else {
    print "<li>Public document</li>\n";
  }
  print "</ul>\n";
  print "</div>\n";
}

sub ModifyListByID {
  my (@GroupIDs) = @_;
  
  unless ($EnhancedSecurity) {
    return;
  }
    
  print "<div id=\"Modifiable\">\n";
  print "<b>Modifiable by:</b><br/>\n";
  print "<ul>\n";
  if (@GroupIDs) {
    foreach $GroupID (@GroupIDs) {
      if ($Public) {
          my $group_name = $SecurityGroups{$GroupID}{NAME};
          print  "<li>$group_name</li>\n";
      }
      else {
          print "<li>",SecurityLink( {-groupid => $GroupID, -check => "create", } ),"</li>\n";
      }
    }
  } else {
    print "<li>Same as Viewable by</li>\n";
  }
  print "</ul>\n";
  print "</div>\n";
}

sub PersonalAccountLink () {
  #my $PersonalAccountLink = "<a href=\"$EmailLogin\">Your Account</a>";
  my $PersonalAccountLink = "<a href=\"$EmailLogin\">My Account</a>";
  if ($UserValidation eq "certificate") {
    require "CertificateUtilities.pm";
    my $CertificateStatus = &CertificateStatus();
    if ($CertificateStatus eq "verified") {
      #$PersonalAccountLink = "<a href=\"$SelectEmailPrefs\">Your Account</a>";
      $PersonalAccountLink = "<a href=\"$SelectEmailPrefs\">My Account</a>";
    } else {
      $PersonalAccountLink = "";
    }
  }
  if ($Public) {
    $PersonalAccountLink = "";
  }
  return $PersonalAccountLink;
}

sub SecurityLink ($) {
  my ($ArgRef) = @_;
  my $GroupID = exists $ArgRef->{-groupid} ? $ArgRef->{-groupid} : 0;
  my $Check   = exists $ArgRef->{-check}   ? $ArgRef->{-check}   : "";

  require "Security.pm";
  
  my %Message = ("view" => "Can't view now", "create" => "Can't modify now");

  unless ($GroupID) {
    return;
  }
  
  my $Link = "<a href=\"$ListBy?groupid=$GroupID\"";
  $Link .= " title=\"$SecurityGroups{$GroupID}{Description}\"";
  $Link .= ">";
  $Link .= $SecurityGroups{$GroupID}{NAME};
  $Link .= "</a>";
  if ($Check && !GroupCan({ -groupid => $GroupID, -action => $Check }) ) {
    $Link .= "<br/>(".$Message{$Check}.")";
  }  
     
  return $Link;
}

1;
