# tiny-popup-filer

最小限・シンプルな Vim9 script 製のファイラー。  
**ファイル操作もツリー表示も新規バッファも不要**。  
「開くだけ」のポップアップ型ファイラー。

## 必要環境

- Vim 9.0 以降

## インストール

Vim の package 機能を使う場合:

```sh
git clone https://github.com/yattn/tiny-popup-filer \
  ~/.vim/pack/yattn/start/tiny-popup-filer
```

## 特徴

* Vim9 script で実装された軽量ファイラー
* ポップアップウィンドウにファイル一覧を表示
* カーソル操作でファイル選択 → 開く
* カレントディレクトリの移動も対応
* 新しいバッファを開かず既存ウィンドウで開く

## 使い方

```vim
:Tpf [dir]    " 省略時は前回開いたディレクトリ
```

| キー | 動作 |
| ---- | ---- |
| `j` / `k`, `↑` / `↓` | 移動 |
| `l` / `→`, `Enter` | 開く・入る |
| `h` / `←`, `-` | 上のディレクトリへ |
| `c` | Vimのカレントディレクトリを選択位置に変更 |
| `x` / `Esc` | 閉じる |

## テスト

```sh
vim -n -es --cmd "set rtp+=." -S test/check.vim < /dev/null
```

成功時は exit 0。

## 要らないもの

* 新しいバッファの作成
* ファイルのコピー／削除／移動などの操作
* 複雑なツリー表示

## 参考

* [vim-molder](https://github.com/mattn/vim-molder)
* [popupfiles.vim](https://github.com/skanehira/popupfiles.vim)

## ライセンス

MIT License
