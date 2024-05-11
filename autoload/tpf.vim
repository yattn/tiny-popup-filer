function! s:name(base, v) abort
	let l:type = a:v['type']
	if l:type ==# 'link' || l:type ==# 'junction'
		if isdirectory(resolve(a:base .. a:v['name']))
			let l:type = 'dir'
		endif
	elseif l:type ==# 'linkd'
		let l:type = 'dir'
	endif
	return a:v['name'] .. (l:type ==# 'dir' ? '/' : '')
endfunction

function! s:init() abort
endfunction

function! s:down(ctx,id) abort

	call popup_close(a:id)
	let a:ctx.curdir .= a:ctx.files[a:ctx.idx]
	let l:dir = a:ctx.files[a:ctx.idx].'/'
	let a:ctx.files = map(readdirex(a:ctx.curdir, '1', {'sort': 'collate'}), {_, v -> s:name(l:dir, v)})
	let a:ctx.idx = 0

   call popup_menu(a:ctx.files, {
                \ 'filter': function('s:filter', [a:ctx])
                \ })
   return 1
endfunction

function! s:up(ctx,id) abort

	call popup_close(a:id)
	let a:ctx.curdir = substitute(a:ctx.curdir, '/$', '', '')
	let a:ctx.curdir = fnamemodify(a:ctx.curdir, ':p:h:h:gs!\!/!') . '/'
	let l:dir = a:ctx.curdir
	let a:ctx.files = map(readdirex(a:ctx.curdir, '1', {'sort': 'collate'}), {_, v -> s:name(l:dir, v)})
	let a:ctx.idx = 0

	" popupを生成する
	" popupのコントロールはs:filterで行う
   call popup_menu(a:ctx.files, {
                \ 'filter': function('s:filter', [a:ctx])
                \ })
   return 1
endfunction

function! s:filter(ctx, id, key) abort

	if a:key is# "\<left>" || a:key is# "h" || a:key is# "-"
		return s:up(a:ctx,a:id)
	endif

	if a:key is# "\<cr>"
		if empty(a:ctx.files)
			return s:up(a:ctx,a:id)
		elseif !isdirectory(a:ctx.curdir . a:ctx.files[a:ctx.idx])
			return s:edit(a:id, 'e',a:ctx.curdir . a:ctx.files[a:ctx.idx])
		else
			return s:down(a:ctx,a:id)
		endif
	endif

	if !empty(a:ctx.files)
		if a:key is# "\<right>" || a:key is# "l"
			if isdirectory(a:ctx.curdir . a:ctx.files[a:ctx.idx])
				return s:down(a:ctx,a:id)
			endif
		endif
	
		if a:key is# "\<up>" || a:key is# "k"
			if a:ctx.idx > 0
				let a:ctx.idx = a:ctx.idx - 1
			else
				let a:ctx.idx = len(a:ctx.files) -1
			endif
		elseif a:key is# "\<down>" || a:key is# "j"
			if a:ctx.idx < len(a:ctx.files) -1
				let a:ctx.idx = a:ctx.idx + 1
			else
				let a:ctx.idx = 0
			endif
		endif
	endif
	
	" popup上の表示とidxが指すfileは別物
	" 表示と内部状態に剥離がないように
	" フィルタ操作(表示上の移動)を行う
	return popup_filter_menu(a:id, a:key)

endfunction

function! s:edit(id, open, filepath) abort
	call popup_close(a:id)
	execute a:open a:filepath
	return 1
endfunction

function! tpf#open() abort
	let l:ctx = {
				\ 'idx': 0,
				\ 'files': [],
				\ 'curdir': [],
				\ }

	let l:path = expand('.')
	let l:dir = fnamemodify(l:path, ':p:gs!\!/!')
	if isdirectory(l:dir) && l:dir !~# '/$'
		let l:dir .= '/'
	endif
	let l:ctx.curdir = l:dir

	let l:ctx.files = map(readdirex(l:path, '1', {'sort': 'collate'}), {_, v -> s:name(l:dir, v)})

   call popup_menu(l:ctx.files, {
                \ 'filter': function('s:filter', [l:ctx])
                \ })
endfunction

