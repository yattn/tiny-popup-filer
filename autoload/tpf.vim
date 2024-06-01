vim9script

var popup_min_width = 0
var popup_max_height = 0

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

def Down(ctx: dict<any>, id: number): bool
    popup_close(id)
    ctx.curdir ..= ctx.files[ctx.idx]
    var dir = ctx.files[ctx.idx] .. '/'
    ctx.files = map(readdirex(ctx.curdir, '1', {'sort': 'collate'}), (_, v): string => Name(dir, v))
    ctx.idx = 0
    popup_menu(ctx.files, {
        'filter': funcref('Filter', [ctx]),
        'scrollbar': 0,
        'minwidth': popup_min_width,
        'maxheight': popup_max_height
    })
    return 1
enddef

def Up(ctx: dict<any>, id: number): bool
    popup_close(id)
    ctx.curdir = substitute(ctx.curdir, '/$', '', '')
    ctx.curdir = fnamemodify(ctx.curdir, ':p:h:h:gs!\/!') .. '/'
    ctx.files = map(readdirex(ctx.curdir, '1', {'sort': 'collate'}), (_, v): string => Name(ctx.curdir, v))
    ctx.idx = 0
    popup_menu(ctx.files, {
        'filter': funcref('Filter', [ctx]),
        'scrollbar': 0,
        'minwidth': popup_min_width,
        'maxheight': popup_max_height
    })
    return 1
enddef

def Filter(ctx: dict<any>, id: number, key: string): bool

    if key ==# "\<left>" || key ==# "h" || key ==# "-"
        return Up(ctx, id)
    endif

    if key ==# "c"
        if isdirectory(ctx.curdir .. ctx.files[ctx.idx])
            return Edit(id, 'cd', ctx.curdir .. ctx.files[ctx.idx])
        else
            echoerr ctx.files[ctx.idx] .. " is not directory"
        endif
    endif

    if key ==# "\<cr>"
        if empty(ctx.files)
            return Up(ctx, id)
        elseif !isdirectory(ctx.curdir .. ctx.files[ctx.idx])
            return Edit(id, 'e', ctx.curdir .. ctx.files[ctx.idx])
        else
            return Down(ctx, id)
        endif
    endif
    if !empty(ctx.files)
        if key ==# "\<right>" || key ==# "l"
            if isdirectory(ctx.curdir .. ctx.files[ctx.idx])
                return Down(ctx, id)
            endif
        endif

        if key ==# "\<up>" || key ==# "k"
            if ctx.idx > 0
                ctx.idx -= 1
            else
                ctx.idx = len(ctx.files) - 1
            endif
        elseif key ==# "\<down>" || key ==# "j"
            if ctx.idx < len(ctx.files) - 1
                ctx.idx += 1
            else
                ctx.idx = 0
            endif
        endif
    endif

    return popup_filter_menu(id, key)
enddef

def Edit(id: number, open: string, filepath: string): bool
    popup_close(id)
    execute open filepath
    return 1
enddef

export def Open(curpath = '.'): void

    var ctx = {
        'idx': 0,
        'files': [],
        'curdir': ''
    }

    popup_min_width = (&columns / 2)
    popup_max_height = (&lines / 2)

    var path = expand(curpath)
    var dir = fnamemodify(path, ':p:gs!\/!')
    if isdirectory(dir) && dir !~# '/$'
        dir ..= '/'
    endif
    ctx.curdir = dir

    ctx.files = map(readdirex(path, '1', {'sort': 'collate'}), (_, v): string => Name(dir, v))
    popup_menu(ctx.files, {
        'filter': funcref('Filter', [ctx]),
        'scrollbar': 0,
        'minwidth': popup_min_width,
        'maxheight': popup_max_height
    })

enddef
