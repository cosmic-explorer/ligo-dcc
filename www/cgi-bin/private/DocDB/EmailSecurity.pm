#        Name: $RCSfile: EmailSecurity.pm,v $
# Description: Security routines for individual user accounts. Used for notifications,
#              preferences, and sign-offs. Some of this should
#              probably be moved to other or new files.
#
#    Revision: $Revision: 1.10.2.7 $
#    Modified: $Author: vondo $ on $Date: 2007/09/20 19:53:14 $
#
#      Author: Eric Vaandering (ewv@fnal.gov)

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

sub ValidateEmailUser ($$) {
  my ($UserName,$Password) = @_;

  my $UserFetch =  $dbh->prepare("select EmailUserID,Password from EmailUser where Username=?");
     $UserFetch -> execute($UserName);
  my ($EmailUserID,$EncryptedPassword) = $UserFetch -> fetchrow_array;

  unless ($EmailUserID) {
    return 0;
  }

  my $TryPassword = crypt($Password,$EncryptedPassword);

  if ($TryPassword eq $EncryptedPassword) {
    return $EmailUserID;
  } else {
    return 0;
  }
}

sub ValidateEmailUserDigest ($$) {
  my ($UserName,$TryDigest) = @_;

  my $UserFetch =  $dbh->prepare("select EmailUserID,Password from EmailUser where Username=?");
     $UserFetch -> execute($UserName);
  my ($EmailUserID,$EncryptedPassword) = $UserFetch -> fetchrow_array;

  unless ($EmailUserID) {
    return 0;
  }

  my $RealDigest = &EmailUserDigest($EmailUserID);
  if ($RealDigest eq $TryDigest) {
    return $EmailUserID;
  } else {
    return 0;
  }
}

sub UserPrefForm ($) {
  my ($EmailUserID) = @_;

  my $Username     = $EmailUser{$EmailUserID}{Username};
  my $Name         = $EmailUser{$EmailUserID}{Name};
  my $EmailAddress = $EmailUser{$EmailUserID}{EmailAddress};
  my $PreferHTML   = $EmailUser{$EmailUserID}{PreferHTML};

  print "<table class=\"MedPaddedTable LeftHeader\">";
  if ($Digest) {
    print "<tr><th>\n";
    print $query -> hidden(-name => 'username', -default => $Username);
    print $query -> hidden(-name => 'digest', -default => $Digest);
    print "Username:</th>\n<td>$Username</td></tr>";
  } elsif ($UserValidation eq "certificate") {
    print "<tr><th>Username:</th>\n<td>$Username</td></tr>";
  } else {
    print "<tr><th>Username:</th>\n<td>";
    print $query -> textfield(-name => 'username', -default => $Username,
                            -size => 16, -maxlength => 32);
    print "</td></tr>";
    if ($UserValidation ne "kerberos") {
        print "<tr><th>Password:</th>\n<td>";
        print $query -> password_field(-name => 'password',
                            -size => 16, -maxlength => 32);
        print "</td></tr>";
    }
  }

  if  ($UserValidation eq "certificate") {
    print "<tr><th>Real name:</th>\n<td>$Name</td></tr>\n";
    print "<tr><th>E-mail address:</th>\n<td>";
    print $query -> textfield(-name => 'email',    -default => $EmailAddress,
                              -size => 24, -maxlength => 64);
    print "</td></tr>\n";
  } elsif ($UserValidation eq "kerberos") {
    print "<tr><th>Real name:</th>\n<td>$Name</td></tr>";
    print "<tr><th>Email address:</th>\n<td>$EmailAddress</td></tr>";
    print "</td></tr>\n";

  } else {
    print "<tr><th>Real name:</th>\n<td>";
    print $query -> textfield(-name => 'name',     -default => $Name,
                              -size => 24, -maxlength => 128);
    print "</td></tr>\n";
    print "<tr><th>E-mail address:</th>\n<td>";
    print $query -> textfield(-name => 'email',    -default => $EmailAddress,
                              -size => 24, -maxlength => 64);
    print "</td></tr>\n";
    print "<tr><th>New password:</th>\n<td>";
    print $query -> password_field(-name => 'newpass',    -default => "",
                          -size => 24, -maxlength => 64, -override =>1 );
    print "</td></tr>\n";
    print "<tr><th>Confirm password:</th>\n<td>";
    print $query -> password_field(-name => 'confnewpass',    -default => "",
                          -size => 24, -maxlength => 64, -override =>1 );
    print "</td></tr>\n";
  }

  print "<tr><th>Prefer HTML e-mail:</th>\n<td>";
  if ($PreferHTML) {
    print $query -> checkbox(-name => "html", -checked => 'checked', -value => 1, -label => '');
  } else {
    print $query -> checkbox(-name => "html", -value => 1, -label => '');
  }
  print "</td></tr>\n";
  if  ($UserValidation eq "certificate") {
    print "<tr><th>Member of Groups:</th>\n";
    print "<td><ul>\n";
    my @UserGroupIDs = &FetchUserGroupIDs($EmailUserID);
    foreach my $UserGroupID (@UserGroupIDs) {
      &FetchSecurityGroup($UserGroupID);
      print "<li>$SecurityGroups{$UserGroupID}{NAME}</li>\n";
    }
    print "</ul></td></tr>\n";
  }
  print "</table>\n";
}

