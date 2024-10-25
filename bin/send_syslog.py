#!/usr/bin/env python3
#!/usr/bin/env python3
import argparse
import socket
import os
from datetime import datetime, timezone

FACILITY = {
    "kern": 0, "user": 1, "mail": 2, "daemon": 3, "auth": 4, "syslog": 5, "lpr": 6, "news": 7,
    "uucp": 8, "cron": 9, "authpriv": 10, "ftp": 11, "ntp": 12, "audit": 13, "alert": 14, "clock": 15,
    "local0": 16, "local1": 17, "local2": 18, "local3": 19, "local4": 20, "local5": 21, "local6": 22, "local7": 23
}

PRIORITY = {
    "emerg": 0, "alert": 1, "crit": 2, "err": 3, "warn": 4, "notice": 5, "info": 6, "debug": 7
}

def parse_arguments():
    parser = argparse.ArgumentParser(description='Send syslog messages.')
    parser.add_argument('--host', default='127.0.0.1', help='Syslog server hostname or IP address (default: 127.0.0.1)')
    parser.add_argument('--port', type=int, default=514, help='Syslog server port (default: 514)')
    parser.add_argument('--tcp', action='store_true', help='Use TCP instead of UDP')
    parser.add_argument('--facility', default='local6', help='Syslog facility (default: local6)')
    parser.add_argument('--priority', default='info', help='Syslog priority (default: info)')
    parser.add_argument('message', nargs='?', help='Message to send (default: <uid> <user>: hello world!)')
    args = parser.parse_args()
    
    if args.message is None:
        uid = os.getuid()
        uname = os.getlogin()
        args.message = f'{uid} {uname}: hello world!'
    
    return args

def format_syslog_message(facility: str, priority: str, message: str, app_name: str = "-", procid: str = "-", msgid: str = "-", bsd_format: bool = False) -> str:
    facility_code = FACILITY.get(facility)
    priority_code = PRIORITY.get(priority)
    
    if facility_code is None or priority_code is None:
        raise ValueError("Invalid facility or priority")

    pri = (facility_code * 8) + priority_code
    hostname = socket.gethostname()
    
    if bsd_format:
        timestamp = datetime.now().strftime("%b %d %H:%M:%S")
        return f"<{pri}> {timestamp} {hostname} {app_name} {message}"
    else:
        timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-4] + 'Z'
        return f"<{pri}>1 {timestamp} {hostname} {app_name} {procid} {msgid} - {message}"

def connect_to_syslog(host, port, use_tcp):
    if use_tcp:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((host, port))
    else:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    
    def socket_writer(data: bytes):
        if use_tcp:
            sock.sendall(data)
        else:
            sock.sendto(data, (host, port))
    
    return socket_writer

def send_syslog_message(message: str, socket_writer):
    data = message.encode('utf-8')
    socket_writer(data)

def main() -> None:
    args = parse_arguments()
    socket_writer = connect_to_syslog(args.host, args.port, args.tcp)
    formatted_message = format_syslog_message(args.facility, args.priority, args.message)
    send_syslog_message(formatted_message, socket_writer)

if __name__ == "__main__":
    main()
