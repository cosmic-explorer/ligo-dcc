#! /usr/bin/env perl
#        Name: $RCSfile: SignoffHTML.pm,v $
# Description: Generates HTML for things related to signoffs
#
#    Revision: $Revision: 1.10.4.6 $
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

require "NotificationSQL.pm";
require "EmailSecurity.pm";
use POSIX;

$myDEBUG = 0;

sub SignoffBox { 
   my (%Params) = @_;

   if ($myDEBUG) { open (DEBUG, ">>/tmp/debug.mca"); }

   my $isParallel = $Params{-parallelsignoff};
   my $Default  = $Params{-default}  || "";
   my $DocRevisionID = $Params{-docrevid} || 0;
   my $ClearInactive = $Params{-clearinactive} || 0;;
   my $SignoffText = $Default;

   my $InactiveUsers = InactiveUsersInSignoff($DocRevisionID);
   my @ActiveSigners = GetActiveEmailUserIDsByDocRevID ($DocRevisionID);

   if ($myDEBUG) {print  DEBUG "SignoffBox: $DocRevisionID  InactiveUsers: $InactiveUsers\n";}
   if ($myDEBUG) {print  DEBUG "SignoffBox: $DocRevisionID  Default : $Default\n";}
   
   if ($InactiveUsers) {
       print "\n<script>\n"; print " 
       function getClearInactive() {
           return document.getElementById('clearinactive').value;
       }


       //if (confirm('At least one of accounts in the signoff list is inactive.  Press OK to remove the inactive account from the list or Cancel to leave it in.') ){ 
      //     document.getElementById('clearinactive').value = 1;
      //     console.log(document.getElementById('clearinactive').value);
      // } 
      // else {
      //     document.getElementById('clearinactive').value = 0;
      // }

      </script>\n";

   }
  

   #        \$('clearinactive').value(1);\n
   #        \$('clearinactive').value = 1;\n
   #        getElementById(\'clearinactive\').value = 1;
   #        console.log(getElementById(\'clearinactive\').value);
   #  my $ChooserLink  = "- <a href=\"Javascript:signoffchooserwindow(\'$SignoffChooser\');\">".
   #        "<b>Signoff Chooser</b></a>";
   #if ($ClearInactive) {
   #    print "\n<script>\n";
   #    print "var GOTHERE\n";
   #    print "</script>\n";
   #}


   my $ElementTitle = &FormElementTitle(-helplink  => "signoffs",
                                       -helptext  => "Signoffs",
                                       -extratext => $ChooserLink);
   print "\n<script>\n  ";
   print "\n   var Signers = [";


   my @EmailUserIDs = sort EmailUserIDsByName GetEmailUserIDs();
   my $EmailUserID;
   my @Signers = ();
   
   foreach $EmailUserID (@EmailUserIDs) {
      FetchEmailUser($EmailUserID);
      unless (CanSign($EmailUserID)) {next;}
      if ($DocRevisionID) {
          if (CanAccessRevision($DocRevisionID, $EmailUserID)) {
              if ($myDEBUG) {print  DEBUG "SignoffBox: $DocRevisionID $EmailUserID\n";}
               my $Name = $EmailUser{$EmailUserID}{Name};
               push @Signers,$Name;
               print '"'.$Name.'", ';
           }
      }
      else {
          my $Name = $EmailUser{$EmailUserID}{Name};
          push @Signers,$Name;
          print '"'.$Name.'", ';
      }
   }
   
   print "];\n</script>\n";

   print "<td><table><tr><td> <a name=\"SignoffBox_Anchor\" id=\"SignoffBox_Anchor\">".$ElementTitle."</a></td><td>\n";

   print FormElementTitle(-helplink => 'signoffs', -helptext  => 'Select authors here ...');

   print $query -> scrolling_list(-name => "signoffscroll", -id => "signoffscroll",
                                   -values => \@Signers,
                                   -onClick => "packValues(event, 'signoffscroll','signofflist');",
                                   -onBlur => "unfocus();",
                                   -size => 10, -multiple => $Multiple);

   print "</td><td>\n";


   print FormElementTitle(-helplink => 'signoffs', -helptext  => '...or type here', -extratext => "(last signer approves document)");
   print "         <div id=\"signoffdiv\">\n";
   print $query -> textarea (-name    => "signofflist", -id => "signofflist",
                            -default => $Default,
                            -columns => 30,    -rows    => 10);
   print "</div>\n</td>";
   print "<td>";
#   print '<a class="Help" href="Javascript:helppopupwindow(\'https://dcc-dev.ligo.org/cgi-bin/private/DocDB/DocDBHelp?term=signoffs\');">';
   my $isParallelChecked="";
   if ($isParallel) {
      $isParallelChecked='checked="checked"';
   }
   print "<input type=\"checkbox\" $isParallelChecked name=\"parallelsignoff\" value=\"1\">\n";
   print "<label for=\"parallelsignoff\">".
                FormElementTitle(-helplink => 'signoffs', -helptext  => 'Parallel?', -extratext => "", -nocolon=>1, -nobreak=>1) .
         "</label>\n";
   # if ($isParallel) {
   #     print $query -> checkbox(-name    => "parallelsignoff", 
   #                              -checked => 'checked',
   #                              -value   => 1,
   #                              -label   => 'Parallel?');
         #FormElementTitle(-helplink => 'signoffs', -helptext  => 'Parallel?', -extratext => "") );
   #} else {
   #      print $query -> checkbox(-name   => "parallelsignoff", 
   #                               -value  => 1,
   #                               -label   => 'Parallel?' );
         #&FormElementTitle(-helplink => 'signoffs', -helptext  => 'Parallel?', -extratext => ""));
   #}
   print "</td>\n";

   print "</tr></table></td>\n";
};

