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

# Constants
$TRUE  = 1;
$FALSE = 0;

#
# Usually called like this:
#
#   debug_file_out(-message => "foo $bar");
#
sub debug_file_out {
   if (defined $DEBUG_PRINT && $DEBUG_PRINT eq '666') {
      my (%Params) = @_;
      my $file   = $Params{-file}    || '/tmp/docdb_debug.txt';
      my $append = $Params{-append}  || '>>';
      my $msg    = $Params{-message} || '';
      my $ts = localtime(time);
 
      open my ($F), $append, $file or  die "$0: open $file: $!";
      print $F $ts.": ".$msg."\n";
      close $F;
   }
}

sub syslog_err {
   open(my $fh, "| logger -p syslog.err -t dcc_error");
   print $fh $_[0] . "\n";
   close($fh);
}

sub tolower {
   my ($string) = $_[0];
   $string =~ tr/[A-Z]/[a-z]/;
   return $string;
}

# Simple email service
# #
# # Delivers email in background - No waiting!
# #
# # Example:
# #
# # send_email("$Project Document Database <$DBWebMasterEmail>",
# #            (join ', ',@Addressees),
# #            $Subject,
# #            $Message."\n".$Body);
# #
# # $sendmail should be defined in SiteConfig.pm, i.e.:
# #
# #  $sendmail = '/usr/sbin/sendmail -ODeliveryMode=b -t';
# #

sub send_email_old {
    use Sys::Syslog qw(:standard :macros);
    my ($sender, $rcpts, $subject, $msg) = @_;
    open(MAIL, "|$sendmail")
    and syslog('warning', "DCC sent mail to $rcpts about $subject")
    or syslog('warning', "DCC SENDMAIL OPEN ERROR: $!")
    and warn "DCC ERROR: sendmail pipe open failed: $!";
    print MAIL "From: $sender\n";
    print MAIL "To: $rcpts\n";
    print MAIL "Subject: $subject\n\n";
    print MAIL "$msg\n";
    close(MAIL)
    or syslog('warning', "DCC SENDMAIL CLOSE ERROR: $!")
    and warn "DCC ERROR: sendmail pipe close failed: $!";
    closelog();
}

sub send_email_stub {
    my ($sender, $rcpts, $subject, $msg) = @_;
    open MAIL, ">>/tmp/log.dat";
    print MAIL "send_email_stub called for $rcpts\n";
    close MAIL;
}

sub send_email {
    use Sys::Syslog qw(:standard :macros);
    use Email::Sender::Simple qw(sendmail);
    use Email::Sender::Transport::SMTP;
    use Email::Simple ();
    use Email::Simple::Creator ();
    use Try::Tiny;
    my ($sender, $rcpts, $subject, $msg) = @_;
open BLA, ">>/tmp/log.dat";
print BLA "send_email_new called for $rcpts\n";
close BLA;
    my $message = Email::Simple->create(
      header => [
        From => $sender,
        To => $rcpts,
        Subject => $subject,
      ],
      body => $msg,
    );
    my $transport = Email::Sender::Transport::SMTP->new({
        host => 'localhost',
        port => 25,
    });
    try {
        sendmail($message, { transport => $transport });
    } catch {
        syslog('warning', "DCC sendmail error: $_");
        warn "DCC ERROR: sendmail failed: $_";
    } and syslog('warning', "dcc sent mail to $rcpts about $subject");
open BLA, ">>/tmp/log.dat";
print BLA "send_email closed sendmail\n";
close BLA;
}

sub getUniqueID {
   use Time::HiRes qw(gettimeofday);
   return join('-',gettimeofday);
}

sub Unique {
  my @Elements = @_;
  my %Hash = ();
  foreach my $Element (@Elements) {
    ++$Hash{$Element};
  }
  
  my @UniqueElements = keys %Hash;  
  return @UniqueElements;
}

sub OrderPreservingUnique {
    my %seen = ();
    my @r = ();
    foreach my $a (@_) {
        unless ($seen{$a}) {
            push @r, $a;
            $seen{$a} = 1;
        }
    }
    return @r;
}

sub Union (\@@) {
  my ($Array_ref,@A2) = @_;

  my @A1 = @{$Array_ref};

  @A1 = &Unique(@A1);
  @A2 = &Unique(@A2);
  push @A1,@A2; # Concat arrays into A1
  my @UnionElements = ();
  
  my %Hash = ();
  foreach my $Element (@A1) {
    if ($Hash{$Element} > 0) {
      push @UnionElements,$Element;
    } else {  
      ++$Hash{$Element};
    }  
  }
  
  return @UnionElements;
}

