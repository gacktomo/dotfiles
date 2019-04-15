set fenc=utf-8
set nobackup
set noswapfile
set autoread
set hidden
set formatoptions-=ro
set iskeyword-=_

set number
set autoindent
set smartindent
set visualbell
set showmatch
set laststatus=2
set wildmode=list:longest

nnoremap j gj
nnoremap k gk
imap <C-j> <esc>
imap jj <esc>
imap kk <esc>
map <C-l> gt
map <C-h> gT

set list listchars=tab:\▸\-
set expandtab
set tabstop=2
set shiftwidth=2

set ignorecase
set smartcase
set incsearch
set wrapscan
set hlsearch
nmap <Esc><Esc> :nohlsearch<CR><Esc>
set switchbuf+=newtab
nnoremap <S-p> :tabe **/
nnoremap <S-f> :vim /hoge/j **/* \| cw

colorscheme molokai
syntax on

"Install with :PlugInstall.
call plug#begin('~/.vim/plugged')
Plug 'Shougo/neocomplete.vim'
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
Plug 'itchyny/lightline.vim'
Plug 'posva/vim-vue'
call plug#end()

"let g:neocomplete#enable_at_startup = 1
"let g:neocomplete#enable_smart_case = 1
"let g:neocomplete#min_keyword_length = 3
"let g:neocomplete#enable_auto_delimiter = 1
"let g:neocomplete#auto_completion_start_length = 1
"inoremap <expr><BS> neocomplete#smart_close_popup()."<C-h>"
"imap <expr><CR> neosnippet#expandable() ? "<Plug>(neosnippet_expand_or_jump)" : pumvisible() ? "<C-y>" : "<CR>"
"imap <expr><TAB> pumvisible() ? "<C-n>" : neosnippet#jumpable() ? "<Plug>(neosnippet_expand_or_jump)" : "<TAB>"