sub PrintRevisionSignoffInfo ($) { # FIXME: Handle more complicated topologies?
  require "SignoffSQL.pm";
  require "Security.pm";

  my ($DocRevID) = @_;
  my $DocumentID = $DocRevisions{$DocRevID}{DOCID};
  my $Version    = $DocRevisions{$DocRevID}{Version};

  # Don't display anything unless the user is logged into a group that can
  # modify the DB. Maybe we want to display but not provide signature boxes?

  unless (&CanAccess($DocumentID,$Version)) {
    return;
  }

  my @RootSignoffIDs = &GetRootSignoffs($DocRevID);
  if (@RootSignoffIDs) {
    print "<div id=\"Signoffs\">\n";
    print "<dl>\n";
    print "<dt class=\"InfoHeader\"><span class=\"InfoHeader\">Signoffs:"; 

    require "SignoffSQL.pm";

    GetAllEmails($DocRevID);
    if (scalar(@AllAddresses) > 1) {
      require "DocumentSQL.pm"; # get alias
      my $DocAlias = FetchDocumentAlias($DocumentID);

      my ($LinkStart,$MailTo,$LinkEnd,$EmailToAll);
      $LinkStart = " <a href\=\"mailto:";
      $MailTo = join ',', map qq($_), @AllAddresses;
      $LinkEnd = "\?Subject\=DCC document LIGO-$DocAlias\"><img src\=\"".$ImgURLPath."/mail-all.png\" title\=\"Contact all signers\" alt\=\"Email all signers\"></a>";
      $EmailToAll = $LinkStart.$MailTo.$LinkEnd;
      print "$EmailToAll\n";
    }

    print "</span></dt>\n";
    my $ParallelSignoff    = $DocRevisions{$DocRevID}{ParallelSignoff};

    # https://stackoverflow.com/questions/2717480/css-selector-for-first-element-with-class
    my $waitforsignature_sibling_style = $ParallelSignoff ? '' :
    qq(
       #Signoffs .WaitforSignature ~ .WaitforSignature {
          font-weight: normal;
       }
    );

    print qq(
    <style>
       #Signoffs .WaitforSignature {
          color: red;
          font-weight: bold;
       }
       $waitforsignature_siblings_style
    </style>
    );
    
    print "<ul>\n";
    foreach my $RootSignoffID (@RootSignoffIDs) {
      &PrintSignoffInfo($RootSignoffID);
    }
    print "</ul>\n";

    print "</dl>\n";
    
    print "</div>\n";
  }
}

sub PrintSignoffInfo ($) {
  require "SignoffSQL.pm";

  my ($SignoffID) = @_;

  if ($Public) { return; }

  my @SubSignoffIDs = &GetSubSignoffs($SignoffID);
  print "<li>";
  &PrintSignatureInfo($SignoffID);
  if (@SubSignoffIDs) {
    print "<ul>\n";
    foreach my $SubSignoffID (@SubSignoffIDs) {
      &PrintSignoffInfo($SubSignoffID);
    }
    print "</ul>\n";
  }
  print "</li>\n";
  return;
}

