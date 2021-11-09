#     
#        Name: DocTypeHTML.pm
# Description: Routines with form elements and other HTML generating 
#              code pertaining to DocumentTypes.
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

sub DocTypeSelect (;%) { # Scrolling selectable list for doc type search
  my ($ArgRef) = @_;
  my $Disabled = exists $ArgRef->{-disabled} ?   $ArgRef->{-disabled} : 0;
  my $Multiple = exists $ArgRef->{-multiple} ?   $ArgRef->{-multiple} : 0;
  my $Format   = exists $ArgRef->{-format}   ?   $ArgRef->{-format}   : "full";
#  my $HelpLink = exists $ArgRef->{-helplink} ?   $ArgRef->{-helplink} : "";
#  my $HelpText = exists $ArgRef->{-helptext} ?   $ArgRef->{-helptext} : "  my (%Params) = @_;
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  my @DocTypeLabels = ();
  @types = sort { $DocumentTypes{$a}{SHORT} cmp $DocumentTypes{$b}{SHORT} } keys %DocumentTypes;

  foreach my $DocTypeID (@types) {
    if ($Format eq "short") {
      my $short_label = $DocumentTypes{$DocTypeID}{SHORT};
      push (@DocTypeLabels, $short_label);
    } elsif ($Format eq "full") {
      my $long_label = $DocumentTypes{$DocTypeID}{SHORT}." [".$DocumentTypes{$DocTypeID}{LONG}."]";
      push (@DocTypeLabels, $long_label);
    }
  }
   
  print FormElementTitle(-helplink => "doctype", -helptext => "Document type");   
  print $query -> scrolling_list(-size => 11, -name => "doctype", -multiple => $Multiple, 
                              -values => \@DocTypeLabels, $Booleans);
};


sub DocTypeEntryBox (;%) {
  my (%Params) = @_;
  
  my $Disabled = $Params{-disabled}  || "0";
  
  my $Booleans = "";
  
  if ($Disabled) {
    $Booleans .= "-disabled";
  }  
  
  print "<table cellpadding=5><tr valign=top>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "doctypeentry", -helptext => "Short Description");
  print $query -> textfield (-name => 'name', 
                             -size => 20, -maxlength => 32, $Booleans);
  print "</td>\n";
  print "</tr><tr>\n";
  print "<td>\n";
  print FormElementTitle(-helplink => "doctypeentry", -helptext => "Long Description");
  print $query -> textfield (-name => 'longdesc', 
                             -size => 40, -maxlength => 255, $Booleans);
  print "</td></tr>\n";

  print "</table>\n";

}

sub DocTypeScroll ($){
  my ($ArgRef) = @_;

  my $MinLevel   = exists $ArgRef->{-minlevel}   ?   $ArgRef->{-minlevel}   : 1;
  my $Multiple   = exists $ArgRef->{-multiple}   ?   $ArgRef->{-multiple}   : 0;
  my $HelpLink   = exists $ArgRef->{-helplink}   ?   $ArgRef->{-helplink}   : "doctype";
  my $HelpText   = exists $ArgRef->{-helptext}   ?   $ArgRef->{-helptext}   : "Document type";
  my $ExtraText  = exists $ArgRef->{-extratext}  ?   $ArgRef->{-extratext}  : "";
  my $Required   = exists $ArgRef->{-required}   ?   $ArgRef->{-required}   : 0;
  my $Name       = exists $ArgRef->{-name}       ?   $ArgRef->{-name}       : "doctype";
  my $Size       = exists $ArgRef->{-size}       ?   $ArgRef->{-size}       : 13;
  my $Disabled   = exists $ArgRef->{-disabled}   ?   $ArgRef->{-disabled}   : "0";
  my @Defaults  = @{$ArgRef->{-default}};
 
  

  require "MiscSQL.pm";
  require "FormElements.pm";

  GetDocTypes();

  my @DocTypeValues = ();
  my %DocTypeLabels = ();

  foreach  $value ( sort {lc $DocumentTypes{$a}{SHORT}  cmp lc $DocumentTypes{$b}{SHORT} } keys %DocumentTypes) {
       push (@DocTypeValues, $value);
       $DocTypeLabels{$value} =  $DocumentTypes{$value}{SHORT};
  }


  print FormElementTitle(-helplink => $HelpLink, -helptext => $HelpText);

  print $query -> scrolling_list(-name     => $Name, -values => \@DocTypeValues,
                                 -size     => $Size, 
                                 -labels   => \%DocTypeLabels,
                                 -multiple => $Multiple,
                                 -default  => \@Defaults);
}

sub DocTypeLink ($;%) {
  my ($TypeID,$TypeMode) = @_;

  require "MiscSQL.pm";

  &FetchDocType($TypeID);
  my $link = "";
  unless ($Public) {
    $link .= "<a href=\"$ListBy?typeid=$TypeID\">";
  }
  if ($TypeMode eq "short") {
    $link .= $DocumentTypes{$TypeID}{SHORT};
  } else {
    $link .= $DocumentTypes{$TypeID}{LONG};
  }
  unless ($Public) {
    $link .= "</a>";
  }

  return $link;
}

1;
