runtime my-vim-settings/myvim_settings.vim
runtime my-vim-settings/myvim_filetype.vim
runtime my-vim-settings/myvim_keymap.vim
" ---------------------------------
"  python language server
" ---------------------------------

runtime my-vim-settings/myvim_mylib.vim
if has('nvim')
    set termguicolors
    silent! colorscheme tokyonight-night
else
    if exists('+termguicolors')
        set termguicolors
    endif
    let g:doom_one_terminal_colors = v:true
    silent! colorscheme doom-one
endif
if !has('nvim')
    fun! MyvimInstallPlugins()
        echo "Installing Plugins..."
        PlugInstall
        quitall!
    endfun
    fun! MyvimUpdatePlugins()
        echo "Updating Plugins..."
        PlugUpdate
        quitall!
    endfun
    fun! MyvimUpdateCoc()
        echo "Updating Coc..."
        CocUpdateSync
        quitall!
    endfun
endif
