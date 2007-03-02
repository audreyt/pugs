package Web::Terminal::Msg;
use strict;
#use IO::Select;
#use IO::Socket;
#use Carp;

our %rd_callbacks = ();
our %wt_callbacks = ();
our $rd_handles   = IO::Select->new();
our $wt_handles   = IO::Select->new();
my $blocking_supported = 0;

#BEGIN {
#    # Checks if blocking is supported
#    eval {
#        require POSIX; POSIX->import(qw (F_SETFL O_NONBLOCK EAGAIN));
#    };
#    $blocking_supported = 1 unless $@;
#}

#-----------------------------------------------------------------
class Endpoint {
$.sock;
$.rcvd_notification_proc;
}
# Send side routines
sub connect ($pkg, $to_host, $to_port,$rcvd_notification_proc) {
    
    # Create a new internet socket
    my $sock=connect($to_host,$to_port);    
#    my $sock = IO::Socket::INET->new (
#                                      PeerAddr => $to_host,
#                                      PeerPort => $to_port,
#                                      Proto    => 'tcp',
#                                      Reuse    => 1);

    return undef unless $sock;

    # Create a connection end-point object
#    my $conn = bless {
#        sock                   => $sock,
#        rcvd_notification_proc => $rcvd_notification_proc,
#    }, $pkg;
   my $conn=Endpoint.new();
   $conn.sock=$sock;
   $conn.rcvd_notification_proc=$rcvd_notification_proc;

if ($rcvd_notification_proc) {
        my $callback = sub {_rcv($conn, 0)};
        set_event_handler ($sock, "read" => $callback);
    }
    return $conn;
}

sub disconnect ($conn) {
    my $sock = delete $conn.sock;
    return unless defined($sock);
    set_event_handler ($sock, "read" => undef, "write" => undef);
    $sock.close();
}

sub send_now ($conn, $msg) {
    _enqueue ($conn, $msg);
    $conn->_send (1); # 1 ==> flush
}

sub send_later ($conn, $msg) {
    _enqueue($conn, $msg);
    my $sock = $conn->{sock};
    return unless defined($sock);
    set_event_handler ($sock, "write" => sub {$conn->_send(0)});
}

sub _enqueue ($conn, $msg) {
    # prepend length (encoded as network long)
    my $len = length($msg);
    $msg = pack ('N', $len) . $msg; 
    push (@{$conn->{queue}}, $msg);
}

sub _send ($conn, $flush) {
    my $sock = $conn->{sock};
    return unless defined($sock);
    my ($rq) = $conn->{queue};

    # If $flush is set, set the socket to blocking, and send all
    # messages in the queue - return only if there's an error
    # If $flush is 0 (deferred mode) make the socket non-blocking, and
    # return to the event loop only after every message, or if it
    # is likely to block in the middle of a message.

    $flush ? $conn->set_blocking() : $conn->set_non_blocking();
    my $offset = (exists $conn->{send_offset}) ? $conn->{send_offset} : 0;

    while (@$rq) {
        my $msg            = $rq->[0];
        my $bytes_to_write = length($msg) - $offset;
        my $bytes_written  = 0;
        while ($bytes_to_write) {
            $bytes_written = syswrite ($sock, $msg,
                                       $bytes_to_write, $offset);
            if (!defined($bytes_written)) {
                if (_err_will_block($!)) {
                    # Should happen only in deferred mode. Record how
                    # much we have already sent.
                    $conn->{send_offset} = $offset;
                    # Event handler should already be set, so we will
                    # be called back eventually, and will resume sending
                    return 1;
                } else {    # Uh, oh
                    $conn->handle_send_err($!);
                    return 0; # fail. Message remains in queue ..
                }
            }
            $offset         += $bytes_written;
            $bytes_to_write -= $bytes_written;
        }
        delete $conn->{send_offset};
        $offset = 0;
        shift @$rq;
        last unless $flush; # Go back to select and wait
                            # for it to fire again.
    }
    # Call me back if queue has not been drained.
    if (@$rq) {
        set_event_handler ($sock, "write" => sub {$conn->_send(0)});
    } else {
        set_event_handler ($sock, "write" => undef);
    }
    1;  # Success
}

sub _err_will_block {
    if ($blocking_supported) {
        return ($_[0] == EAGAIN());
    }
    return 0;
}
sub set_non_blocking {                        # $conn->set_blocking
    if ($blocking_supported) {
        # preserve other fcntl flags
        my $flags = fcntl ($_[0], F_GETFL(), 0);
        fcntl ($_[0], F_SETFL(), $flags | O_NONBLOCK());
    }
}
sub set_blocking {
    if ($blocking_supported) {
        my $flags = fcntl ($_[0], F_GETFL(), 0);
        $flags  &= ~O_NONBLOCK(); # Clear blocking, but preserve other flags
        fcntl ($_[0], F_SETFL(), $flags);
    }
}
sub handle_send_err ($conn, $err_msg) {
   # For more meaningful handling of send errors, subclass Msg and
   # rebless $conn.  
   warn "Error while sending: $err_msg \n";
   set_event_handler ($conn.sock, "write" => undef);
}

#-----------------------------------------------------------------
# Receive side routines

my ($g_login_proc,$g_pkg);
my $main_socket = 0;
sub new_server ($pkg, $my_host, $my_port, $login_proc) {
    #@_ == 4 || die "Msg->new_server (myhost, myport, login_proc)\n";
    #my ($pkg, $my_host, $my_port, $login_proc) = @_;
    
    $main_socket = listen($my_port);
#    $main_socket = IO::Socket::INET->new (
#                                          LocalAddr => $my_host,
#                                          LocalPort => $my_port,
#                                          Listen    => 5,
#                                          Proto     => 'tcp',
#                                          Reuse     => 1);
    die "Could not create socket: $! \n" unless $main_socket;
    set_event_handler ($main_socket, "read" => \&_new_client);
    $g_login_proc = $login_proc; $g_pkg = $pkg;
}