# Does this do what RemoveArray does?
sub ArrayDiff (\@@) {
  my (@A1,@A2) = @_;
  my @UniqueElements = ();
  
  foreach my $Element (@A1) {
    if (grep { $_ ne $Element } @A2) {
       push @UniqueElements,$Element;
    }
  }
  
  return @UniqueElements;
}

sub RemoveArray (\@@) { # Removes elements of one array from another
                        # Call &RemoveArray(\@Array1,@Array2)
                        # FIXME: Figure out how to do like push, no reference
                        #        on call needed
                        
  my ($Array_ref,@BadElements) = @_;

  my @Array = @{$Array_ref};

  foreach my $BadElement (@BadElements) {
    my $Index = 0;
    foreach my $Element (@Array) {
      if ($Element eq $BadElement) {
        splice @Array,$Index,1;
      }
      ++$Index;  
    }
  }
  return @Array;
}

sub IndexOf {
  my ($Element,@Array) = @_;
  
  my $Found = 0;
  my $Count = 0;
  foreach my $Test (@Array) {
    if ($Test eq $Element) {
      $Found = 1;
      last;
    }  
    ++$Count;
  }
  
  if ($Found) {
    return $Count;
  } else {
    return undef;
  }          
}

# If AddLineBreaks and URLify will be called on the same input,
# AddLineBreaks MUST BE CALLED FIRST!
sub URLify {
   use Sys::Hostname;
   my $host_name = 'https://'.hostname.'.ligo.org';
   my ($Text) = @_;
   # Carefully selected tags that flag content that would get broken
   # if we start sticking URL's in them.
   if ($Text !~ m/<(br|tr|td|dd|table|div|span|pre|center|p|\/a)>/) {
       $Text =~ s/([^\=\>])?((https|http|ftp|file):[\/]+[^\,\s\n\t<]+)/$1<a href=$2>$2<\/a>/ig;
       $Text =~ s/href=(.+)\.>(.+)\.<\/a>/href=$1>$2<\/a>/g;
       $Text =~ s/([\s\n\t])((LIGO-)?[A-Z]\d{6,8}(-[xv]\d+)?)/$1<a href=$host_name\/$2>$2<\/a>/ig;
   }
   $Text = &SafeHTML($Text);
   return $Text;           
}

# BUG #455
# use regex to detect Latex expressions using $..$  or $$..$$
# and replace with \(..\) and \[..\]
# detect and leave finace expressions untouched
sub SanitizeLatexExpression {
  my ($Text) = @_;
  if ($Text =~ m/\$.*\$/) {
    my @probable_math = ($Text =~ /(10\^|\$ \w|\$[^ ]+\$|\$\$|\\\wdot|\\sigma|\\epsilon|\\sum|\\sim|\\approx|\\delta|\\sqrt|\$1\/f\$)/g);
    my @probable_finance = ($Text =~ /(\$\W?\d|cost|estimate|budget|\\\$)/g);
    my $score = scalar @probable_math - scalar @probable_finance;
    if ($score < 0) {
      # financial: let's escape the $ sign as an abundance of caution
      $Text =~ s/\\?\$/&#36;/g;
    } elsif ($score >= 0 ){
      # this is a MathJax then 
      # replace $$ pairs with \\\[ ... \\\]
      $Text =~ s/\$\$([^\$]+)\$\$/\\\[ $1 \\\]/g;
      # then  $ pairs with \\\( ... \\\)
      $Text =~ s/\$([^\$]+)\$/\\\( $1 \\\)/g;
    }
  }
  return $Text;
}


sub AddTime ($$) {
  my ($TimeA,$TimeB) = @_;
  
  use Time::Local;

  my ($HourA,$MinA,$SecA) = split /:/,$TimeA;
  my ($HourB,$MinB,$SecB) = split /:/,$TimeB;
  
  $TimeA = timelocal($SecA,$MinA,$HourA,1,0,0);
  $TimeB = timelocal($SecB,$MinB,$HourB,1,0,0)-timelocal(0,0,0,1,0,0);
  
  my $Time = $TimeA + $TimeB;

  my ($Sec,$Min,$Hour) = localtime($Time);
  
  my $TimeString = sprintf "%2.2d:%2.2d:%2.2d",$Hour,$Min,$Sec;

  return $TimeString; 
}

