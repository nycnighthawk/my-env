function MapToggle(key, opt)
  let cmd = ':set '.a:opt.'! \| set '.a:opt."?\<CR>"
  exec 'nnoremap '.a:key.' '.cmd
  exec 'inoremap '.a:key." \<C-O>".cmd
endfunction
set timeout timeoutlen=800 ttimeoutlen=250
nnoremap zh :let &hls=!&hls<CR>
inoremap kj <ESC>
if !has('nvim')
let mapleader=""
let maplocalleader=""
endif

if !has('nvim')
    if !has('gui_running')
        set <A-j>=j
        set <A-k>=k
    else
        if has('macunix')
            set <A-j>=<M-j>
            set <A-k>=<M-k>
        endif
    endif
else
    if has('gui_running') && has('macunix')
        " <A-j>
        nnoremap ∆ :m .+1<CR>
        "vnoremap ∆ :'<,'>m '>+1<CR>gv
        vnoremap ∆ :m '>+1<CR>gv
        " <A-k>
        nnoremap ˚ :m .-2<CR>
        "vnoremap ˚ :'<,'>m '<-2<CR>gv
        vnoremap ˚ :m '<-2<CR>gv
    endif
endif

nnoremap <A-j> :m .+1<CR>
nnoremap <A-k> :m .-2<CR>
vnoremap <A-j> :m '>+1<CR>gv
vnoremap <A-k> :m '<-2<CR>gv

let g:UltiSnipsExpandTrigger = "<leader><tab>"
let g:UltiSnipsListSnippets = "<leader>l"
let g:UltiSnipsJumpForwardTrigger = "<leader>j"
let g:UltiSnipsJumpBackwardTrigger = "<leader>k"
nnoremap <leader>:ur :UltiSnips#RfreshSnippets()<CR>
nnoremap <leader>:ua :UltiSnipsAddFiletypes<space>
"lnoremap <silent> <leader>e <esc>
"lnoremap <silent> <leader>E <esc>
"onoremap <silent> <leader>e <esc>
"onoremap <silent> <leader>E <esc>
"nnoremap <silent> <leader>e <esc>
"nnoremap <silent> <leader>E <esc>
vnoremap <silent> <leader>e <esc>
vnoremap <silent> <leader>E <esc>
inoremap <silent> <C-@>e <esc>
"inoremap <silent> <leader><space> \
"inoremap <silent> <leader><leader> \
inoremap <silent> <C-@>d <c-o>:call myvim_mylib#RemoveSinglePairedChar("d")<cr>
inoremap <silent> <C-Space>d <c-o>:call myvim_mylib#RemoveSinglePairedChar("d")<cr>
inoremap <silent> <C-@>b <c-o>:call myvim_mylib#RemoveSinglePairedChar("b")<cr>
inoremap <silent> <C-Space>b <c-o>:call myvim_mylib#RemoveSinglePairedChar("b")<cr>
inoremap <silent> <C-@>f" <esc>ciW"<c-r>""
inoremap <silent> <C-Space>f" <esc>ciW"<c-r>""
inoremap <silent> <C-@>f' <esc>ciW'<c-r>"'
inoremap <silent> <C-Space>f' <esc>ciW'<c-r>"'
inoremap <silent> <C-@>f` <esc>ciW`<c-r>"`
inoremap <silent> <C-Space>f` <esc>ciW`<c-r>"`
inoremap <silent> <C-@>f( <esc>ciW(<c-r>")
inoremap <silent> <C-Space>f( <esc>ciW(<c-r>")
inoremap <silent> <C-@>f[ <esc>ciW[<c-r>"]
inoremap <silent> <C-Space>f[ <esc>ciW[<c-r>"]
inoremap <silent> <C-@>f{ <esc>ciW{<c-r>"}
inoremap <silent> <C-Space>f{ <esc>ciW{<c-r>"}
inoremap <silent> <C-@>f< <esc>ciW<<c-r>">
inoremap <silent> <C-Space>f< <esc>ciW<<c-r>">
nnoremap <silent> <leader>f" ciW"<c-r>""<esc>
nnoremap <silent> <leader>f' ciW'<c-r>"'<esc>
nnoremap <silent> <leader>f` ciW`<c-r>"`<esc>
nnoremap <silent> <leader>f( ciW(<c-r>")<esc>
nnoremap <silent> <leader>f[ ciW[<c-r>"]<esc>
nnoremap <silent> <leader>f{ ciW(<c-r>"}<esc>
nnoremap <silent> <leader>f< ciW<<c-r>"><esc>
vnoremap <silent> <leader>f" c"<c-r>""<esc>
vnoremap <silent> <leader>f' c'<c-r>"'<esc>
vnoremap <silent> <leader>f` c`<c-r>"`<esc>
vnoremap <silent> <leader>f( c(<c-r>")<esc>
vnoremap <silent> <leader>f[ c[<c-r>"]<esc>
vnoremap <silent> <leader>f{ c{<c-r>"}<esc>
vnoremap <silent> <leader>f< c<<c-r>"><esc>
inoremap <silent> <C-@>E <esc>
tnoremap <silent> <C-@>e <c-w>N
tnoremap <silent> <C-Space>e <c-w>N
tnoremap <silent> <C-@>E <c-w>N
tnoremap <silent> <C-Space>E <c-w>N
call MapToggle('<F11>', 'ignorecase')
set pastetoggle=<F12>

if has('nvim')
    tnoremap <leader>e <c-\><c-n>
    tnoremap <leader>E <c-\><c-n>
    tnoremap <C-Space>e <c-\><c-n>
    tnoremap <C-Space>E <c-\><c-n>
    tnoremap kj <c-\><c-n>
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
else
    tnoremap kj <c-w>N
    tnoremap <leader>e <c-w>N
    tnoremap <leader>E <c-w>N
    tnoremap <c-space>E <c-w>N
    tnoremap <c-space>e <c-w>N
endif

inoremap <c-j> <C-O>gj
inoremap <c-k> <C-O>gk
noremap <c-j> gj
noremap <c-k> gk
vnoremap <c-j> gj
vnoremap <c-k> gk

" custom mapping for certain command
inoremap <silent> <C-@>fcg :exec 'CocList --input='.expand('<cword>').' grep'<CR>
inoremap <silent> <C-Space>fcg :exec 'CocList --input='.expand('<cword>').' grep'<CR>
nnoremap <silent> <leader>fcg :exec 'CocList --input='.expand('<cword>').' grep'<CR>
"inoremap <silent> <localleader>ap  <C-R>=AutoPairsToggle()<CR>
nnoremap <silent> <localleader>ap  :call AutoPairsToggle()<CR>
