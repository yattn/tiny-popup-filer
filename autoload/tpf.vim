vim9script

var prevdir = '.'

def Name(base: string, v: dict<any>): string
    var type = v['type']
    if type ==# 'link' || type ==# 'junction'
        if isdirectory(resolve(base .. v['name']))
            type = 'dir'
        endif
    elseif type ==# 'linkd'
        type = 'dir'
    endif
    return v['name'] .. (type ==# 'dir' ? '/' : '')
enddef

def Show(ctx: dict<any>): void
    ctx.files = map(readdirex(ctx.curdir, '1', {'sort': 'collate'}), (_, v): string => Name(ctx.curdir, v))
    popup_menu(ctx.files, {
        'filter': funcref('Filter', [ctx]),
        'callback': funcref('OnSelect', [ctx]),
        'scrollbar': 0,
        'minwidth': &columns / 2,
        'maxheight': &lines / 2
    })
enddef

def Descend(ctx: dict<any>, name: string): void
    ctx.curdir ..= name
    Show(ctx)
enddef

def Up(ctx: dict<any>, id: number): bool
    popup_close(id)
    var dir = substitute(ctx.curdir, '/\+$', '', '')
    if dir !=# ''
        var parent = fnamemodify(dir, ':h')
        ctx.curdir = parent ==# '/' ? '/' : parent .. '/'
    endif
    Show(ctx)
    return true
enddef

# 選択位置は popup のハイライトだけを見て、ctx 側では持たない。
# 二重管理すると popup_filter_menu の操作 (C-N/C-P/Space/マウス等) とずれるため。
def Selected(ctx: dict<any>, id: number): string
    if empty(ctx.files)
        return ''
    endif
    var idx = line('.', id) - 1
    if idx < 0 || idx >= len(ctx.files)
        return ''
    endif
    return ctx.files[idx]
enddef

def Filter(ctx: dict<any>, id: number, key: string): bool
    if key ==# "\<left>" || key ==# 'h' || key ==# '-'
        return Up(ctx, id)
    endif

    if key ==# "\<cr>" && empty(ctx.files)
        return Up(ctx, id)
    endif

    if key ==# "\<right>" || key ==# 'l'
        var name = Selected(ctx, id)
        if name !=# '' && isdirectory(ctx.curdir .. name)
            popup_close(id)
            Descend(ctx, name)
            return true
        endif
    endif

    if key ==# 'c'
        var target = Selected(ctx, id)
        if target !=# '' && isdirectory(ctx.curdir .. target)
            execute 'cd' fnameescape(ctx.curdir .. target)
        endif
        return true
    endif

    return popup_filter_menu(id, key)
enddef

def OnSelect(ctx: dict<any>, id: number, result: number): void
    if result <= 0
        return
    endif
    var name = ctx.files[result - 1]
    if isdirectory(ctx.curdir .. name)
        Descend(ctx, name)
    else
        prevdir = ctx.curdir
        execute 'edit' fnameescape(ctx.curdir .. name)
    endif
enddef

export def Open(curpath = ''): void
    if curpath !=# ''
        prevdir = curpath
    endif

    var path = expand(prevdir)
    if !isdirectory(path)
        path = fnamemodify(path, ':h')
    endif

    var ctx: dict<any> = {
        'files': [],
        'curdir': fnamemodify(path, ':p')
    }
    Show(ctx)
enddef
