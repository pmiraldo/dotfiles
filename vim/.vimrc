set nocompatible              " be iMproved, required
filetype plugin on
syntax on

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'vimwiki/vimwiki'
let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]


" some nice vim settings
" https://dane-bulat.medium.com/vim-setting-up-a-build-system-and-code-completion-for-c-and-c-eb263c0a19a1
" https://dane-bulat.medium.com/how-to-turn-vim-into-a-lightweight-ide-6185e0f47b79 

" Add YCM repository to plugin list
" NEEDS: sudo apt install build-essential python3-dev llvm-dev llvm
" https://github.com/ycm-core/YouCompleteMe
" need apt install c++-12
Plugin 'ycm-core/YouCompleteMe'

" for compiling c++ from vim
Plugin 'tpope/vim-dispatch'

" colors
Plugin 'sainnhe/edge'
Plugin 'cocopon/iceberg.vim'
Plugin 'arcticicestudio/nord-vim'
Plugin 'Badacadabra/vim-archery'
Plugin 'kristijanhusak/vim-hybrid-material'
Plugin 'scheakur/vim-scheakur'
" Plugin 'lifepillar/vim-solarized'


" Language Packs for Syntax Highlighting
Plugin 'sheerun/vim-polyglot'

" Pair completion
Plugin 'jiangmiao/auto-pairs'


" NERDTREEE
Plugin 'preservim/nerdtree'

" sudo apt install ctags
Plugin 'preservim/tagbar'

" for swtiching between hpp and cpp
Plugin 'derekwyatt/vim-fswitch'

" git extensions
Plugin 'airblade/vim-gitgutter'

" ALE
Plugin 'dense-analysis/ale'


" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line
"
"
"


" Enable line numbers
set nu

" How many columns of whitespace a \t is worth
set tabstop=2
" How many columns of whitespace a "level of indentation" is worth
set shiftwidth=2
" Use spaces when tabbing
set expandtab

set termwinsize=12x0   " Set terminal size
set splitbelow         " Always split below
set mouse=a            " Enable mouse drag on window splits
set cursorline         " highlights the cursor line
set cursorcolumn       " highlights the cursor column
set colorcolumn=80

" Mapping to close the completion menu (default <C-y>)
let g:ycm_key_list_stop_completion = ['<C-x>']

" Set filetypes where YCM will be turned on
let g:ycm_filetype_whitelist = { 'cpp':1, 'h':2, 'hpp':3, 'c':4, 'cxx':5 }

" Close preview window after completing the insertion
let g:ycm_autoclose_preview_window_after_insertion = 1
let g:ycm_autoclose_preview_window_after_completion = 1

let g:ycm_confirm_extra_conf = 0                 " Don't confirm python conf
let g:ycm_always_populate_location_list = 1      " Always populae diagnostics list
let g:ycm_enable_diagnostic_signs = 1            " Enable line highligting diagnostics
let g:ycm_open_loclist_on_ycm_diags = 1          " Open location list to view diagnostics

let g:ycm_max_num_candidates = 20                " Max number of completion suggestions 
let g:ycm_max_num_identifier_candidates = 10     " Max number of identifier-based suggestions
let g:ycm_auto_trigger = 1                       " Enable completion menu
let g:ycm_show_diagnostic_ui = 1                 " Show diagnostic display features
let g:ycm_error_symbol = "\UF490"                    " The error symbol in Vim gutter
let g:ycm_warning_symbol = "\UF421"                    " The error symbol in Vim gutter
let g:ycm_enable_diagnostic_signs = 1            " Display icons in Vim's gutter, error, warnings
let g:ycm_enable_diagnostic_highlighting = 1     " Highlight regions of diagnostic text
let g:ycm_echo_current_diagnostic = 1            " Echo line's diagnostic that cursor is on

" Make Vim always render the sign column:
set signcolumn=yes


" Open vim-dispatch window and scroll to bottom
nnoremap    <C-m>m    :Copen<CR> <bar> G
" Build debug and release targets
nnoremap    <C-m>b   :Dispatch! make -j${nproc} -C build/<CR>
nnoremap    <C-m>c   :Dispatch! make clean -C build/<CR>
nnoremap    <C-m>r   :Dispatch! rm -rf build/*<CR>



"" COLORS
" let g:edge_style = 'aura'
let g:edge_style = 'neon'
let g:edge_enable_italic = 0
let g:edge_disable_italic_comment = 1
if has('termguicolors')
    set termguicolors
endif
set guifont=Hack\ 11
set background=dark
colorscheme archery
" Switch between dark and light obackground
nmap <F3> :set background=dark<CR>
nmap <F4> :set background=light<CR>


"" PAIR COMPLETION TOUGLE ...... NOT WORKING
let g:AutoPairsShortcutToggle = '<C-P>'



"" NERD tree options
let NERDTreeShowBookmarks = 0   " Show the bookmarks table
let NERDTreeShowHidden = 0      " Show hidden files
let NERDTreeShowLineNumbers = 0 " Hide line numbers
let NERDTreeMinimalMenu = 1     " Use the minimal menu (m)
let NERDTreeWinPos = "left"     " Panel opens on the left side
let NERDTreeWinSize = 31        " Set panel width to 31 columns

nmap <F2> :NERDTreeToggle<CR>


"" tabmanagement
map  <C-l> :tabn<CR>
map  <C-h> :tabp<CR>
map  <C-n> :tabnew<CR>


""" FOR CTAGS
" Focus the panel when opening it
let g:tagbar_autofocus = 1
" Highlight the active tag
let g:tagbar_autoshowtag = 1
" Make panel vertical and place on the right
let g:tagbar_position = 'botright vertical'
" Mapping to open and close the panel
nmap <F8> :TagbarToggle<CR>


""" Swtiching bwetween h and c
au! BufEnter *.cpp let b:fswitchdst = 'hpp,h'
au! BufEnter *.h let b:fswitchdst = 'cpp,c'
nmap <C-Z> :vsplit <bar> :wincmd l <bar> :FSRight<CR>