sub EmailUserDigest ($) {
  use Digest::SHA1 qw(sha1_hex);
  my ($EmailUserID) = @_;
  &FetchEmailUser($EmailUserID);

  my ($day,$mon,$yr);
  my $Digest;
  (undef,undef,undef,$day,$mon,$yr) = localtime(time);
  if ($EmailUser{$EmailUserID}{Username}) {
    my $data = $EmailUser{$EmailUserID}{Password}.
               $EmailUser{$EmailUserID}{Username}.$day.$mon.$yr;
    $Digest = sha1_hex($data);
  } else {
    $Digest = 0;
  }

  return $Digest;
}

sub NewEmailUserForm {
  print "<b>Create a new account:</b><p>\n";
  print $query -> startform('POST',$SelectEmailPrefs);
  print $query -> hidden(-name => 'mode', -default => "newuser", -override => 1);

  print "<dl><dd><table>";
  print "<tr><td align=right><b>Username:</b></td>\n<td>";
  print $query -> textfield(-name => 'username',      -size => 16, -maxlength => 32);
  print "<tr><td align=right><b>Password:</b></td>\n<td>";
  print $query -> password_field(-name => 'password', -size => 16, -maxlength => 32);
  print "<tr><td align=right><b>Confirm password:</b></td>\n<td>";
  print $query -> password_field(-name => 'passconf', -size => 16, -maxlength => 32);
  print "<tr><td colspan=2 align=center>";
  print $query -> submit (-value => "Create new account");
  print "</table></dl>\n";
  print $query -> endform;
}

sub LoginEmailUserForm {
  print "<b>Change preferences on an existing account:</b><p>\n";
  print $query -> startform('POST',$SelectEmailPrefs);
  print $query -> hidden(-name => 'mode', -default => "login", -override => 1);

  print "<dl><dd><table>";
  print "<tr><td align=right><b>Username:</b></td>\n<td>";
  print $query -> textfield(-name => 'username',      -size => 16, -maxlength => 32);
  print "<tr><td align=right><b>Password:</b></td>\n<td>";
  print $query -> password_field(-name => 'password', -size => 16, -maxlength => 32);
  print "<tr><td colspan=2 align=center>";
  print $query -> submit (-value => "Login");
  print "</table></dl>\n";
  print $query -> endform;
}

sub CanSign($) {
  my ($EmailUserID) = @_;

  require "DocDBGlobals.pm";
  require "NotificationSQL.pm";

  FetchEmailUser($EmailUserID);
  if ($AllCanSign){
     require "AuthorSQL.pm";
      my $AuthorID = $EmailUser{$EmailUserID}{AuthorID}; 
      FetchAuthor($AuthorID);
      return $Authors{$AuthorID}{ACTIVE};
  }
  else {
      return $EmailUser{$EmailUserID}{CanSign};
  }
}

1;
