#!/usr/bin/expect --

if {$argc != 1} {
    send_user "usage:\n"
    send_user "atc host\n"
    exit
}
set username hchen
set password d98cce33
set count 0
set host [lindex $argv 0]
set timeout 15
set use_telnet 1
log_user 0
spawn ssh -l $username $host
expect {
    -nocase -re "ssword: *$" {
        send "$password\r"
        incr count
        if {$count == 2} {
            send_user "Please check your password\n"
            exit
        }
        exp_continue
    }
    -nocase -re "# *$" {
        log_user 1
        send "\r"
        send_user "You have logged into $host via ssh\n"
        interact
        set use_telnet 0
    }
    -nocase -re "> *$" {
        log_user 1
        send "\r"
        send_user "You would need to enter enable password\n"
        interact
        set use_telnet 0
    }
    timeout {
        send_user "try telnet instead\n"
    }
}

log_user 0
if {$use_telnet == 1} {
    spawn telnet $host
    set count 0
    expect {
        -nocase -re "name: *$" {
            send "$username\r"
            exp_continue
        }
        -nocase -re "ssword: *$" {
            send "$password\r"
            incr count
            if {$count == 2} {
                send_user "Please check your password\n"
                exit
            }
            exp_continue
        }
        -nocase -re "# *$" {
            log_user 1
            send "\r"
            send_user "You have logged in $host via telnet\n"
            interact
        }
        -nocase -re "> *$" {
            log_user 1
            send "\r"
            send_user "You would need to enter enable password\n"
            interact
            set use_telnet 0
        }
        timeout {
            send_user "timeout!"
            exit
        }
    }
}
