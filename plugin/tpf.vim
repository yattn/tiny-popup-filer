if exists('g:loaded_tpf')
  finish
endif
let g:loaded_tpf = 1

command! Tpf call tpf#open()

