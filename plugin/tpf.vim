if !has('vim9script') ||  v:version < 900
    echoerr 'Needs Vim version 9.0 and above'
    finish
endif
vim9script

g:loaded_tpf = true

import autoload '../autoload/tpf.vim'
