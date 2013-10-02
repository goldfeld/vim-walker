## vim-walker

Walker is a context-aware list stepper. Here are the heuristics used to
determine what to do:

* If you are in diff mode, he'll walk you through diffs (uses the vim built-ins
  `[c`, `]c` and so forth)
* If you are in a buffer with git-diff-like output (i.e. has lines beginning
  with `+` and/or `-` and has filetype `git`/`diff`), a custom algorithm will
  help you walk through each change as if you were in diff mode.
* Otherwise, the commands will walk you through your quicklist (uses `:cfirst`,
  `:cnext`, `:cprevious` and so on)

The following commands let you use walker to step through lists in a unified,
context-aware fashion:

| Command      |  Example                             |
|--------------|:------------------------------------:|
|`WalkerFirst` | `nnoremap <Leader>f :WalkerFirst<CR>`|
|`WalkerNext`  | `nnoremap <Leader>d :WalkerNext<CR>` |
|`WalkerPrev`  | `nnoremap <Leader>s :WalkerPrev<CR>` |

More to come, I'm just lazy (and that's all I really use.)

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/goldfeld/vim-walker/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