sub PrintSignatureInfo ($) {
  require "SignoffSQL.pm";
  require "SignoffUtilities.pm";
  require "NotificationSQL.pm";

  my ($SignoffID) = @_;

  if ($Public) { return; }

  my $ServerTimeZone = strftime "%Z", localtime() ;
  my @SignatureIDs = &GetSignatures($SignoffID);

  my @SignatureSnippets = ();

  if ($myDEBUG) { open (DEBUG, ">>/tmp/debug.mca"); }

  my $LastSignerID = GetLastSignerByDocRevID ($DocRevID);

  # FIXME: put the style in a proper css file
  my $RedGavel = qq (
     <style> 
        .hideRedGavelText {
            display: none;
            z-index: 999;
        }
  
        #gavel:hover + .hideRedGavelText {
            display: block;
            color: #333;
            font-size: 70%;
            margin-top: 1.5em;
            margin-left: 12%;
            padding: 0.5em;
        }
     </style>
     <img id="gavel" src="/Static/img/gavel-24.ico" alt="Red gavel" width="16" height="16" />
     <div class="hideRedGavelText">When the final approver (last in signoff list) approves or disapproves, the signature process ends. 
        If the final approver clears their approval or disapproval, the signature process resumes.</div>
  );
 
  my $pendingSignatures= &NumberOfPendingSignatures($DocRevID);

  foreach my $SignatureID (@SignatureIDs) {
    my $SignatureIDOK = &FetchSignature($SignatureID);
    if ($SignatureIDOK) {
      my $EmailUserID = $Signatures{$SignatureID}{EmailUserID};
      &FetchEmailUser($EmailUserID);

      my $SignoffID = $Signatures{$SignatureID}{SignoffID};
      my $Status = &SignoffStatus($SignoffID);

      # If the Signoff is ready for a signature, put a password field
      # If signed, allow rescinding the signature
      # Otherwise, note that it's waiting

      my $SignatureText = "";
      my $SignatureLink = &SignatureLink($EmailUserID);

      if ($myDEBUG) {print  DEBUG "Status: $Status for $EmailUserID\n";}

      if ($Status eq "Ready" || $Status eq "Signed" || $Status eq "Approved" || $Status eq "Disapproved"){
        # FIXME: move that javascript function outside of the loop or in Signature.js 
        print "\n<script>\n
        function setSignAction(i) {\n

            if (i==0) \$('sign_action').value = \"unsign\";\n
            if (i==1) \$('sign_action').value = \"approve\";\n
            if (i==2) \$('sign_action').value = \"abstain\";\n
            if (i==3) \$('sign_action').value = \"disapprove\";\n
//            alert (document.getElementById(\"sign_action\").value);
            
            document.sign_form.submit()
            }

        function getValue() {\n
            alert(document.sign_form.elements[1].value);\n
            document.sign_form.submit()
        }
        
        function setApproverSignAction(i) {\n
            
            if (confirm('Once the final approval is given, those who have not signed will not be able to sign. Do you want to proceed?')) {
                setSignAction(i)
            }
        }
  </script>\n";


        if ($UserValidation eq "kerberos") {

          if (FetchEmailUserIDFromRemoteUser() == $EmailUserID) {


            if ($EmailUserID == $LastSignerID) {
               if ($Status eq "Ready") {
                  $Action = "approve";
               } else {
                  $Action = "unsign";
               }

               $SignatureText .= $query -> start_form(-name   => "sign_form", 
                                                      -method => 'POST',
                                                      -action => "$SignRevision",
                                                      -enctype=> "multipart/form-data");
               $SignatureText .= "<div>\n";
               $SignatureText .= "<div>\n";
               $SignatureText .= "<tr><td class=\"LeftHeader\">\n";
               $SignatureText .= "$SignatureLink ";
               $SignatureText .= $query -> hidden(-name => 'docid',   -default => $DocumentID);
               $SignatureText .= $query -> hidden(-name => 'version',   -default => $Version);
               $SignatureText .= $query -> hidden(-name => 'signatureid',   -default => $SignatureID);
               $SignatureText .= $query -> hidden(-name => 'emailuserid',   -default => $EmailUserID);
               $SignatureText .= $query -> hidden(-name => 'sign_action',   -id => 'sign_action', -default => $Action);
               if ($myDEBUG) {print  DEBUG "Before Action: $Action\n";}
               if ( ($Action eq "approve") && ($ReadOnly == 0)) {
                   # FIXME: actually compute whether the approver is the last to sign
                   my $actuallyFinalSigner = ($pendingSignatures == 1);
                   my $SignActionFunction = $actuallyFinalSigner ? "setSignAction" : "setApproverSignAction";
                   $SignatureText .= "<input class=\"approver\" type=\"button\" value=\"$FinalApproverButtons{approve}\"  onClick=\"${SignActionFunction}(1)\">\n";
                   $SignatureText .= "<input type=\"button\" value=\"$FinalApproverButtons{disapprove}\" onClick=\"${SignActionFunction}(3)\">\n";
                   $SignatureText .= $RedGavel;
               } else {
                 
                  if ($ReadOnly == 0){
                      $SignatureText .= "<input type=\"button\" value=\"$FinalApproverButtons{unsign}\"  onClick=\"setSignAction(0)\">\n";
                      #$SignatureText .= $RedGavel;
                  }
               }
               my $signature_text = GetSignatureText($SignatureID);
               $Action = $Signatures{$SignatureID}{Signed};
               my $SignoffAction = $SignoffActions{$Action};
               if ($myDEBUG) {print  DEBUG "After Action: $Action\n";}

               if ($Action ne "unsign") {
                   if ($myDEBUG) {print  DEBUG "Signature Text: $signature_text\n";}
                   $SignatureText .= "<td> $signature_text </td>";
               }
               $SignatureText .= "</div>\n";
               $SignatureText .= $query -> end_multipart_form;
            }  #RemoteUser is last Signer
            else {
               $SignatureText .= $query -> start_form(-name   => "sign_form", 
                                                      -method => 'POST',
                                                      -action => "$SignRevision",
                                                      -enctype=> "multipart/form-data");
               $SignatureText .= "<div>\n";
               $SignatureText .= "<div>\n";
               $SignatureText .= "<tr><td class=\"LeftHeader\">\n";
               $SignatureText .= "$SignatureLink ";
               $SignatureText .= $query -> hidden(-name => 'docid',   -default => $DocumentID);
               $SignatureText .= $query -> hidden(-name => 'version',   -default => $Version);
               $SignatureText .= $query -> hidden(-name => 'signatureid',   -default => $SignatureID);
               $SignatureText .= $query -> hidden(-name => 'emailuserid',   -default => $EmailUserID);
               $SignatureText .= $query -> hidden(-name => 'sign_action',   -id => 'sign_action', -default => $Action);

               my ($revision_status, $Locked, $LastDocRevID) = RevisionStatus($DocRevID); 
               my $LastSignatureValue = GetLastSignatureValueBySignoffID($LastSignerID); 

               if ($myDEBUG) {print  DEBUG "PrintSigInfo RevisionStatus($revision_status) LastSignatureValue($LastSignatureValue)\n";}
               if ($myDEBUG) {print  DEBUG "PrintSigInfo Locked($Locked) \n";}
                
               
               if (($revision_status ne $Approved_RevisionStatus) ||
                   ($revision_status ne $Unapproved_RevisionStatus) ||
                   ($LastSignatureValue == 0)) {
                  
                  if ( ($Locked == 0) && ($ReadOnly ==0) ){
                     if (($Action eq "unsign") || ($Status eq "Ready")){
                        $SignatureText .= "<input type=\"button\" value=\"$SignoffButtons{approve}\"    onClick=\"setSignAction(1)\">\n";
                        $SignatureText .= "<input type=\"button\" value=\"$SignoffButtons{disapprove}\" onClick=\"setSignAction(3)\">\n";
                        $SignatureText .= "<input type=\"button\" value=\"$SignoffButtons{abstain}\"    onClick=\"setSignAction(2)\">\n";
                     }
                     else {
                        $SignatureText .= "<input type=\"button\" value=\"$SignoffButtons{unsign}\"     onClick=\"setSignAction(0)\">\n";
                     }
                  }
               }

               if ($myDEBUG) {print  DEBUG "In PrintSignatureInfo RevisionStatus: ($revision_status)\n";}

               my $signature_text = GetSignatureText($SignatureID);
               $Action = $Signatures{$SignatureID}{Signed};
               my $SignoffAction = $SignoffActions{$Action};

               if ($Action ne "unsign") {
                   if ($myDEBUG) {print  DEBUG "Signature Text: $signature_text\n";}
                   $SignatureText .= "<td> $signature_text </td>";
               }
               $SignatureText .= "</div>\n";
               $SignatureText .= $query -> end_multipart_form;
            } #RemoteUser is not the last signer
          } else {
               my ($revision_status, $Locked, $LastDocRevID) = RevisionStatus($DocRevID); 
               if ($myDEBUG) {print  DEBUG "Fall through: $Status\n";}
               if ($Status eq "Signed" || $Status eq "Disapproved") {
                 my $signature_text = GetSignatureText($SignatureID);
                 $SignatureText .= "$SignatureLink $signature_text ";
               } else {
                 my $DaysSince = NumberOfDaysSince($SignoffID);
                 if ($LastSignerID == $EmailUserID) {
                    $SignatureText .= "<strong>$SignatureLink (waiting for approval for $DaysSince days)</strong> \n";
                    $SignatureText .= $RedGavel;
                 }
                 else {
                    if (($revision_status eq $Approved_RevisionStatus) ||
                        ($revision_status eq $Unapproved_RevisionStatus)){
                        $SignatureText .= "$SignatureLink ";
                    }
                    else {
                        $SignatureText .= "$SignatureLink (<span class=\"WaitforSignature\">waiting for signature</span> for $DaysSince days)";
                    }
                 }
               }
            }
        } else {
          $SignatureText .= $query -> start_form('GET',"$SignRevision");
          $SignatureText .= "<div>\n";
          $SignatureText .= "$SignatureLink (signed ";

          $SignatureText .= $query -> hidden(-name => 'docid',   -default => $DocumentID);
          
          $SignatureText .= $query -> hidden(-name => 'version',   -default => $Version);
          $SignatureText .= $query -> hidden(-name => 'signatureid',   -default => $SignatureID);
          $SignatureText .= $query -> hidden(-name => 'emailuserid',   -default => $EmailUserID);
          $SignatureText .= $query -> hidden(-name => 'action',   -default => $Action);
          $SignatureText .= $query -> password_field(-name => "password-$EmailUserID", -size => 16, -maxlength => 32);
          $SignatureText .= "</div>\n";
          $SignatureText .= $query -> end_multipart_form;
        }
      } elsif ($Status eq "NotReady") {
          my ($revision_status, $Locked, $LastDocRevID) = RevisionStatus($DocRevID); 
          if (($revision_status eq $Approved_RevisionStatus) ||
              ($revision_status eq $Unapproved_RevisionStatus)) {
              $SignatureText .= "$SignatureLink ";
          }
          else {
              $SignatureText .= "$SignatureLink (waiting for other signatures)";
          }
      } else {
        $SignatureText .= "$SignatureLink (unknown status)";
      }
      push @SignatureSnippets,$SignatureText;
    } # if ($SignatureIDOK)
  } # foreach (@SignatureIDs)

  my $SignoffText = join ' or <br>',@SignatureSnippets;
  print "$SignoffText\n";

  if ($myDEBUG) { close (DEBUG);}
}

