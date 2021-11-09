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

# make sure to add the dcc code directory to the LIB
#use lib '/usr1/www/cgi-bin/private/DocDB';
use lib '../www/cgi-bin/private/DocDB';

# do I smell setup() ?
BEGIN {
  system("cp SiteConfig.pm.org SiteConfig.pm");
}



# How many tests need to run ?
use Test::Simple tests => 1;


# require the file/module whose functions you're about to test
use ProjectGlobals; 
use MeetingSQL;

# sub GetConferences { 
# sub ClearConferences () {
# sub GetEventsByDate (%) {
# sub GetRevisionEvents ($%) { # Get the events associated with a revision
# sub GetAllEventGroups () {
# sub ClearEventGroups () {
# sub LookupEventGroup { # Returns EventGroupID from Name
# sub MatchEventGroup ($) {
# sub MatchEvent ($) {
# sub FetchEventGroup ($) {
# sub FetchEventsByGroup ($) {
# sub FetchConferenceByConferenceID { # Fetches a conference by ConferenceID
# sub FetchSessionsByConferenceID ($) {
# sub FetchSessionsByDate ($) {
# sub ClearSessions () {
# sub FetchSessionByID ($) {
# sub FetchSessionSeparatorsByConferenceID ($) {
# sub FetchSessionSeparatorByID ($) {
# sub FetchMeetingOrdersByConferenceID {
# sub InsertEvent (%) {
# sub UpdateEvent (%) {
# sub InsertSession (%) {
# sub UpdateSession (%) {
# sub DeleteEventGroup (%) {
# sub DeleteEvent (%) {
# sub DeleteSession ($) {
# sub DeleteSessionSeparator ($) {
# sub InsertRevisionEvents (%) {
# sub InsertMeetingOrder {
# sub MeetingTopicUpdate {  
# sub MeetingModeratorUpdate {  
# sub GetEventsByModerator ($) {
# sub GetEventsByTopic ($) {

ok( 1, '1 is true');

use DBUtilities;
my $dbh = CreateConnection(-type => "rw");
