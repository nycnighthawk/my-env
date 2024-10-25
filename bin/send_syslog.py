#!/usr/bin/env python3
import argparse
import socket
import os
from datetime import datetime

FACILITY = {
    "kern": 0, "user": 1, "mail": 2, "daemon": 3, "auth": 4, "syslog": 5, "lpr": 6, "news": 7,
    "uucp": 8, "cron": 9, "authpriv": 10, "ftp": 11, "ntp": 12, "audit": 13, "alert": 14, "clock": 15,
    "local0": 16, "local1": 17, "local2": 18, "local3": 19, "local4": 20, "local5": 21, "local6": 22, "local7": 23
}

PRIORITY = {
    "emerg": 0, "alert": 1, "crit": 2, "err": 3, "warn": 4, "notice": 5, "info": 6, "debug": 7
}

def parse_arguments() -> dict:
    parser = argparse.ArgumentParser(description="Send a syslog message.")
    parser.add_argument("--server", type=str, default="127.0.0.1", help="The server name or IP address.")
    parser.add_argument("--protocol", type=str, choices=["udp", "tcp"], default='udp', help="The protocol to use (udp or tcp), default udp.")
    parser.add_argument("--facility", type=str, default="local6", help="The syslog facility, default local6.")
    parser.add_argument("--priority", type=str, default="info", help="The syslog priority, default info.")
    parser.add_argument("--message", type=str, default=f"{os.getuid()} {os.getlogin()}: test hello world!", help="The message to send.")
    return vars(parser.parse_args())

def format_syslog_message(facility: str, priority: str, message: str, app_name: str = "-", procid: str = "-", msgid: str = "-", bsd_format: bool = False) -> str:
    facility_code = FACILITY.get(facility)
    priority_code = PRIORITY.get(priority)
    
    if facility_code is None or priority_code is None:
        raise ValueError("Invalid facility or priority")

    pri = (facility_code * 8) + priority_code
    hostname = socket.gethostname()
    
    if bsd_format:
        timestamp = datetime.now().strftime("%b %d %H:%M:%S")
        return f"<{pri}> {timestamp} {hostname} {app_name}: {message}"
    else:
        timestamp = datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%fZ")[:-3]
        return f"<{pri}>1 {timestamp} {hostname} {app_name} {procid} {msgid} - {message}"


def send_syslog_message(server: str, protocol: str, message: str) -> None:
    if protocol == "udp":
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    else:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((server, 514))
    
    if protocol == "udp":
        sock.sendto(message.encode(), (server, 514))
    else:
        sock.sendall(message.encode())
    
    sock.close()

def main() -> None:
    args = parse_arguments()
    formatted_message = format_syslog_message(args["facility"], args["priority"], args["message"])
    send_syslog_message(args["server"], args["protocol"], formatted_message)

if __name__ == "__main__":
    main()
