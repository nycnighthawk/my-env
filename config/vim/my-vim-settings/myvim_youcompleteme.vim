let g:ycm_server_python_interpreter = $HOME . '\bin\python.org\3.7.6\python.exe'
let g:ycm_confirm_extra_conf = 0
let g:ycm_collect_identifiers_from_tags_files = 1
let g:ycm_add_preview_to_completeopt = 1
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_use_ultisnips_completer = 1 " Default 1, just ensure
let g:ycm_seed_identifiers_with_syntax = 1 " Completion for programming language's keyword
let g:ycm_complete_in_comments = 1 " Completion in comments
let g:ycm_complete_in_strings = 1 " Completion in string
let g:ycm_key_list_select_completion = ['<C-j>', '<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-k>', '<C-p>', '<Up>']
let g:ycm_key_invoke_completion = '<C-Space>'
let g:ycm_python_interpreter_path = ''
let g:ycm_python_sys_path = []
let g:ycm_extra_conf_vim_data = [
  \  'g:ycm_python_interpreter_path',
  \  'g:ycm_python_sys_path',
  \  'g:ycm_server_python_interpreter'
  \]
"let g:ycm_global_ycm_extra_conf = '~/global_extra_conf.py'
let g:ycm_global_ycm_extra_conf = '~/.global_config_ycm.py'
let g:ycm_disable_for_files_larger_than_kb = 5000
map <F3> :YcmCompleter GoTo<CR>
"
"
"
" let g:Lf_PythonVersion = 2
" nmap <F8> :LeaderfBufTag<CR>
