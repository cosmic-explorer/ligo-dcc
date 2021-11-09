#!/usr/bin/perl -w
use strict;
use warnings;

# make sure to include the right 
# path https://stackoverflow.com/questions/841785/how-do-i-include-a-perl-module-thats-in-a-different-directory
# undecided yet if I go for /usr1/www/cgi-bin/private/DocDB (using "production" locatio)
# for .. or ../.. (assumes test directory in production location, simpler but with implication on deployment)
# or for $GIT_ROOT/cgi-bin/private (assumes I know GIT_ROOT, and structure is the same) 
# or externally manage PERL5LIB and trust it blindly
#


#use lib '/usr1/www/cgi-bin/private/DocDB';
use lib '../www/cgi-bin/private/DocDB';
use Test::Simple tests => 6;
require  "Utilities.pm";


# not using <<~ because perl 5.16 is too old to support it
# I also need to not interpolate the $xyz tokens
#T1800347 is a tie of hints and a good sentinel for possible regression on the heuristics
my $T1800347 = 'To characterise the dark noise  dark current  linearity  saturation and quantum efficiency at 1550\ nm for extended InGaAs photodiodes  with different cut off wavelengths and sizes  six types of extended InGaAs photodiodes were tested. 
  These were the IG19x1000S4i  IG22x1000S4i  IG24x500S4i  IG26x500S4i from Laser Components; the FD10D from Thorlabs and the G12183-020K from Hamamatsu. 
  One of the main problems with extended InGaAs photodiodes is the large amount of $1/f$ noise they produce when used with a reverse bias voltage  so the dependence of dark noise on the reverse bias voltage and temperature was investigated. 
  It was found that cooling the photodiode from room temperature to 0\SIunits{\degree C} did not reduce this noise significantly. 
  The dependence of quantum efficiency on the reverse bias voltage was investigated and it was found that for the FD10D  the quantum efficiency can be increased by as much as 15\% if a large reverse bias is used.
  The absolute quantum efficiency for the FD10D was measured  and it was found that  when taking into account reflections from the FD10D s window  the quantum efficiency was 70\% at 0.6V reverse bias. 
  This reverse bias is low enough that the FD10Ds noise is not dominated by $1/f$ noise. 
The best compromise between quantum efficiency increasing vs the dark noise increasing due to the reverse bias was investigated for each diode. 
  The amount of power  with a spot size such that 99.9\% of the laser was on the photodiode  that each photodiode could measure to before saturating was investigated. 
  It was found that the smaller Laser Components photodiodes diodes could only handle up to 1.5\ mA of photocurrent. 
  Due to needing a lower bias voltage so the noise was limited to the shot noise rather than $1/f$ noise  the extended InGaAs photodiodes saturated at a much lower light power than a regular InGaAs photodiode. 
  The laser components photodiodes exhibited an extra source of noise  which is present when the photodiode is operating in the power regime in which it s linear  and gets larger the more saturated the photodiode is becomes. 
  The FD10D was capable of handling 15\ mA of photocurrent  and by measuring the noise of the photocurrent  the increase in photocurrent obtained by increasing the bias can be attributed to the quantum efficiency increasing.
';



ok( &SanitizeLatexExpression("expression 1: without dollar sign") =~ /sign$/, 'expression without $ is untouched' ) ; 
ok( &SanitizeLatexExpression('expression 2: with 1 $ sign') =~ /sign$/, 'expression with 1 $ is untouched');
ok( &SanitizeLatexExpression('expression 3: $ 35 \M{odot}'."\n".' $ on a range of $ 17 Mpsec $ ') =~ /\\\(.*\\\)/sg, 'Inline Latex detected');
ok( &SanitizeLatexExpression('expression 4: $$ 35 '."\n".'\M{odot} $$ on a range of $ 17 Mpsec $') =~ /(\\\[.*\\\])/sg, 'Latex Block detected');
ok( &SanitizeLatexExpression('expression 5: at a unit cost of $ 17 Qy 1 total $ 17 ') =~ /&#36/, 'financial expresion detected');
ok( &SanitizeLatexExpression($T1800347) =~ /\\\(.*\\\)/sg , 'T1800347 correctly recognized as Latex' );

