# mpd-notify

This utility connects to a MPD music server and monitors it for status changes.
Once a song, the transport status (play, stop, pause), the volume, or the
repeat status changes, a notification using the Desktop notification system is
displayed. It has only been tested in Linux, using the Desktop notification
system implemented by the [Galago
project](http://www.galago-project.org/specs/notification/).

It will download cover images from an online source. This hasn't been
implemented yet.

To install, for the time being, copy or symlink `src/mpd-notify` to `~/bin` or a
directory in your path.

Required modules:

* `Audio::MPD`
* `Desktop::Notify`
* `common::sense`
* `Getopt::Long`
* `Pod::Usage`
* `Time::HiRes`

Run the requirement check scipt (which requires `Test::More`) by running:

	perl src/check-requirements.pl

I had to add a missing feature to `Desktop::Notify::Notification`. The patch is:


	--- a/blib/lib/Desktop/Notify/Notification.pm	2009-12-24 20:09:23.000000000 -0500
	+++ b/blib/lib/Desktop/Notify/Notification.pm	2010-11-17 17:51:45.000000000 -0500
	@@ -5,7 +5,7 @@
	 
	 use base qw/Class::Accessor/;
	 
	-Desktop::Notify::Notification->mk_accessors(qw/summary body timeout/);
	+Desktop::Notify::Notification->mk_accessors(qw/summary body timeout app_icon/);
	 
	 =head1 NAME
	 
	@@ -78,7 +78,7 @@
		 $self->{id} = $self->{server}->{notify}
			 ->Notify($self->{server}->{app_name},
					  $self->{id} || 0,
	-                 '',
	+                 $self->{app_icon} || '',
					  $self->{summary},
					  $self->{body},
					  [],

which basically adds an accessor for `app_icon` and sends `app_icon` to the server.

