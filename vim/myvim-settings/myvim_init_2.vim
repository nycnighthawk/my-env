runtime myvim-settings/myvim_settings.vim
runtime myvim-settings/myvim_filetype.vim
runtime myvim-settings/myvim_keymap.vim
" ---------------------------------
"  python language server
" ---------------------------------
if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

runtime myvim-settings/myvim_mylib.vim
if has('nvim')
    set termguicolors
elseif exists('+termguicolors')
    set termguicolors
endif
let g:doom_one_terminal_colors = v:true
silent! colorscheme doom-one
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
