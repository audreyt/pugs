=begin pod

=head1 NAME

Sys::Statistics::Linux::MemStats - Collect linux memory informations.

=head1 SYNOPSIS

   use Sys::Statistics::Linux::MemStats;

   my $lxs   = Sys::Statistics::Linux::MemStats.new;
   my %stats = $lxs.get;

=head1 DESCRIPTION

Sys::Statistics::Linux::MemStats gathers memory statistics from the virtual F</proc> filesystem (procfs).

For more informations read the documentation of the front-end module L<Sys::Statistics::Linux>.

=head1 MEMORY INFORMATIONS

Generated by F</proc/meminfo>.

   memused      -  Total size of used memory in kilobytes.
   memfree      -  Total size of free memory in kilobytes.
   memusedper   -  Total size of used memory in percent.
   memtotal     -  Total size of memory in kilobytes.
   buffers      -  Total size of buffers used from memory in kilobytes.
   cached       -  Total size of cached memory in kilobytes.
   realfree     -  Total size of memory is real free (memfree + buffers + cached).
   realfreeper  -  Total size of memory is real free in percent of total memory.
   swapused     -  Total size of swap space is used is kilobytes.
   swapfree     -  Total size of swap space is free in kilobytes.
   swapusedper  -  Total size of swap space is used in percent.
   swaptotal    -  Total size of swap space in kilobytes.

   The following statistics are only available by kernels from 2.6.

   slab         -  Total size of memory in kilobytes that used by kernel for data structure allocations.
   dirty        -  Total size of memory pages in kilobytes that waits to be written back to disk.
   mapped       -  Total size of memory in kilbytes that is mapped by devices or libraries with mmap.
   writeback    -  Total size of memory that was written back to disk.

=head1 METHODS

=head2 new()

Call C<new()> to create a new object.

   my $lxs = Sys::Statistics::Linux::MemStats.new;

=head2 get()

Call C<get()> to get the statistics. C<get()> returns the statistics as a hash reference.

   my %stats = $lxs.get;

=head1 EXAMPLES

    my $lxs = Sys::Statistics::Linux::MemStats.new;
    my $header = 0;

    loop {
        sleep(1);
        my %stats = $lxs.get;
        my $time  = localtime();

        if $header == 0 {
            $header = 20;
            print  ' ' x 20;
            printf "%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\n",
                   <memused memfree memusedper memtotal buffers cached realfree realfreeper
                    swapused swapfree swapusedper swaptotal slab dirty mapped writeback>;
        }

        printf "%04d-%02d-%02d %02d:%02d:%02d %12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s%12s\n",
               $time.<year month day hour min sec>,
               %stats<memused memfree memusedper memtotal buffers cached realfree realfreeper
                      swapused swapfree swapusedper swaptotal slab dirty mapped writeback>;

        $header--;
    }

=head1 EXPORTS

No exports.

=head1 SEE ALSO

B<proc(5)>

=head1 REPORTING BUGS

Please report all bugs to <jschulz.cpan(at)bloonix.de>.

=head1 AUTHOR

Jonny Schulz <jschulz.cpan(at)bloonix.de>.

=head1 COPYRIGHT

Copyright (c) 2006, 2007 by Jonny Schulz. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=end pod

#package Sys::Statistics::Linux::MemStats;
#our $VERSION = '0.08';

class Sys::Statistics::Linux::MemStats-0.001;

use v6-alpha;

#use strict;
#use warnings;
#use Carp qw(croak);

sub croak (*@m) { die @m } # waiting for Carp::croak

#sub new {
#   my $class = shift;
#   my %self = (
#      files => {
#         meminfo => '/proc/meminfo',
#      }
#   );
#   return bless \%self, $class;
#}

has Hash $.files = {};

submethod BUILD () {
    $.files<meminfo> = '/proc/meminfo';
}

#sub get {
#   my $self    = shift;
#   my $class   = ref($self);
#   my $file    = $self->{files};
#   my %meminfo = ();
#
#   open my $fh, '<', $file->{meminfo} or croak "$class: unable to open $file->{meminfo} ($!)";
#
#   while (my $line = <$fh>) {
#      if ($line =~ /^(MemTotal|MemFree|Buffers|Cached|SwapTotal|SwapFree|Slab|Dirty|Mapped|Writeback):\s*(\d+)/) {
#         my ($n, $v) = ($1, $2);
#         $n =~ tr/A-Z/a-z/;
#         $meminfo{$n} = $v;
#      }
#   }
#
#   close($fh);
#
#   $meminfo{memused}     = sprintf('%u', $meminfo{memtotal} - $meminfo{memfree});
#   $meminfo{memusedper}  = sprintf('%.2f', 100 * $meminfo{memused} / $meminfo{memtotal});
#   $meminfo{swapused}    = sprintf('%u', $meminfo{swaptotal} - $meminfo{swapfree});
#   $meminfo{realfree}    = sprintf('%u', $meminfo{memfree} + $meminfo{buffers} + $meminfo{cached});
#   $meminfo{realfreeper} = sprintf('%.2f', 100 * $meminfo{realfree} / $meminfo{memtotal});
#
#   # maybe there is no swap space on the machine
#   if (!$meminfo{swaptotal}) {
#      $meminfo{swapusedper} = 0;
#   } else {
#      $meminfo{swapusedper} = sprintf('%.2f', 100 * $meminfo{swapused} / $meminfo{swaptotal});
#   }
#
#   return \%meminfo;
#}

method get () {
    my $memfile = self.files<meminfo>;
    my $memfh   = open($memfile, :r) or croak("unable to open $memfile: $!");
    my %meminfo;

    for =$memfh -> $line {
        next unless $line ~~ /^(
            MemTotal | MemFree  | Buffers  | Cached   | SwapTotal|
            SwapFree | Slab     | Dirty    | Mapped   | Writeback
            )\:\s*(\d+)/;

        my ($n, $v) = ($0, $1);
        %meminfo{$n.lc} = $v;
    }

    $memfh.close;

    %meminfo<memused>     = sprintf('%u', %meminfo<memtotal> - %meminfo<memfree>);
    %meminfo<memusedper>  = sprintf('%.2f', 100 * %meminfo<memused> / %meminfo<memtotal>);
    %meminfo<swapused>    = sprintf('%u', %meminfo<swaptotal> - %meminfo<swapfree>);
    %meminfo<realfree>    = sprintf('%u', %meminfo<memfree> + %meminfo<buffers> + %meminfo<cached>);
    %meminfo<realfreeper> = sprintf('%.2f', 100 * %meminfo<realfree> / %meminfo<memtotal>);

    # maybe there is no swap space on the machine
    if !%meminfo<swaptotal> {
       %meminfo<swapusedper> = 0;
    } else {
       %meminfo<swapusedper> = sprintf('%.2f', 100 * %meminfo<swapused> / %meminfo<swaptotal>);
    }

    return %meminfo;
}

1;
