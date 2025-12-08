" use extended feature of vim (no compatible with vi)
set nocompatible

"set line numbers
set number relativenumber

" Toggle numbers. Relative in normal mode, absolute in insert mode
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
augroup END

" Paste from clipboard Ctrl+Shift+V
"set paste
set mouse=a
set clipboard=unnamedplus

" Disable compatibility with vi which can cause unexpected issues
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type
filetype on

" Enable plugins and load plugin for the detected file type
filetype plugin on

" Load an indent file for the detected file type
filetype indent on

" Syntax highlighting
syntax on

" Set shift width to 2 spaces
set shiftwidth=2

" Set tab width to 2 colums
set tabstop=2

"Use space characters instead of tabs
set expandtab

" While searching though a file incrementally highlight matching characters
set incsearch

" Ignore capital letters during search
set ignorecase

" Override the ignorecase option if searchig for capital letters
set smartcase

" Show matching words during a search
set showmatch

" Use hightlighting when doing a search
set hlsearch

" Show partial command you type in the last line of the screen
set showcmd

" Set the commands to save in history default number is 20
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" Press the space bar to type the : character in command mode.
nnoremap <space> :

" Fix True Color in tmux
if exists('+termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
  set termguicolors
endif

" 2. Define the override BEFORE loading the colorscheme
augroup MyCustomColors
  autocmd!
  " Force the background to gray (#1c1c1c) whenever a colorscheme loads
  autocmd ColorScheme * highlight Normal guibg=#181818 ctermbg=234
  " Optional: Match the empty space (NonText) to the same color
  autocmd ColorScheme * highlight NonText guibg=#181818 ctermbg=234
augroup END

" ALWAYS set a colorscheme when using termguicolors. 
" The default scheme looks 'wrong' or broken in RGB mode.
" 'desert' is a safe built-in choice if you don't have others installed.
colorscheme torte 
syntax on