sub rcv_now ($conn) {
    my ($msg, $err) = _rcv ($conn, 1); # 1 ==> rcv now
    return wantarray ? ($msg, $err) : $msg;
}

# Complement to _send
sub _rcv ($conn, $rcv_now) { # $rcv_now complement of $flush
    # Find out how much has already been received, if at all
    my ($msg, $offset, $bytes_to_read, $bytes_read);
    my $sock = $conn->{sock};
    return unless defined($sock);
    if (exists $conn->{msg}) {
        $msg           = $conn->{msg};
        $offset        = length($msg) - 1;  # sysread appends to it.
        $bytes_to_read = $conn->{bytes_to_read};
        delete $conn->{'msg'};              # have made a copy
    } else {
        # The typical case ...
        $msg           = "";                # Otherwise -w complains 
        $offset        = 0 ;  
        $bytes_to_read = 0 ;                # Will get set soon
    }
    # We want to read the message length in blocking mode. Quite
    # unlikely that we'll get blocked too long reading 4 bytes
    if (!$bytes_to_read)  {                 # Get new length 
        my $buf;
        $conn->set_blocking();
        $bytes_read = sysread($sock, $buf, 4);
        if ($! || ($bytes_read != 4)) {
            goto FINISH;
        }
        $bytes_to_read = unpack ('N', $buf);
    }
    $conn->set_non_blocking() unless $rcv_now;
    while ($bytes_to_read) {
        $bytes_read = sysread ($sock, $msg, $bytes_to_read, $offset);
        if (defined ($bytes_read)) {
            if ($bytes_read == 0) {
                last;
            }
            $bytes_to_read -= $bytes_read;
            $offset        += $bytes_read;
        } else {
            if (_err_will_block($!)) {
                # Should come here only in non-blocking mode
                $conn->{msg}           = $msg;
                $conn->{bytes_to_read} = $bytes_to_read;
                return ;   # .. _rcv will be called later
                           # when socket is readable again
            } else {
                last;
            }
        }
    }

  FINISH:
    if (length($msg) == 0) {
        $conn->disconnect();
    }
    if ($rcv_now) {
        return ($msg, $!);
    } else {
        &{$conn->{rcvd_notification_proc}}($conn, $msg, $!);
    }
}

sub _new_client {
    my $sock = $main_socket.accept();
    #returns undef on fail. Calling peerhost on undef makes it die.
    ## so:
    if (defined $sock) {

    my $conn = bless {
        'sock' =>  $sock,
        'state' => 'connected'
    }, $g_pkg;
    my $rcvd_notification_proc =
        &$g_login_proc ($conn, $sock->peerhost(), $sock->peerport());
    if ($rcvd_notification_proc) {
        $conn->{rcvd_notification_proc} = $rcvd_notification_proc;
        my $callback = sub {_rcv($conn,0)};
        set_event_handler ($sock, "read" => $callback);
    } else {  # Login failed
        $conn->disconnect();
    }
    } else {
        return undef;
    }
}

#----------------------------------------------------
# Event loop routines used by both client and server

sub set_event_handler ($handle, %args) {
#    shift unless ref($_[0]); # shift if first arg is package name
#    my ($handle, %args) = @_;
    my $callback;
    if (exists $args{'write'}) {
        $callback = $args{'write'};
        if ($callback) {
            $wt_callbacks{$handle} = $callback;
            $wt_handles->add($handle);
        } else {
            delete $wt_callbacks{$handle};
            $wt_handles->remove($handle);
        }
    }
    if (exists $args{'read'}) {
        $callback = $args{'read'};
        if ($callback) {
            $rd_callbacks{$handle} = $callback;
            $rd_handles->add($handle);
        } else {
            delete $rd_callbacks{$handle};
            $rd_handles->remove($handle);
       }
    }
}

sub event_loop ($pkg, $loop_count) { # event_loop(1) to process events once
    my ($conn, $r, $w, $rset, $wset);
    while (1) {
        # Quit the loop if no handles left to process
        last unless ($rd_handles->count() || $wt_handles->count());
        ($rset, $wset) =
            IO::Select->select ($rd_handles, $wt_handles, undef, undef);
        foreach $r (@$rset) {
            &{$rd_callbacks{$r}} ($r) if exists $rd_callbacks{$r};
        }
        foreach $w (@$wset) {
            &{$wt_callbacks{$w}}($w) if exists $wt_callbacks{$w};
        }
        if (defined($loop_count)) {
            last unless --$loop_count;
        }
    }
}

1;

__END__

=head1 NAME

Web::Terminal::Msg -- Client/Server messaging framework 

=head1 SYNOPSIS

    use Web::Terminal::Msg;
    # in Dispatcher:
    $conn = Web::Terminal::Msg->connect( $host, $port, \&rcvd_msg_from_server );
    # in Server:
    Web::Terminal::Msg->new_server( $host, $port, \&login_proc );
    Web::Terminal::Msg->event_loop();

=head1 AUTHORS

Sriram Srinivasan created Msg.pm for his excellent book "Advanced Perl Programming";
Wim Vanderbauwhede made some minor modifications to incorporate it in
Web::Terminal.

=head1 COPYRIGHT 

Copyright (c) 1997 Sriram Srinivasan. All rights reserved.
Copyright (c) 2006 Wim Vanderbauwhede <wim.vanderbauwhede@gmail.com>. All
rights reserved.

L<http://search.cpan.org/src/SRIRAM/examples/Networking/Msg.pm>

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>
=cut