sub SignatureLink ($) {
  require "NotificationSQL.pm";
  require "DocumentSQL.pm"; ###
  my ($EmailUserID,$DocumentID_asArg) = @_; ###
  # If DocID is not available as a global (as in multiple doc lists), pass it:  ###
  if (defined($DocumentID_asArg) && $DocumentID_asArg ne "") { ###
    $DocumentID = $DocumentID_asArg; ###
  } ###
  my $DocAlias = &FetchDocumentAlias($DocumentID); ###

  # has been moved above:
  #my ($EmailUserID) = @_; ###
  require "SignoffSQL.pm"; ###

  &FetchEmailUser($EmailUserID);
  my $Link = "<a href=\"$SignatureReport?emailuserid=$EmailUserID\">";
     $Link .= $EmailUser{$EmailUserID}{Name};
     $Link .= "</a>";
     GetSignerEmail($EmailUserID); ###
    #my $Name = $EmailUser{$EmailUserID}{Name}; ###
    #$mail = " <a href\=\"mailto:$EmailAddress\?Subject\=DCC document LIGO\-$DocAlias\"><img src\=\"".$ImgURLPath."/mail.png\" title\=\"Contact $Name\"></a>"; ###
     $mail = " <a href\=\"mailto:$EmailAddress\?Subject\=DCC document LIGO\-$DocAlias\"><img src\=\"".$ImgURLPath."/mail.png\" title\=\"Contact this signer\"></a>"; ###
     $Link .= $mail; ###

  return $Link;
}


1;
