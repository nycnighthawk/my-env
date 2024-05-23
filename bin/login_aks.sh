#!/bin/bash
#
if [ ! -d ~/.azcli ]
then
    echo "$(date '+%y-%m-%d %H:%M:%S') Installing Azure Cli, please wait ..."
    ~/bin/update-azcli || $(echo "Installation failed!, abort" && exit 1)
    echo "$(date '+%y-%m-%d %H:%M:%S') Azure Cli installation done."
fi
interactive_shell=/bin/bash
if [ -f /bin/zsh ]
then
    interactive_shell=/bin/zsh
fi
unset MY_PATH_INIT
cat > ${HOME}/.my_env_onetime_only << END
export MY_ADDITIONAL_SOURCES="${MY_ADDITIONAL_SOURCES} ${HOME}/.azcli/bin/activate ${HOME}/bin/azcli_login.sh"
END
exec ${interactive_shell}
