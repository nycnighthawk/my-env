function MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  exec 'inoremap '.a:key." \<C-O>".cmd
endfunction

set timeoutlen=800
nnoremap zh :let &hls=!&hls<CR>
inoremap kj <ESC>
let mapleader="\\"

let g:UltiSnipsExpandTrigger = "<leader><tab>"
let g:UltiSnipsListSnippets = "<leader>l"
let g:UltiSnipsJumpForwardTrigger = "<leader>j"
let g:UltiSnipsJumpBackwardTrigger = "<leader>k"
nnoremap <leader>:ur :UltiSnips#RfreshSnippets()<CR>
nnoremap <leader>:ua :UltiSnipsAddFiletypes<space>
lnoremap <silent> <leader>e <esc>
lnoremap <silent> <leader>E <esc>
onoremap <silent> <leader>e <esc>
onoremap <silent> <leader>E <esc>
nnoremap <silent> <leader>e <esc>
nnoremap <silent> <leader>E <esc>
vnoremap <silent> <leader>e <esc>
vnoremap <silent> <leader>E <esc>
inoremap <silent> <leader>e <esc>
"inoremap <silent> <leader><space> \
inoremap <silent> <leader><leader> \
inoremap <silent> <leader>d <c-o>:call myvim_mylib#RemoveSinglePairedChar("d")<cr>
inoremap <silent> <leader>b <c-o>:call myvim_mylib#RemoveSinglePairedChar("b")<cr>
inoremap <silent> <leader>f" <esc>ciW"<c-r>""
inoremap <silent> <leader>f' <esc>ciW'<c-r>"'
inoremap <silent> <leader>f` <esc>ciW`<c-r>"`
inoremap <silent> <leader>f( <esc>ciW(<c-r>")
inoremap <silent> <leader>f[ <esc>ciW[<c-r>"]
inoremap <silent> <leader>f{ <esc>ciW{<c-r>"}
nnoremap <silent> <leader>f" ciW"<c-r>""<esc>
nnoremap <silent> <leader>f' ciW'<c-r>"'<esc>
nnoremap <silent> <leader>f` ciW`<c-r>"`<esc>
nnoremap <silent> <leader>f( ciW(<c-r>")<esc>
nnoremap <silent> <leader>f[ ciW[<c-r>"]<esc>
nnoremap <silent> <leader>f{ ciW(<c-r>"}<esc>
vnoremap <silent> <leader>f" c"<c-r>""<esc>
vnoremap <silent> <leader>f' c'<c-r>"'<esc>
vnoremap <silent> <leader>f` c`<c-r>"`<esc>
vnoremap <silent> <leader>f( c(<c-r>")<esc>
vnoremap <silent> <leader>f[ c[<c-r>"]<esc>
vnoremap <silent> <leader>f{ c{<c-r>"}<esc>
inoremap <silent> <leader>E <esc>
tnoremap <silent> <leader>e <c-w>N
tnoremap <silent> <leader>E <c-w>N
call MapToggle('<F11>', 'ignorecase')
set pastetoggle=<F12>

if has('nvim')
    tnoremap <leader>e <c-\><c-n>
    tnoremap <c-w>j <c-\><c-n><c-w>j
    tnoremap <c-w>h <c-\><c-n><c-w>h
    tnoremap <c-w>k <c-\><c-n><c-w>k
    tnoremap <c-w>h <c-\><c-n><c-w>h
    tnoremap <c-w>N <c-\><c-n>
    tnoremap <c-w>"a <c-\><c-n>"api<cr>
    tnoremap <c-w>"b <c-\><c-n>"bpi<cr>
    tnoremap <c-w>"c <c-\><c-n>"cpi<cr>
    tnoremap <c-w>"d <c-\><c-n>"dpi<cr>
    tnoremap <c-w>"e <c-\><c-n>"epi<cr>
    tnoremap <c-w>"f <c-\><c-n>"fpi<cr>
    tnoremap <c-w>"g <c-\><c-n>"gpi<cr>
    tnoremap <c-w>"h <c-\><c-n>"hpi<cr>
    tnoremap <c-w>"i <c-\><c-n>"ipi<cr>
    tnoremap <c-w>"j <c-\><c-n>"jpi<cr>
    tnoremap <c-w>"k <c-\><c-n>"kpi<cr>
    tnoremap <c-w>"l <c-\><c-n>"lpi<cr>
    tnoremap <c-w>"m <c-\><c-n>"mpi<cr>
    tnoremap <c-w>"n <c-\><c-n>"npi<cr>
    tnoremap <c-w>"o <c-\><c-n>"opi<cr>
    tnoremap <c-w>"p <c-\><c-n>"ppi<cr>
    tnoremap <c-w>"q <c-\><c-n>"qpi<cr>
    tnoremap <c-w>"r <c-\><c-n>"rpi<cr>
    tnoremap <c-w>"s <c-\><c-n>"spi<cr>
    tnoremap <c-w>"t <c-\><c-n>"tpi<cr>
    tnoremap <c-w>"u <c-\><c-n>"upi<cr>
    tnoremap <c-w>"v <c-\><c-n>"vpi<cr>
    tnoremap <c-w>"w <c-\><c-n>"wpi<cr>
    tnoremap <c-w>"x <c-\><c-n>"xpi<cr>
    tnoremap <c-w>"y <c-\><c-n>"ypi<cr>
    tnoremap <c-w>"z <c-\><c-n>"zpi<cr>
    tnoremap <c-w>"+ <c-\><c-n>"+pi<cr>
    tnoremap <c-w>"0 <c-\><c-n>"0pi<cr>
    tnoremap <c-w>"1 <c-\><c-n>"1pi<cr>
    tnoremap <c-w>"2 <c-\><c-n>"2pi<cr>
    tnoremap <c-w>"3 <c-\><c-n>"3pi<cr>
    tnoremap <c-w>"4 <c-\><c-n>"4pi<cr>
    tnoremap <c-w>"5 <c-\><c-n>"5pi<cr>
    tnoremap <c-w>"6 <c-\><c-n>"6pi<cr>
    tnoremap <c-w>"7 <c-\><c-n>"7pi<cr>
    tnoremap <c-w>"8 <c-\><c-n>"8pi<cr>
    tnoremap <c-w>"9 <c-\><c-n>"9pi<cr>
endif

inoremap <c-j> <C-O>gj
inoremap <c-h> <left>
inoremap <c-k> <C-O>gk
inoremap <c-l> <right>
noremap <c-j> gj
noremap <c-k> gk
noremap <c-h> h
noremap <c-l> l
vnoremap <c-j> gj
vnoremap <c-k> gk
vnoremap <c-h> <left>
vnoremap <c-l> <right>

" custom mapping for certain command
inoremap <silent> <leader>fcg :exec 'CocList --input='.expand('<cword>').' grep'<CR>
nnoremap <silent> <leader>fcg :exec 'CocList --input='.expand('<cword>').' grep'<CR>
