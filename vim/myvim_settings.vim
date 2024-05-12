set spellfile=~/.vim/spell/en.utf-8.add
"source ~/.vim/myvim_ultisnips.vim
"source ~/.vim/myvim_youcompleteme.vim
"source ~/.vim/myvim_deoplete-jedi.vim
" -------------------------------------------
"  change search highlight
" -------------------------------------------
hi Search term=reverse ctermfg=0 ctermbg=14 guifg=#000000 guibg=#f1dd38

" -------------------------------------------
"  change all file type encoding
" -------------------------------------------
" augroup myag_all_files
"     autocmd!
"     autocmd BufWritePre * setl encoding=utf8
"     autocmd BufWritePre * setl ff=unix
" augroup END

" change syntax sync minlines to 20,000, should be good for most cases
syntax sync minlines=20000
