#!/usr/bin/env python3
#!/usr/bin/env python3
import argparse
import socket
import os
from datetime import datetime, timezone

FACILITY = {
    "kern": 0,
    "user": 1,
    "mail": 2,
    "daemon": 3,
    "auth": 4,
    "syslog": 5,
    "lpr": 6,
    "news": 7,
    "uucp": 8,
    "cron": 9,
    "authpriv": 10,
    "ftp": 11,
    "ntp": 12,
    "audit": 13,
    "alert": 14,
    "clock": 15,
    "local0": 16,
    "local1": 17,
    "local2": 18,
    "local3": 19,
    "local4": 20,
    "local5": 21,
    "local6": 22,
    "local7": 23,
}

PRIORITY = {
    "emerg": 0,
    "alert": 1,
    "crit": 2,
    "err": 3,
    "warn": 4,
    "notice": 5,
    "info": 6,
    "debug": 7,
}


def parse_arguments():
    parser = argparse.ArgumentParser(description="Send syslog messages.")
    parser.add_argument(
        "--host",
        default="127.0.0.1",
        help="Syslog server hostname or IP address (default: 127.0.0.1)",
    )
    parser.add_argument(
        "--port", type=int, default=514, help="Syslog server port (default: 514)"
    )
    parser.add_argument(
        "--tcp", default=False, action="store_true", help="Use TCP instead of UDP"
    )
    parser.add_argument(
        "--bsd",
        default=False,
        action="store_true",
        help="Use BSD format instead of RFC5424",
    )
    parser.add_argument(
        "--facility", default="local6", help="Syslog facility (default: local6)"
    )
    parser.add_argument(
        "--priority", default="info", help="Syslog priority (default: info)"
    )
    parser.add_argument(
        "--nohostname",
        default=False,
        action="store_true",
        help="no hostname added to the message",
    )
    parser.add_argument(
        "--raw", default=False, action="store_true", help="message will not be modified"
    )
    parser.add_argument(
        "message",
        nargs="?",
        help="Message to send (default: <uid> <user>: hello world!)",
    )
    args = parser.parse_args()

    if args.message is None:
        uid = os.getuid()
        uname = os.getlogin()
        args.message = f"{uid} {uname}: hello world!"

    return args


def format_syslog_message(
    facility: str,
    priority: str,
    message: str,
    app_name: str = "-",
    procid: str = "-",
    msgid: str = "-",
    bsd_format: bool = False,
    no_hostname: bool = False,
    raw: bool = False,
) -> str:
    facility_code = FACILITY.get(facility)
    priority_code = PRIORITY.get(priority)

    if facility_code is None or priority_code is None:
        raise ValueError("Invalid facility or priority")

    pri = (facility_code * 8) + priority_code
    hostname = socket.gethostname()
    if raw:
        return f"{message}"

    if bsd_format:
        timestamp = datetime.now().strftime("%b %d %H:%M:%S")
        if no_hostname:
            return f"<{pri}>{timestamp} {message}"
        else:
            return f"<{pri}>{timestamp} {hostname}: {message}"
    else:
        timestamp = (
            datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-4] + "Z"
        )
        if no_hostname:
            return f"<{pri}>1 {timestamp} - {app_name} {procid} {msgid} {message}"
        else:
            return f"<{pri}>1 {timestamp} {hostname} {app_name} {procid} {msgid}: {message}"


def connect_to_syslog(host, port, use_tcp, timeout=1):
    if use_tcp:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((host, port))
        sock.settimeout(timeout)
    else:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

    def socket_writer(data: bytes):
        if use_tcp:
            data_length = len(data)
            payload = f"{data_length} ".encode("utf-8") + data
            sock.sendall(payload)
        else:
            sock.sendto(data, (host, port))

    return socket_writer


def send_syslog_message(message: str, socket_writer):
    data = message.encode("utf-8")
    socket_writer(data)


def main() -> None:
    args = parse_arguments()
    try:
        socket_writer = connect_to_syslog(args.host, args.port, args.tcp)
        if args.bsd is None:
            args.bsd = False
        formatted_message = format_syslog_message(
            args.facility,
            args.priority,
            args.message,
            bsd_format=args.bsd,
            no_hostname=args.nohostname,
            raw=args.raw,
        )
        print(f"formatted raw message: {formatted_message}")
        send_syslog_message(formatted_message, socket_writer)
    except ConnectionRefusedError:
        print(f"connection failed: {args.host}:{args.port}")


if __name__ == "__main__":
    main()
