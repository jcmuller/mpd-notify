# mpd-notify

This utility connects to a MPD music server and monitors it for status changes.
Once a song, the transport status (play, stop, pause), the volume, or the
repeat status changes, a notification using the Desktop notification system is
displayed. It has only been tested in Linux, using the Desktop notification
system implemented by the Galago project (see
http://www.galago-project.org/specs/notification/).

It will download cover images from an online source. This hasn't been
implemented yet.

To install, for the time being, copy or symlink src/mpd-notify to ~/bin or a
directory in your path.

Required modules:

* common::sense
* Audio::MPD
* Desktop::Notify
* Getopt::Long
    * Pod::Usage
    * Time::HiRes qw(usleep)

Run the requirement check scipt (which requires Test::More) by running:

	perl src/check-requirements.pl

