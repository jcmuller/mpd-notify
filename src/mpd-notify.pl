#!/usr/bin/perl 

use common::sense;

=head1 DESCRIPTION

Get the data from MPD and display a notification window using Desktop::Notify.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
Street, Fifth Floor, Boston, MA  02110-1301, USA.

=head1 AUTHOR

Juan C. Muller &lt;jcmuller@gmail.com&gt;

=head1 SYNOPSIS

mpd-notify.pl [options]

	-o, --once		Run once
	-c, --covers [args]
					Directory(ies) where to look for covers. The first one will
					be used to store new ones (currently not implemented).
	-h, --mpd-host	Host name where MPD is running
	-p, --mpd-port	Port number where MPD is running
	-m, --man		Shoa man page
	-h, --help		Show this text
	-i, --images-from [args]
					If arg='list' will show all the hosts where covers can be 
					retrieved from.

=cut

package Defaults;

sub base_path
{
	my $base_path = "${ENV{HOME}}/.covers";
	return $base_path;
}

# {{{ TODO
#
# - Check mp3 file for icon. 
# 	- Not-> check cache directory for icon
# 		Not present -> try to gather from amazon
# 		Present -> display
# 	-> display
#
# - Add command line arguments
# 	- Once
# 		- Shows notification once. Otherwise, program runs forever.
# 	- cover directory
# 	- mpd host
# 	- mpd port
# 	- Choice of hosts to get covers from.
# 		- Might need API keys.

# }}}

package MpdNotify;

use Audio::MPD;
use Desktop::Notify;
use Getopt::Long;
use Time::HiRes qw(usleep);
use Pod::Usage;

=head1 CONSTRUCTOR

=head2 SYNOPSIS

 my $mpdn = MpdNotify->new(%args);

=cut

sub new
{
	my ($proto, %args) = @_;
	my $class = ref $proto || $proto;
	my $self = {};
	bless $self, $class;
	$self->_initialize(%args) if ($self->can('_initialize'));
	return $self;
}

sub _collect_arguments
{
	my ($self) = @_;

	my %arguments;
	GetOptions(\%arguments,
		'once',
		'cover=s@',
		'mpd-host=s',
		'mpd-port=i',
		'man',
		'help',
		'images-from=s@'
	);

	$self->{arguments} = \%arguments;

	if ($self->{arguments}{help})
	{
		pod2usage(1);
	}
	elsif ($self->{arguments}{man})
	{
		pod2usage(-verbose => 2);
	}
}

sub _initialize
{
	my ($self, %args) = @_;

	$self->_collect_arguments;

	# Open a connection to the notification daemon
	$self->{notify} = Desktop::Notify->new;

	# Create notification
	$self->{notification} = $self->{notify}->create(timeout  => 5000);

	# Open a connection to MPD, and reuse it.
	my %args = (
		conntype => 'reuse',
	);

	$args{host} = $self->{arguments}{'mpd-host'} if ($self->{arguments}{'mpd-host'});
	$args{port} = $self->{arguments}{'mpd-port'} if ($self->{arguments}{'mpd-port'});
	$self->{mpd}    = Audio::MPD->new(\%args);
}

# Get different things

sub _get_status
{
	my ($self) = @_;

	my $mpdstatus = $self->{mpd}->status;

	my $status = $mpdstatus->state  || 0;
	my $song   = $mpdstatus->song   || 0;
	my $random = $mpdstatus->random || 0;
	my $repeat = $mpdstatus->repeat || 0;
	my $volume = $mpdstatus->volume || 0;

	return 
		$random,
		$repeat,
		$song,
		$status,
		$volume;
}

sub _get_album_cover
{
	my ($self, $artist, $album) = @_;

	my $BASE_PATH = Defaults->base_path;

	mkdir $BASE_PATH if (! -d $BASE_PATH);

	my $filename = "$BASE_PATH/${artist}_${album}.png";
	#print "$filename\n";

	if ( -e $filename and ! -z $filename)
	{
		return $filename;
	}

	my $icon = "$BASE_PATH/default.png";
	return $icon;
}

sub display
{
	my ($self) = @_;

	my $status = $self->{mpd}->status;

	my $song   = '';
	my $time   = '';
	my $volume = '';

	my $minutes = '';
	my $seconds = '';

	my $track    = '';
	my $songtime = '';
	my $date     = '';
	my $file     = '';
	my $genre    = '';
	my $artist   = '';
	my $album    = '';
	my $title    = '';
	my $id       = '';
	my $pos      = '';

	my $statusString = 'stopped';
	my $repeatString = '';
	my $randomString = '';
	my $timeString = '';

	if ($status->state ne 'stop')
	{
		$song   = $self->{mpd}->song($status->{song});
		$time   = $status->time;
		$volume = $status->volume;

		my (undef, $totalTime) = split /:/, $time->time;

		$minutes    = sprintf('%02d', int ($totalTime / 60));
		$seconds    = sprintf('%02d', $totalTime - $minutes * 60);
		$timeString = "${minutes}:${seconds}";

		$statusString = $status->state eq 'play' ? 'playing' : 'paused';
		$repeatString = $status->repeat ? 'on ' : 'off';
		$randomString = $status->random ? 'on ' : 'off';

		$track    = $song->track  || '';
		$songtime = $song->time   || '';
		$date     = $song->date   || '';
		$file     = $song->file   || '';
		$genre    = $song->genre  || '';
		$artist   = $song->artist || '';
		$album    = $song->album  || '';
		$title    = $song->title  || '';
		$id       = $song->id     || '';
		$pos      = $song->pos    || '';
	}

	$self->{notification}->summary("Music Player Daemon - [$statusString]");

	my $body = << "FINI";
$artist - $title<br>
$album<br>
[$statusString] $timeString
volume: ${volume}% repeat: $repeatString random: $randomString
FINI

	my $icon = $self->_get_album_cover($artist, $album);
	$self->{notification}->app_icon($icon);
	$self->{notification}->body($body);

	#print "$body\n";

	# Display the notification
	$self->{notification}->show;
}

=head1 notify

=head2 SYNOPSIS

=cut

sub notify
{
	my ($self) = @_;

	my $old_song;
	my $old_status;
	my $old_volume;
	my $old_repeat;
	my $old_random;

	while (1)
	{
		my (
			$random,
			$repeat,
			$song,
			$status,
			$volume
		) = $self->_get_status;

		if (
			(!$old_song and !$old_status) or
			($old_song   != $song)        or
			($old_status ne $status)      or
			($old_random ne $random)      or
			($old_repeat ne $repeat)      or
			($old_volume != $volume)
		)
		{
			$old_song   = $song;
			$old_status = $status;
			$old_volume = $volume;
			$old_random = $random;
			$old_repeat = $repeat;
			$self->display;
		}

		last if ($self->{arguments}{once});

		usleep (500_000);
	}

	# This will probably *never* be reached, but we include for correctness.
	$self->{notification}->close;
}

package Main;

sub main
{
	my $mpdn = MpdNotify->new;
	$mpdn->notify;
}

main();

# vim:set foldmethod=marker:
