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

### `JazzNrepl` or `<C-j>n`: Creates a menu to select the nrepl connection.
[![asciicast](https://asciinema.org/a/PkPPUEYRvVqVks2IxxJI55s34.svg)](https://asciinema.org/a/PkPPUEYRvVqVks2IxxJI55s34)

### `JazzFindUsages` or `<C-j>u`: Lists all the usages of the symbol under the cursor.
[![asciicast](https://asciinema.org/a/236703.svg)](https://asciinema.org/a/236703)

### `JazzNavigateSymbols` or `<C-j>s`: Lists all symbols in the project and moves to the selected symbol's definition.
[![asciicast](https://asciinema.org/a/236704.svg)](https://asciinema.org/a/236704)


## Extending

There are infinite possibilities. Please open an issue or a pull request if you have any extension idea.
