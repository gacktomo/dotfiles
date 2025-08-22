set fenc=utf-8
language C
set nobackup
set noswapfile
set autoread
set hidden
set formatoptions-=ro
set iskeyword-=_
set re=0
set number
set autoindent
set smartindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest
set nowrap
set nocompatible

set list listchars=tab:\▸\-
set expandtab
set tabstop=2
set shiftwidth=2
set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
set switchbuf+=newtab

nnoremap j gj
nnoremap k gk
imap <C-j> <esc>
imap jj <esc>
imap kk <esc>
map <C-l> gt
map <C-h> gT

nmap <Esc><Esc> :nohlsearch<CR><Esc>

if has('termguicolors')
  set termguicolors
endif
" colorscheme molokai
syntax on

let mapleader = "\<Space>"

""" easymotion
nmap s <Plug>(easymotion-s2)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gdv :tabe<CR><Plug>(coc-definition)
"nmap <silent> gdv :vs<CR><Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

""" coc-fzf
nmap <Leader>f [fzf-p]
xmap <Leader>f [fzf-p]
" nnoremap <silent> [fzf-p]p     :<C-u>FzfPreviewFromResourcesRpc project_mru git<CR>
nnoremap <Leader>p :<C-u>FzfPreviewFromResourcesRpc project_mru git<CR>
nnoremap <silent> [fzf-p]gs    :<C-u>FzfPreviewGitStatusRpc<CR>
nnoremap <silent> [fzf-p]ga    :<C-u>FzfPreviewGitActionsRpc<CR>
nnoremap <silent> [fzf-p]b     :<C-u>FzfPreviewBuffersRpc<CR>
nnoremap <silent> [fzf-p]B     :<C-u>FzfPreviewAllBuffersRpc<CR>
nnoremap <silent> [fzf-p]o     :<C-u>FzfPreviewFromResourcesRpc buffer project_mru<CR>
nnoremap <silent> [fzf-p]<C-o> :<C-u>FzfPreviewJumpsRpc<CR>
nnoremap <silent> [fzf-p]g;    :<C-u>FzfPreviewChangesRpc<CR>
nnoremap <silent> [fzf-p]/     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
nnoremap <silent> [fzf-p]*     :<C-u>FzfPreviewLinesRpc --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
nnoremap          [fzf-p]gr    :<C-u>FzfPreviewProjectGrepRpc<Space>
xnoremap          [fzf-p]gr    "sy:FzfPreviewProjectGrepRpc<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"
nnoremap <silent> [fzf-p]t     :<C-u>FzfPreviewBufferTagsRpc<CR>
nnoremap <silent> [fzf-p]q     :<C-u>FzfPreviewQuickFixRpc<CR>
nnoremap <silent> [fzf-p]l     :<C-u>FzfPreviewLocationListRpc<CR>

""" Running :PlugInstall command.
call plug#begin('~/.vim/plugged')
Plug 'tomasr/molokai', {'do': 'cp colors/* ~/.vim/colors/'}
Plug 'sheerun/vim-polyglot'
Plug 'itchyny/lightline.vim'
Plug 'easymotion/vim-easymotion'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'yuki-yano/fzf-preview.vim', { 'branch': 'release/rpc' }
call plug#end()
