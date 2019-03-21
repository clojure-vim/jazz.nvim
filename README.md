# Jazz.nvim

Acid + Impromptu = Jazz

This is an extension of [acid](https://github.com/clojure-vim/acid.nvim) that uses [impromptu](https://github.com/Vigemus/impromptu.nvim) to create prompts (menus, filter) and leverage the potential of acid through interactive features!

## Installing

```vim

"Dependencies
Plug 'clojure-vim/acid.nvim' "Remember to :UpdateRemotePlugins
Plug 'Vigemus/impromptu.nvim'

"🎵 Jazz
Plug 'clojure-vim/jazz.nvim'
```

## Features

* `JazzNrepl` or `<C-j>n`: Creates a menu to select the nrepl connection.
* `JazzFindUsages` or `<C-j>u`: Lists all the usages of the symbol under the cursor.
* `JazzNavigateSymbols` or `<C-j>s`: Lists all symbols in the project and moves to the selected symbol's definition.


## Extending

There are infinite possibilities. Please open an issue or a pull request if you have any extension idea.
