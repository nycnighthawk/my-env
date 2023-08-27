augroup Buffer
    autocmd!
    autocmd BufWrite <buffer> silent! execute "call CocAction('format')" 
augroup END
