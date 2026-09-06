vim9script
# tiny-popup-filer の最小自動テスト。開く・並べる・親解決だけ見る。
# キー操作 (h/j/k/l) は test.sh の手動確認が担当。
#
# 実行 (repo root から): vim -n -es --cmd "set rtp+=." -S test/check.vim < /dev/null; echo $?
# 成功時 exit 0、失敗時 exit 非ゼロ。

var failures: list<string> = []

def Ok(cond: bool, msg: string): void
    if !cond
        failures->add('FAIL: ' .. msg)
    endif
enddef

def Lines(): list<string>
    var ids = popup_list()
    Ok(len(ids) == 1, 'exactly one popup, got ' .. string(len(ids)))
    if empty(ids)
        return []
    endif
    return getbufline(winbufnr(ids[0]), 1, '$')
enddef

def TryTpf(arg: string): void
    try
        execute 'Tpf' fnameescape(arg)
    catch
        failures->add('FAIL: Tpf ' .. arg .. ': ' .. v:exception)
    endtry
enddef

# 1. ディレクトリ一覧: ファイルは素の名前、ディレクトリは '/' 付き
TryTpf('test/fixture')
var top = Lines()
Ok(index(top, 'a.txt') >= 0, 'lists a.txt: ' .. string(top))
Ok(index(top, 'sub/') >= 0, 'suffixes dir with /: ' .. string(top))
popup_clear()

# 2. サブディレクトリの中身
TryTpf('test/fixture/sub')
Ok(Lines() == ['b.txt'], 'lists subdir')
popup_clear()

# 3. ファイルを渡したら親ディレクトリを開く
TryTpf('test/fixture/a.txt')
var parent = Lines()
Ok(index(parent, 'a.txt') >= 0 && index(parent, 'sub/') >= 0, 'file arg opens parent: ' .. string(parent))
popup_clear()

if empty(failures)
    qa!
endif
writefile(failures, '/dev/stderr')
cquit
