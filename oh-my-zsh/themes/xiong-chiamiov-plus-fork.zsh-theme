# user, host, full path, and time/date
# on two lines for easier vgrepping
# entry in a nice long thread on the Arch Linux forums: https://bbs.archlinux.org/viewtopic.php?pid=521888#p521888
my_git_prompt() {
    _color='%{\e[0;34m%}%B'
    _git_prompt=$(git_prompt_info)
    if [ -z "${_git_prompt}" ]
    then
        final_git_prompt=""
    else
        final_git_prompt=" - ${_color}<${_git_prompt}>"
    fi
    echo "${final_git_prompt}"
}

venv_prompt() {
    if [ -z "${VIRTUAL_ENV}" ]
    then
        final_virt_prompt=""
    else
        final_virt_prompt=" - (venv:$(basename ${VIRTUAL_ENV}))"
    fi
    echo "${final_virt_prompt}"
}
PROMPT=$'%{\e[0;34m%}%B┌─[%b%{\e[0m%}%{\e[1;32m%}%n%{\e[1;30m%}@%{\e[0m%}%{\e[0;36m%}%m%{\e[0;34m%}%B]%b%{\e[0m%} - %{\e[0;34m%}%B[%b%{\e[0;33m%}'%D{"%a %b %d, %H:%M"}%b$'%{\e[0;34m%}%B]%b%{\e[0m%}$(venv_prompt)$(my_git_prompt)
%{\e[0;34m%}%B│ %b%{\e[0;34m%}%B[%b%{\e[1;37m%}%~%{\e[0;34m%}%B]%b%{\e[0m%}
%{\e[0;34m%}%B└─%B%{\e[1;35m%}$%{\e[0;34m%}%B %{\e[0m%}%b'
PS2=$' \e[0;34m%}%B>%{\e[0m%}%b'
