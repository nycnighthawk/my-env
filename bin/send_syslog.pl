#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Socket;
use POSIX qw(strftime);
use Time::HiRes qw(gettimeofday);
use Pod::Usage;

# Define constants
my %FACILITY = (
    kern => 0, user => 1, mail => 2, daemon => 3, auth => 4, syslog => 5, lpr => 6, news => 7,
    uucp => 8, cron => 9, authpriv => 10, ftp => 11, ntp => 12, audit => 13, alert => 14, clock => 15,
    local0 => 16, local1 => 17, local2 => 18, local3 => 19, local4 => 20, local5 => 21, local6 => 22, local7 => 23
);

my %PRIORITY = (
    emerg => 0, alert => 1, crit => 2, err => 3, warn => 4, notice => 5, info => 6, debug => 7
);

# Parse arguments
sub parse_arguments {
    my %args;
    GetOptions(
        "server=s"   => \$args{server},
        "protocol=s" => \$args{protocol},
        "facility=s" => \$args{facility},
        "priority=s" => \$args{priority},
        "message=s"  => \$args{message},
        "help|?"     => \$args{help},
    ) or pod2usage(2);

    pod2usage(1) if $args{help};

    $args{server}   ||= '127.0.0.1';
    $args{protocol} ||= 'udp';
    $args{facility} ||= 'local6';
    $args{priority} ||= 'info';
    $args{message}  ||= getpwuid($<) . " " . getlogin() . ": test hello world!";

    return %args;
}

# Format syslog message
sub format_syslog_message {
    my ($facility, $priority, $message, $app_name, $procid, $msgid, $bsd_format) = @_;
    $app_name ||= '-';
    $procid   ||= '-';
    $msgid    ||= '-';
    $bsd_format ||= 0;

    my $facility_code = $FACILITY{$facility};
    my $priority_code = $PRIORITY{$priority};

    die "Invalid facility or priority" unless defined $facility_code && defined $priority_code;

    my $pri = ($facility_code * 8) + $priority_code;
    my $hostname = `hostname`;
    chomp($hostname);

    my $timestamp;
    if ($bsd_format) {
        $timestamp = strftime("%b %d %H:%M:%S", localtime);
        return "<$pri> $timestamp $hostname $app_name: $message";
    } else {
        my ($seconds, $microseconds) = gettimeofday();
        my $milliseconds = int($microseconds / 1000);
        $timestamp = sprintf("%s.%04d", strftime("%Y-%m-%dT%H:%M:%S", localtime), $milliseconds);
        return "<$pri>1 $timestamp $hostname $app_name $procid $msgid - $message";
    }
}

# Send syslog message
sub send_syslog_message {
    my ($server, $protocol, $message) = @_;
    my $port = 514;

    if ($protocol eq 'udp') {
        my $sock;
        socket($sock, PF_INET, SOCK_DGRAM, getprotobyname('udp')) or die "Socket error: $!";
        my $ip = inet_aton($server) or die "Unable to resolve hostname: $server";
        my $addr = sockaddr_in($port, $ip);
        send($sock, $message, 0, $addr) == length($message) or die "Send error: $!";
        close($sock);
    } else {
        my $sock;
        socket($sock, PF_INET, SOCK_STREAM, getprotobyname('tcp')) or die "Socket error: $!";
        my $ip = inet_aton($server) or die "Unable to resolve hostname: $server";
        my $addr = sockaddr_in($port, $ip);
        connect($sock, $addr) or die "Connect error: $!";
        send($sock, $message, 0) == length($message) or die "Send error: $!";
        close($sock);
    }
}

# Main function
sub main {
    my %args = parse_arguments();
    my $formatted_message = format_syslog_message($args{facility}, $args{priority}, $args{message});
    send_syslog_message($args{server}, $args{protocol}, $formatted_message);
}

# Execute main function
main();

__END__

=head1 NAME

syslog_sender - Send syslog messages

=head1 SYNOPSIS

syslog_sender [options]

 Options:
   --server      Syslog server address (default: 127.0.0.1)
   --protocol    Protocol to use (udp or tcp, default: udp)
   --facility    Syslog facility (default: local6)
   --priority    Syslog priority (default: info)
   --message     Message to send (default: "username login: test hello world!")
   --help        Display this help message

=head1 DESCRIPTION

This script sends syslog messages to a specified server using the specified protocol.

=cut
