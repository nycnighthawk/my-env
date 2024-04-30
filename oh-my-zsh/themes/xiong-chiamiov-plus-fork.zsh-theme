# user, host, full path, and time/date
# on two lines for easier vgrepping
# entry in a nice long thread on the Arch Linux forums: https://bbs.archlinux.org/viewtopic.php?pid=521888#p521888
_my_blue_color=$'%{\e[1;34m%}'
_my_yellow_color=$'%{\e[0;33m%}'
_my_purple_color=$'%{\e[1;35m%}'
_my_green_color=$'%{\e[1;32m%}'
_my_gray_color=$'%{\e[1;30m%}'
_my_light_blue_color=$'%{\e[0;36m%}'
_normal=$'%{\e[0m%}%b'
_mytheme_git_prompt() {
    ret=$(command -v git >/dev/null 2>&1 && git symbolic-ref --quiet --short HEAD 2>/dev/null)
    echo "${ret}"
}
my_git_prompt() {
    _git_prompt=$(_mytheme_git_prompt)
    if [ -z "${_git_prompt}" ]
    then
        final_git_prompt=""
    else
        final_git_prompt="${_my_blue_color}[${_my_light_blue_color}%Bgit:${_git_prompt}${_my_blue_color}]"
    fi
    echo "${final_git_prompt}"
}

venv_prompt() {
    if [ -z "${VIRTUAL_ENV}" ]
    then
        final_virt_prompt=""
    else
        final_virt_prompt="${_my_blue_color}[${_normal}%Bvenv:$(basename ${VIRTUAL_ENV})${_my_blue_color}]"
    fi
    echo "${final_virt_prompt}"
}


PROMPT=$'${_my_blue_color}%B┌─[${_my_green_color}%n${_my_gray_color}@${_my_light_blue_color}%m${_my_blue_color}%B][%b${_my_yellow_color}%D{%a %b %d, %H:%M}${_my_blue_color}%B]$(venv_prompt)$(my_git_prompt)${_my_blue_color}%B
│ [${_normal}%B%~${_my_blue_color}%B]
└─${_my_purple_color}%B$ ${_normal}'
PS2=$' ${_my_blue_color}%B> ${_normal}'
