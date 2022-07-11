" Delay in milliseconds after (Esc) key press.
set ttimeoutlen=50

syntax on                       " syntax highlighting
filetype on                     " try to detect filetypes
filetype plugin indent on       " enable loading indent file for filetype
filetype plugin on              " enable templates

" Spaces instead of tabs (looks the same in all editors) ...
set expandtab       " insert space(s) when tab key is pressed
set tabstop=4       " number of spaces inserted
set shiftwidth=4    " number of spaces for indentation
" more: http://vim.wikia.com/wiki/Converting_tabs_to_spaces

" Space settings per language
" (https://github.com/zdr1976/dotfiles/blob/master/vim/vimrc#L170)
autocmd Filetype gitcommit setlocal spell textwidth=72
autocmd FileType python setlocal tabstop=4 softtabstop=4 shiftwidth=4 expandtab
autocmd FileType go,godoc setlocal noexpandtab tabstop=8 shiftwidth=8 softtabstop=8
"autocmd BufRead,BufNewFile */playbooks/*.yml set filetype=ansible
autocmd FileType yaml setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType json setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd FileType html,htmldjango setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab
autocmd BufNewFile,BufRead *.kubeconfig setlocal filetype=yaml
autocmd FileType c,go,python autocmd BufWritePre <buffer> :%s/\s\+$//e

set nofoldenable " disable folding

" Stop vim from messing up my indentation on comments
" https://unix.stackexchange.com/questions/106526/stop-vim-from-messing-up-my-indentation-on-comments
set cinkeys-=0#
set indentkeys-=0#

set textwidth=79
set colorcolumn=80

"set nu          " show line numbers
"set relativenumber
"colors delek    " colorscheme
set showmatch   " show matching brackets

" don't bell or blink
set noerrorbells
set vb t_vb=

" paste/nopaste (inluding don't show/show numbers)
nnoremap <F2> :set nu! invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

" where to store swap files (*.swp)
" (https://stackoverflow.com/questions/1636297/how-to-change-the-folder-path-for-swp-files-in-vim)
:set directory=$HOME/.vim//

" search
set ignorecase  " case-insensitive search
set smartcase   " overide ignorecase when search includes uppercase letters
