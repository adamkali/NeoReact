" Title:        NeoReact
" Description:  A React plugin for Neovim.
" Last Change:  27 November 2022
" Maintainer:   Adam Kalinowski <https://github.com/example-user>


if exists('g:loaded_NeoReact') | finish | endif 

let s:save_cpo = &cpo
set cpo&vim

hi def link NeoReactHeader     Number
hi def link NeoReactSubHeader  Identifier

command! NeoReact lua require'NeoReact'.NeoReact()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_NeoReact = 1

