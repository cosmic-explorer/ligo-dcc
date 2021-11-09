# Locate the .pm files in the CGI directory and allow their use
# # Modify this file if your own files aren't in one of the "standard" locations
#
if (-e "/usr1/www/cgi-bin/private/DocDB/DocDBGlobals.pm") {
   use lib "/usr1/www/cgi-bin/private/DocDB/";
   use lib ".";
} elsif (-e "/usr1/www/dcc/cgi/DocDBGlobals.pm") {
   use lib "/usr1/www/dcc/cgi/";
   use lib ".";
}

1;
