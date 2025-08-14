augroup Buffer
    autocmd!
    autocmd BufWrite <buffer> silent! :call CocAction('runCommand', 'python.sortImports')
    autocmd BufWrite <buffer> silent! :call CocAction('format')
augroup END
