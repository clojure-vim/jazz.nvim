command! -nargs=0 JazzNrepl lua require('jazz.nrepl').nrepl_menu()
command! -nargs=? JazzFindUsages lua require('jazz').find_usages(<f-args>)
command! -nargs=0 JazzNavigateSymbols lua require('jazz.navigation').symbols()

nmap <C-c>jn <Cmd>JazzNrepl<CR>

augroup Jazz
  au FileType clojure nmap <buffer> <C-c>ns <Cmd>JazzNavigateSymbols<Cr>
augroup END
