#!/usr/bin/perl 

# {{{ POD

=head1 AUTHOR

(c) 2010 Juan C. Muller E<lt>jcmuller@gmail.comE<gt>. All rights reserved.

=head1 DESCRIPTION

Check requirements for mpd-notify

=head1 VERSION

v0.1

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

=cut
# }}}

use strict;
use warnings;
use Test::More tests => 6;

BEGIN { use_ok('common::sense'); };
BEGIN { use_ok('Audio::MPD'); };
BEGIN { use_ok('Desktop::Notify'); };
BEGIN { use_ok('Getopt::Long'); };
BEGIN { use_ok('Pod::Usage'); };
BEGIN { use_ok('Time::HiRes'); };


# vim:set foldmethod=marker expandtab sw=4 ts=4:

