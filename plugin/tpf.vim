if exists('g:loaded_tpf')
    finish
endif
if !has('vim9script')
    echoerr 'Needs Vim version 9.0 and above'
    finish
endif
vim9script

g:loaded_tpf = true

command! -nargs=? -complete=dir -bar Tpf call tpf#Open(<f-args>)
