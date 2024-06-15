set nocompatible              " be iMproved, required
set ff=unix
set encoding=utf-8
if !has('nvim')
filetype off                  " required
endif
" ++++++++++++++++++++ force specific python3 executable +++++++++++++++++++++
" if has('nvim') && has('win32')
"   let g:python3_host_prog = $USERPROFILE.'/bin/python.org/3.10/python.exe'
" elseif has('nvim') && has('linux')
"   let g:python3_host_prog = '/opt/python/3.8/bin/python'
" endif
" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
"
" if !has('nvim')
"    py3 import sys; import pathlib; import os; sys.path.insert(0, str(pathlib.Path(os.environ['VIMPYTHON']).parent / 'lib/site-packages'))
" endif
set fileencoding=utf-8
set viminfo=""
if has('win32')
  set viewdir=~/vimfiles/view
else
  set viewdir=~/.vim/view
endif
set ignorecase
set smartcase
set wildmode=full
set wildmenu
set hidden

" set the python3 location
" set pythonthreehome=~/bin/python.org/3.9
" set pythonthreedll=~/bin/python.org/3.9/python39.dll
" set the runtime path to include Vundle and initialize
"
" ++++++++++++++++++++++ force specific python3 dll ++++++++++++++++++++++++++
" if !has('nvim') && has('win32')
"     "set pythonthreehome=C:\\Users\\hchen1\\bin\\python.org\\3.9
"     "set pythonthreedll=C:\\Users\\hchen1\\bin\\python.org\\3.9\\python39.dll
"     let &pythonthreedll = $USERPROFILE.'/bin/python.org/3.9/python39.dll'
" endif
" ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
set smarttab
set expandtab
set incsearch
set shiftwidth=4
set ts=4
set sts=4
set number
set numberwidth=5
let $GIT_SSL_NO_VERIFY = 'true'
set showtabline=2
set laststatus=2

"let g:deoplete#enable_at_startup = 1
set backspace=indent,eol,start
"set preserveindent
set copyindent
"set nohlsearch
set nobackup
set showmatch
set wrap
set splitbelow
set splitright
