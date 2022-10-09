#! bash oh-my-bash.module
SCM_THEME_PROMPT_PREFIX=""
SCM_THEME_PROMPT_SUFFIX=""

SCM_THEME_PROMPT_DIRTY=" ${_omb_prompt_bold_brown}✗${_omb_prompt_normal}"
SCM_THEME_PROMPT_CLEAN=" ${_omb_prompt_bold_green}✓${_omb_prompt_normal}"
SCM_GIT_CHAR="${_omb_prompt_bold_green}±${_omb_prompt_normal}"
SCM_SVN_CHAR="${_omb_prompt_bold_teal}⑆${_omb_prompt_normal}"
SCM_HG_CHAR="${_omb_prompt_bold_brown}☿${_omb_prompt_normal}"

#Mysql Prompt
export MYSQL_PS1="(\u@\h) [\d]> "

case $TERM in
        xterm*)
        TITLEBAR="\[\033]0;\w\007\]"
        ;;
        *)
        TITLEBAR=""
        ;;
esac

PS3=">> "

__my_rvm_ruby_version() {
    local gemset=$(echo $GEM_HOME | awk -F'@' '{print $2}')
  [ "$gemset" != "" ] && gemset="@$gemset"
    local version=$(echo $MY_RUBY_HOME | awk -F'-' '{print $2}')
    local full="$version$gemset"
  [ "$full" != "" ] && echo "[$full]"
}

is_vim_shell() {
        if [ ! -z "$VIMRUNTIME" ]
        then
                echo "[${_omb_prompt_teal}vim shell${_omb_prompt_normal}]"
        fi
}

modern_scm_prompt() {
        CHAR=$(scm_char)
        if [ $CHAR = $SCM_NONE_CHAR ]
        then
                return
        else
                echo "[$(scm_char)][$(scm_prompt_info)]"
        fi
}

# show chroot if exist
chroot(){
    if [ -n "$debian_chroot" ]
    then 
        my_ps_chroot="${_omb_prompt_bold_teal}$debian_chroot${_omb_prompt_normal}";
        echo "($my_ps_chroot)";
    fi
    }

# show virtualenvwrapper
my_ve(){
    if [ -n "$VIRTUAL_ENV" ]
    then 
        my_ps_ve="${_omb_prompt_bold_purple}$ve${_omb_prompt_normal}";
        echo "($my_ps_ve)";
    fi
    echo "";
    }

date_prompt() {
    _d=$(date +"%Y-%m-%d %H:%M")
    echo "${_d}"
}

# yellow
_my_prompt_color='\[\e[0;33m\]'
# blue
_my_blue_color='\[\e[1;34m\]'

_omb_theme_PROMPT_COMMAND() {

    # my_ps_host="${_omb_prompt_green}\h $(date_prompt)${_omb_prompt_normal}";
    my_ps_host="${_my_prompt_color}\h $(date_prompt)${_omb_prompt_normal}";
    # yes, these are the the same for now ...
    # my_ps_host_root="${_omb_prompt_green}\h $(date_prompt)${_omb_prompt_normal}";
    my_ps_host_root="${_my_prompt_color}\h $(date_prompt)${_omb_prompt_normal}";
 
    # my_ps_user="${_omb_prompt_bold_green}\u@${_omb_prompt_normal}"
    my_ps_user="${_my_prompt_color}\u@${_omb_prompt_normal}"
    # my_ps_root="${_omb_prompt_bold_brown}\u@${_omb_prompt_normal}";
    my_ps_root="${_my_prompt_color}\u@${_omb_prompt_normal}";

    if [ -n "$VIRTUAL_ENV" ]
    then
        ve=`basename $VIRTUAL_ENV`;
    fi

    # nice prompt
    case "`id -u`" in
        0) PS1="${TITLEBAR}${_my_blue_color}┌─${_omb_prompt_normal}$(my_ve)$(chroot)${_my_blue_color}[$my_ps_user$my_ps_host_root${_my_blue_color}]$(modern_scm_prompt)$(__my_rvm_ruby_version)$(is_vim_shell)
${_my_blue_color}│ [${_omb_prompt_normal}\w${_my_blue_color}]
${_my_blue_color}└─#${_omb_prompt_normal} "
        ;;
        *) PS1="${TITLEBAR}${_my_blue_color}┌─${_omb_prompt_normal}$(my_ve)$(chroot)${_my_blue_color}[$my_ps_user$my_ps_host${_my_blue_color}]$(modern_scm_prompt)$(__my_rvm_ruby_version)$(is_vim_shell)
${_my_blue_color}│ [${_omb_prompt_normal}\w${_my_blue_color}] 
${_my_blue_color}└─\$${_omb_prompt_normal} "
        ;;
    esac
}

PS2="└─$ "

_omb_util_add_prompt_command _omb_theme_PROMPT_COMMAND
