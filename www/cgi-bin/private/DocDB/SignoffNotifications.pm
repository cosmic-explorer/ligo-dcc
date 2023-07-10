#!/usr/bin/env perl

# some documentation 

=head1 NAME

SignoffNotifications.pm - Email notifications for signoffs

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 METHODS 

=head2 new

=head1 AUTHOR

=head1 BUGS

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

# let's enforce good practices from the get go

use strict;
use warnings;

# I think it's a good idea to keep at least for now

use autodie;

# minimal perl version
use 5.016;

# if it were an actual script I'd recommend to set it up as a modulino to make testing and reuse easier
# refs
# https://briandfoy.github.io/how-a-script-becomes-a-module/
# https://www.perl.com/article/107/2014/8/7/Rescue-legacy-code-with-modulinos/
# https://perlmaven.com/modulino-both-script-and-module
# https://perlmaven.com/self-testing-with-modulino
#
# don't really care if the function run as script is run() or main() as long as it stay consistent accross the project.

1;

