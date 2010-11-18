#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  mpd-notify.pl
#
#        USAGE:  ./mpd-notify.pl  
#
#  DESCRIPTION:  
#
#      OPTIONS:  ---
# REQUIREMENTS:  Audio::MPD, Desktop::Notify
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Juan C. Muller (Mu), jcmuller@gmail.com
#      COMPANY:  
#      VERSION:  1.0
#      CREATED:  11/12/2010 04:03:59 PM
#     REVISION:  ---
#===============================================================================

=head1 Roadmap

 - Check mp3 file for icon. 
 	- Not-> check cache directory for icon
 		Not present -> try to gather from amazon
 		Present -> display
 	-> display

 - 

=cut

use strict;
use warnings;

package Main;

use Object;
use base 'Object';
use Time::HiRes qw(usleep);

use Desktop::Notify;
use Audio::MPD;
    
# Open a connection to the notification daemon
my $notify = Desktop::Notify->new;

my $notification = $notify->create(
	summary  => "Music Player Daemon",
	timeout  => 5000,
);

# Open a connection to mpd
my $mpd    = Audio::MPD->new;

# Get different things

sub getStatus ()
{
	my $mpdstatus = $mpd->status;

	my $status = $mpdstatus->state;
	my $song   = $mpdstatus->song;

	return $status, $song;
}

sub display ()
{
	#my $stats  = $mpd->stats;
	my $status = $mpd->status;
	my $song   = $mpd->song($status->{song});
	my $time   = $status->time;
	my $volume = $status->volume;

	my (undef, $totalTime) = split /:/, $time->time;

	my $minutes = sprintf('%02d', int ($totalTime / 60));
	my $seconds = sprintf('%02d', $totalTime - $minutes * 60);

	my $statusString = $status->state eq 'play' ? 'playing' : $status->state eq 'paused' ? 'paused' : 'stopped';
	my $repeatString = $status->repeat ? 'on ' : 'off';
	my $randomString = $status->random ? 'on ' : 'off';

	my $track    = $song->track  || '';
	my $songtime = $song->time   || '';
	my $date     = $song->date   || '';
	my $file     = $song->file   || '';
	my $genre    = $song->genre  || '';
	my $artist   = $song->artist || '';
	my $album    = $song->album  || '';
	my $title    = $song->title  || '';
	my $id       = $song->id     || '';
	my $pos      = $song->pos    || '';


	my $icon = '/usr/share/pixmaps/pidgin/protocols/scalable/irc.svg';

	$notification->app_icon($icon);
	$notification->body( << "FINI" );
		$artist - $title<br>
		$album<br>
[$statusString] ${minutes}:${seconds}
volume: ${volume}% repeat: $repeatString random: $randomString
FINI

# Display the notification
	$notification->show;

# Close the notification later
}


while (1)
{
	my ($status, $song) = getStatus;
	display;
	usleep (500_000);
	print "1\n";
}

$notification->close;
