package Socket::AcceptFilter;

use 5.008008;
use strict;
use warnings;
use Carp;
use Socket qw(SOL_SOCKET IPPROTO_TCP);
use Exporter;

our @EXPORT = qw(accept_filter);
*import = \&Exporter::import;

=head1 NAME

Socket::AcceptFilter - Set FreeFSD SO_ACCEPTFILTER

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Socket::AcceptFilter;
    
    my $socket = ...;
    listen($socket);
    accept_filter($socket,'httpready'); # FreeBSD only
    # or
    accept_filter($socket,'dataready'); # FreeBSD/Linux

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 FUNCTIONS

=head2 accept_filter

=cut

sub accept_filter ($$;$) {
	#define SO_ACCEPTFILTER  0x1000 # fbsd
	#define TCP_DEFER_ACCEPT 9      # linux
	#struct  accept_filter_arg {
	#	char    af_name[16];
	#	char    af_arg[256-16];
	#};
	#setsockopt(s, IPPROTO_TCP, TCP_DEFER_ACCEPT, &yes, sizeof yes);
	my ($fh,$name,$arg) = @_;
	$arg = '' unless defined $arg;
	if ($^O eq 'freebsd') {
		my $aha = pack('Z16 Z240',$name,$arg);
		my $rc = setsockopt
			$fh,
			SOL_SOCKET, 0x1000, $aha
			or carp "accept_filter($name) failed: ".({ reverse %! }->{0+$!}).": $!";
		return $rc;
	}
	elsif ($name eq 'dataready' and $^O eq 'linux') {
		my $rc = setsockopt
			$fh, IPPROTO_TCP, 9 , 1
			or carp "accept_filter($name) failed: ".({ reverse %! }->{0+$!}).": $!";
		return $rc;
	}
	else {
		carp("accept_filter $name not implemented for on $^O");
		return;
	}
}

=head1 AUTHOR

Mons Anderson, C<< <mons at cpan.org> >>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Socket::AcceptFilter

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Socket-AcceptFilter>

=item * Search CPAN

L<http://search.cpan.org/dist/Socket-AcceptFilter/>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2009 Mons Anderson, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Socket::AcceptFilter
