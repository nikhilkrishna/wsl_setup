{ config, pkgs, ... }:

{
  # ============================================
  # Neovim Configuration (basic, functional)
  # ============================================
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      " Better defaults
      set nocompatible
      set encoding=utf-8
      set backspace=indent,eol,start
      set autoindent
      set smartindent
      set hlsearch
      set incsearch
      set showmatch
      set wildmenu
      set wildmode=longest:full,full

      " Line numbers
      set number
      set relativenumber

      " Tabs and indentation
      set expandtab
      set tabstop=2
      set shiftwidth=2

      " Mouse and search
      set mouse=a
      set ignorecase
      set smartcase

      " Better splits
      set splitbelow
      set splitright

      " No backup files
      set nobackup
      set nowritebackup
      set noswapfile

      " Status line
      set laststatus=2
      set statusline=%f\ %m%r%h%w\ [%{&ff}]\ [%Y]\ [%l,%c]\ [%p%%]

      " Colors
      syntax enable
      set background=dark

      " Key mappings
      let mapleader = " "
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Clear search highlighting
      nnoremap <leader><space> :nohlsearch<CR>
    '';
  };

  # ============================================
  # Bat (better cat) Configuration
  # ============================================
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };
}
