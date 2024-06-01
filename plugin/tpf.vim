if !has('vim9script') ||  v:version < 900
    " Needs Vim version 9.0 and above
    finish
endif
vim9script
import autoload 'tpf.vim'
command! -nargs=? -bar Tpf call tpf#Open(<f-args>)
