command! -nargs=0 JazzNrepl lua require('jazz.nrepl').nrepl_menu()
command! -nargs=? JazzFindUsages lua require('jazz.usages').find_all(<f-args>)
command! -nargs=0 JazzNavigateSymbols lua require('jazz.navigation').symbols()

nmap <C-j>n <Cmd>JazzNrepl<CR>

augroup Jazz
  au FileType clojure nmap <buffer> <C-j>u <Cmd>JazzFindUsages<Cr>
  au FileType clojure nmap <buffer> <C-j>s <Cmd>JazzNavigateSymbols<Cr>
  au FileType clojure nmap <buffer> <C-j>a <Cmd>lua require("jazz.files").alternate()<Cr>
  au FileType clojure nmap <buffer> <C-j>f <Cmd>lua require("jazz.files").new()<Cr>
augroup END
