#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Socket;
use POSIX qw(strftime);
use Sys::Hostname;
use IO::Socket::INET;
use Time::HiRes qw(gettimeofday);

my %FACILITY = (
    kern => 0, user => 1, mail => 2, daemon => 3, auth => 4, syslog => 5, lpr => 6, news => 7,
    uucp => 8, cron => 9, authpriv => 10, ftp => 11, ntp => 12, audit => 13, alert => 14, clock => 15,
    local0 => 16, local1 => 17, local2 => 18, local3 => 19, local4 => 20, local5 => 21, local6 => 22, local7 => 23
);

my %PRIORITY = (
    emerg => 0, alert => 1, crit => 2, err => 3, warn => 4, notice => 5, info => 6, debug => 7
);

sub parse_arguments {
    my %args;
    GetOptions(
        'host=s' => \$args{host},
        'port=i' => \$args{port},
        'tcp' => \$args{tcp},
        'facility=s' => \$args{facility},
        'priority=s' => \$args{priority},
        'help|?' => sub { pod2usage(1) }
    ) or pod2usage(2);
    $args{host} //= '127.0.0.1';
    $args{port} //= 514;
    $args{facility} //= 'local6';
    $args{priority} //= 'info';
    $args{message} = join(' ', @ARGV) if @ARGV;
    if (!defined $args{message}) {
        my $uid = $<;
        my $uname = getpwuid($uid);
        $args{message} = "$uid $uname: hello world!";
    }
    return \%args;
}

sub format_syslog_message {
    my ($facility, $priority, $message, $app_name, $procid, $msgid, $bsd_format) = @_;
    $app_name = defined $app_name ? $app_name : '-';
    $procid = defined $procid ? $procid : '-';
    $msgid = defined $msgid ? $msgid : '-';
    $bsd_format = defined $bsd_format ? $bsd_format : 0;

    my $facility_code = $FACILITY{$facility};
    my $priority_code = $PRIORITY{$priority};

    die "Invalid facility or priority" unless defined $facility_code && defined $priority_code;

    my $pri = ($facility_code * 8) + $priority_code;
    my $hostname = hostname();
    if ($bsd_format) {
        my $timestamp = strftime("%b %d %H:%M:%S", localtime);
        return "<$pri> $timestamp $hostname $app_name $message";
    } else {
        my ($seconds, $microseconds) = gettimeofday();
        my $milliseconds = int($microseconds / 1000);
        my $timestamp = strftime("%Y-%m-%dT%H:%M:%S", gmtime($seconds)) . sprintf(".%03dZ", $milliseconds);
        return "<$pri>1 $timestamp $hostname $app_name $procid $msgid - $message";
    }
}

sub connect_to_syslog {
    my ($host, $port, $use_tcp) = @_;
    my $sock;
    if ($use_tcp) {
        $sock = IO::Socket::INET->new(
            PeerAddr => $host,
            PeerPort => $port,
            Proto    => 'tcp'
        ) or die "Could not create socket: $!";
    } else {
        $sock = IO::Socket::INET->new(
            PeerAddr => $host,
            PeerPort => $port,
            Proto    => 'udp'
        ) or die "Could not create socket: $!";
    }
    return sub {
        my ($data) = @_;
        if ($use_tcp) {
            print $sock $data;
        } else {
            $sock->send($data);
        }
    };
}

sub send_syslog_message {
    my ($message, $socket_writer) = @_;
    $socket_writer->($message);
}

sub main {
    my $args = parse_arguments();
    my $socket_writer = connect_to_syslog($args->{host}, $args->{port}, $args->{tcp});
    my $formatted_message = format_syslog_message($args->{facility}, $args->{priority}, $args->{message});
    send_syslog_message($formatted_message, $socket_writer);
}

main() if !caller;

__END__

=head1 NAME

syslog_sender - Send syslog messages.

=head1 SYNOPSIS

syslog_sender [options] [message]

 Options:
   --host       Syslog server hostname or IP address (default: 127.0.0.1)
   --port       Syslog server port (default: 514)
   --tcp        Use TCP instead of UDP
   --facility   Syslog facility (default: local6)
   --priority   Syslog priority (default: info)
   --help       Display this help message

=head1 DESCRIPTION

This script sends syslog messages to a specified syslog server.

If no message is provided, a default message containing the UID and username will be sent.