# If AddLineBreaks and URLify will be called on the same input,
# AddLineBreaks MUST BE CALLED FIRST!
sub AddLineBreaks {
  my ($Text) = @_;
  # Carefully selected tags that flag content that would get broken
  # if we start sticking tags willy-nilly into them.
  if ($Text !~ m/<(br|tr|td|dd|table|div|span|pre|center|p|\/a)>/) {
     # Replace two new lines and any space with <p/>
     $Text =~ s/\s*\n\s*\n\s*/<p\/>/g;
     # Replace two new lines and any space with <br/>
     $Text =~ s/\s*\n\s*/<br\/>\n/g;
     # Add line breaks as necessary
     $Text =~ s/<p\/>/<p\/>\n/g;
  }
  $Text = SafeHTML($Text);
  return $Text;
}

my @mismatch = qw(table tbody thead tr td th font div span pre center blockquote
                  dl ul ol h1 h2 h3 h4 h5 h6 fieldset tt p noscript a
                  b strong i em u ins s del);

sub SafeHTML {
    my ($Text) = @_;
    if (defined $Text && length $Text) {
       require "Defang.pm";
       my $Defang = HTML::Defang->new(
          fix_mismatched_tags => 1,
          mismatched_tags_to_fix => \@mismatch
       );
       $Text = $Defang->defang($Text);
    }
    return $Text;
}

sub SafeMathJax {
    my ($Text) = @_;

    return $Text; 
}

# Callback for custom handling URLs in HTML attributes as well as
#  style tag/attribute declarations.
#
# Requires the Defang options to be like:
#
#  my $Defang = HTML::Defang->new(
#     fix_mismatched_tags => 1,
#     mismatched_tags_to_fix => \@mismatch,
#     url_callback => \&DefangUrlCallback
#  );
#
sub DefangUrlCallback {
    my ($Self, $Defang, $lcTag, $lcAttrKey, $AttrValR, $AttributeHash, $HtmlR) = @_;
    if ($$AttrValR =~ /^(http|https):\/\/[a-z0-9_\.-]+\.(ligo\.org|edu|gov)/i) {
       return 0;
    } else {
       return 1;
    }
}    

sub Printable ($) {
  my ($Text) = @_;
  $Text =~ tr/[\040-\377\r\n\t]//cd;
  return $Text;
}  
 
sub FillTable ($) {
  my ($ArgRef) = @_;
  my $Arrange  = exists $ArgRef->{-arrange}  ?   $ArgRef->{-arrange}   : "vertical";
  my $Columns  = exists $ArgRef->{-columns}  ?   $ArgRef->{-columns}   : 1;
  my @Elements = exists $ArgRef->{-elements} ? @{$ArgRef->{-elements}} : ();

  # Nothing other than vertical works
  
  my @PerColumn = ();
  my $PerColumn = int(scalar(@Elements) / $Columns);
  my $ExtraColumns = scalar(@Elements) % $Columns;
  
  for my $i (1..$Columns) {
    if ($ExtraColumns >= $i) {
      $PerColumn[$i] = $PerColumn + 1;
    } else {  
      $PerColumn[$i] = $PerColumn;
    }    
  }
  
  my @ColumnRefs = ();
  
  for my $i (1..$Columns) {
    for my $j (1..$PerColumn[$i]) {
      my $Element = shift @Elements;
      if ($Element) {
        push @{$ColumnRefs[$i]},$Element;
      }  
    }
  }    
  
  return @ColumnRefs;
}
 
## Usage: *myfunc = cache_it(\&myfunc,20);
sub cache_it {
  my ($func,$life) = @_;
  my %cache;

  $afunc = sub {
    my $key = join ',', @_;
    my $now=time();

    if($key eq 'CLEARCACHE') {
      %cache=();
      return;
    }

    # Should the cache be cleaned?
    if($key eq 'CLEANCACHE') {
      foreach my $ckey (keys %cache) {
        delete $cache{$ckey} if $cache{$ckey}->{expires} < $now;
      }
      return;
    }

    unless(exists $cache{$key} and $cache{$key}->{expires} >= $now) {
      # We don't have a cached value, make one
      my $val = $func->(@_);

      # ... and cache it
      $cache{$key} = {
           value => $val,
           expires => $now+$life,
      };
    }

    # return the cached value
    return $cache{$key}->{value};
  };
  return $afunc;
}

 
1;
