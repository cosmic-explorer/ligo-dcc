#
# Description: Routines to deal with cookies
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

sub GetPrefsCookie {

  # FIXME: Move to using UserPreferences directly as possible.

  $PrefAuthorID     = $query -> cookie('userid');
  $UploadTypePref   = $query -> cookie('archive');
  $NumFilesPref     = $query -> cookie('numfile');
  $UploadMethodPref = $query -> cookie('upload');
  $TopicModePref    = $query -> cookie('topicmode');
  $AuthorModePref   = $query -> cookie('authormode') || 'all';
  $AuthorModePref2  = $query -> cookie('authormode2') || 'all';
  $DateOverridePref = $query -> cookie('overdate');
  $ReadGroupPref    = $query -> cookie('security');
  $WriteGroupPref   = $query -> cookie('modify');

  $UserPreferences{AuthorID}     = $PrefAuthorID    ;
  $UserPreferences{UploadType}   = $UploadTypePref  ;
  $UserPreferences{NumFiles}     = $NumFilesPref    ;
  $UserPreferences{UploadMethod} = $UploadMethodPref;
  $UserPreferences{TopicMode}    = $TopicModePref   ;
  $UserPreferences{AuthorMode}   = $AuthorModePref  ;
  $UserPreferences{AuthorMode2}  = $AuthorModePref2 ;
  $UserPreferences{DateOverride} = $DateOverridePref;
  $UserPreferences{ReadGroup}    = $ReadGroupPref   ;
  $UserPreferences{WriteGroup}   = $WriteGroupPref  ;
}

sub GetGroupsCookie {
  my @GroupIDs = ();
  if ($query) {
    my $GroupIDs = $query -> cookie('groupids');
    if ($GroupIDs) {
      push @DebugStack,"Found group limiting cookie";
      @GroupIDs = split /,/,$GroupIDs;
    }
  }
  return @GroupIDs;
}

sub GetReadGroupACLsCookie {
  my @myGroupIDs = ();
  if ($query) {
    my $myGroupPref = $query -> cookie('security');
    if ($myGroupPref) {
      push @DebugStack,"Found group limiting cookie";
      @myGroupIDs = split (';', $ReadGroupPref);
    }
  }

  return @myGroupIDs;
}

sub GetWriteGroupACLsCookie {
  my @myGroupIDs = ();
  if ($query) {
    my $myGroupPref = $query -> cookie('modify');
    if ($myGroupPref) {
      push @DebugStack,"Found group limiting cookie";
      @myGroupIDs = split (';', $WriteGroupPref);
    }
  }

  return @myGroupIDs;
}

1;

