{ pkgs, config, ... }:

let

  sources = import ./nix/sources.nix;

in with { overlay = _: pkgs:
{ niv = (import sources.niv {}).niv;
    };
  };
  with import <home-manager/modules/lib/dag.nix> { inherit lib; };
  with config;
  let
    nixpkgs = sources.nixpkgs;

    pkgs = import nixpkgs {
      overlays = [
        overlay
        (self: super: # until 0.2.0 is released and in nixpkgs
        {
          pandoc-plantuml-filter = super.pandoc-plantuml-filter.overrideAttrs (old: {
            src = super.fetchFromGitHub {
              owner = sources.pandoc-plantuml-filter.owner;
              repo = sources.pandoc-plantuml-filter.repo;
              rev = sources.pandoc-plantuml-filter.rev;
              # If you don't know the hash, the first time, set:
              # sha256 = "0000000000000000000000000000000000000000000000000000";
              # then nix will fail the build with such an error message:
              # hash mismatch in fixed-output derivation '/nix/store/m1ga09c0z1a6n7rj8ky3s31dpgalsn0n-source':
              # wanted: sha256:0000000000000000000000000000000000000000000000000000
              # got:    sha256:173gxk0ymiw94glyjzjizp8bv8g72gwkjhacigd1an09jshdrjb4
              sha256 = sources.pandoc-plantuml-filter.sha256;
            };
            patches = (old.patches or []) ++ [
              (super.fetchpatch {
                url = sources.pandoc-plantuml-filter.homepage + "/commit/4634f3d808527b9223a216747a841619c63a8774.patch";
                sha256 = "0nzcrxvj0fw16p6ysp0yf55sg1jyn2y6dic66b8k3pzm93m58y48";
              })
            ];
          });
          wrappedRuby = with pkgs; (import ./program/ruby-gems { inherit lib; inherit bundlerEnv; inherit bundlerUpdateScript; inherit ruby; }).wrappedRuby;
          customPlugins = with pkgs.vimUtils; {
              SearchComplete = buildVimPluginFrom2Nix {
                pname = sources.vim-SearchComplete.repo;
                version = sources.vim-SearchComplete.version;
                src = pkgs.fetchFromGitHub {
                  owner = sources.vim-SearchComplete.owner;
                  repo = sources.vim-SearchComplete.repo;
                  rev = sources.vim-SearchComplete.rev;
                  sha256 = sources.vim-SearchComplete.sha256;
                };
                meta.homepage = sources.vim-SearchComplete.homepage;
              };
              mru = buildVimPlugin {
                name = sources.vim-mru.repo;
                src = pkgs.fetchFromGitHub {
                  owner = sources.vim-mru.owner;
                  repo = sources.vim-mru.repo;
                  rev = sources.vim-mru.rev;
                  sha256 = sources.vim-mru.sha256;
                };
              };
            };
            dotfiles = super.fetchFromGitHub {
              owner = sources.dotfiles.owner;
              repo = sources.dotfiles.repo;
              rev = sources.dotfiles.rev;
              sha256 = sources.dotfiles.sha256;
            };
            searx = super.fetchFromGitHub {
              owner = sources.searx.owner;
              repo = sources.searx.repo;
              rev = sources.searx.rev;
              sha256 = sources.searx.sha256;
            };
            winbinSrc = super.fetchFromGitHub {
              owner = sources.winbin.owner;
              repo = sources.winbin.repo;
              rev = sources.winbin.rev;
              sha256 = sources.winbin.sha256;
            };
            gitissueSrc = super.fetchFromGitHub {
              owner = sources.git-issue.owner;
              repo = sources.git-issue.repo;
              rev = sources.git-issue.rev;
              sha256 = sources.git-issue.sha256;
            };
            nvd = (import (super.fetchFromGitLab {
              owner = sources.nvd.owner;
              repo = sources.nvd.repo;
              rev = sources.nvd.rev;
              sha256 = sources.nvd.sha256;
            }) { pkgs = self; });
            rnix-lsp = super.callPackage <nixpkgs/pkgs/development/tools/rnix-lsp> {
              rustPlatform = super.rustPlatform // {
                buildRustPackage  = args:
                super.rustPlatform.buildRustPackage (args // {
                  src =
                    super.fetchFromGitHub {
                      owner = sources.rnix-lsp.owner;
                      repo = sources.rnix-lsp.repo;
                      rev = sources.rnix-lsp.rev;
                      sha256 = sources.rnix-lsp.sha256;
                    };
                    cargoSha256 = sources.rnix-lsp.cargoSha256;
                  });
                };
              };
            })
            (import sources.neovim-nightly-overlay)
          ]; config = {};
        };

        dag = config.lib.dag;
                  in
                  {

  # The home-manager manual is at:
  #
  #   https://rycee.gitlab.io/home-manager/release-notes.html
  #
  # Configuration options are documented at:
  #
  #   https://rycee.gitlab.io/home-manager/options.html

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  #
  # You need to change these to match your username and home directory
  # path:
  # NOTE https://github.com/nix-community/home-manager/blob/b95ad632010bf1d135f7585c590f51f6c3dc2896/doc/release-notes/rl-2009.adoc#L21
  #  says that `builtins.getEnv` was used before (`HOME` and `USER` respectively), hard code username if needed here
  # https://github.com/nix-community/home-manager/blob/ac319fd3149b23a3ad8ee24cb2def6e67acf194c/modules/home-environment.nix
  # https://github.com/nix-community/home-manager/blob/97d183e2e466808f5d7cd1c838815bedd88f37fe/tests/default.nix#L23
  home.username = (builtins.getEnv "USER");
  home.homeDirectory = (builtins.getEnv "HOME");

  # If you use non-standard XDG locations, set these options to the
  # appropriate paths:
  #
  # xdg.cacheHome
  # xdg.configHome
  # xdg.dataHome

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";

  imports =
    let
      inherit pkgs;
    in
    [
      (sources.declarative-cachix + "/home-manager.nix")
      ./program/emacs
      ./program/haskell
      ./program/python
   ];

    caches = {
      extraCaches =
        [
          {
            url = "https://hydra.iohk.io";
            key = "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=";
          }
        ];

        cachix = [
          {
            name = "cachix";
            sha256 = "0k781wwv25nr8f9qyq6isvcl87mhaf659nfcg5wq3f5402ly549h";
          }
          {
            name = "nix-on-droid";
            sha256 = "02scgj2c75jjg2wkn8n8kniaxs26k3a64i7r4bz0ndf2a0cg32ps";
          }
          {
            name = "nix-community";
            sha256 = "1r0dsyhypwqgw3i5c2rd5njay8gqw9hijiahbc2jvf0h52viyd9i";
          }
          {
            name = "niv";
            sha256 = "13q2c4immry22m8s11fwr1gw6icfz2dkasyxyps06g4vicba1hb3";
          }
          {
            name = "smos";
            sha256 = "1svlgqx9k7y4vg9r78py0bd6lzc8xyml634h090010ipwil1w0w8";
          }
          {
            name = "573-bc";
            sha256 = "1pxxadpfbfqbbqldal0i6jqldf9hcv2rnqlyjdvxf9rlqhynyb23";
          }
          {
            name = "srid";
            sha256 = "1nnp81jjxbj68n5xm6zlmsmzfzlday6a2j2bqp4wq00n67v4bz03";
          }
          {
            name = "jupyterwith";
            sha256 = "19v6g0hbpap8f9b9787rkxaa73yqpm5lhm3k6av0ijhaxrgc9n1w";
          }
          {
            name = "mjlbach";
            sha256 = "17xz215pfzlar0xjp43f9n5215djxaqd80livkvs0796634fw7xk";
          }
        ];
      };

      home.activation.report-changes = with pkgs; dag.entryAnywhere ''
        ${nvd}/bin/nvd diff $oldGenPath $newGenPath
      '';

      home.packages =  with pkgs;[
    #  neovim.io - Vim-fork focused on extensibility and usability
    neovim-nightly

    # neovim dependencies
    nodePackages.diagnostic-languageserver
    nodePackages.json-server
    nodePackages.pyright
    rnix-lsp
    nodejs_latest
    yarn
    tree-sitter
    rust-analyzer
    clang-tools

    # I am using this ruby env for a mail-filter script
    wrappedRuby

    # https://github.com/cachix/cachix - Command line client for Nix binary cache hosting
    cachix # building with default ghc in nixpkgs, revision e68dfcb4a53c8abad243d4e2f06079b56a8bcf38 breaks with https://paste.c-net.org/16af6c0b-022f-8898-1368-82d5aca82d79

    # https://github.com/mlvzk/manix - A fast CLI documentation searcher for Nix.
    manix

    # https://calcurse.org/ - calcurse is a calendar and scheduling application for the command line.
    calcurse

    # https://github.com/ggreer/the_silver_searcher/ - description = "A code-searching tool similar to ack, but faster
    silver-searcher

    # http://stedolan.github.io/jq/download/ - A lightweight and flexible command-line JSON processor
    jq

    # https://github.com/purcell/sqlint - Simple SQL linter supporting ANSI and PostgreSQL syntaxes
    sqlint

    # https://www.openssh.com/ - OpenSSH is the premier connectivity tool for remote login with the SSH protocol
    openssh

    # https://github.com/htop-dev/htop - htop - an interactive process viewer
    htop

    # https://github.com/so-fancy/diff-so-fancy - Good-looking diffs filter for git
    gitAndTools.diff-so-fancy

    # https://github.com/mvdan/sh - A shell parser, formatter, and interpreter with bash support; includes shfmt
    shfmt

    # https://github.com/koalaman/shellcheck - ShellCheck, a static analysis tool for shell scripts
    shellcheck

    # https://github.com/timofurrer/pandoc-plantuml-filter - Pandoc filter which converts PlantUML code blocks to PlantUML images (usage example: https://github.com/timofurrer/pandoc-plantuml-filter/pull/14#issuecomment-805739942)
    pandoc-plantuml-filter
  ];

  programs.command-not-found.enable = true;

  programs.home-manager = let
    src = pkgs.fetchFromGitHub {
      owner = sources.home-manager.owner;
      repo = sources.home-manager.repo;
# using master here; reason (https://nix-community.github.io/home-manager/index.html#sec-install-standalone "if you are following Nixpkgs (...) unstable channel")
# and output of nix-channel --list was: nixpkgs https://nixos.org/channels/nixpkgs-unstable
      rev = sources.home-manager.rev;
      sha256 = sources.home-manager.sha256;
    };
    # `path` is required for `home-manager` to find its own sources
    # to cite hm's manual: If instead of using channels you want to run Home Manager from a Git checkout of the repository then you can use the programs.home-manager.path option to specify the absolute path to the repository.
    in {
      enable = true;
      path = "${src}";
    };

  # see https://github.com/nix-community/nix-direnv#via-home-manager
  # see https://github.com/nix-community/nix-direnv#why-not-use-lorri-instead
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.autojump.enable = true;

  # Since we do not install home-manager, you need to let home-manager
  # manage your shell, otherwise it will not be able to add its hooks
  # to your profile.
  programs.bash = with pkgs.lib; {
    enable = true;
    historySize = 10000000;
    historyFileSize = 10000000;
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    historyIgnore = [ "ls" "cd" "exit" ];
    sessionVariables = {
      DISPLAY = ":0.0";
      EDITOR = "vim";
      PATH = "\${PATH}:/mnt/c/Windows/System32:/mnt/c/Users/${(builtins.getEnv "USER")}/scoop/apps/pwsh/current";
    };

    profileExtra = mkMerge [
      (mkBefore ''
      # profileExtra top
      # https://unix.stackexchange.com/questions/4921/sh-startup-files-over-ssh/4953#4953
      # the following seem IDK just right(ish)
        . "${config.home.profileDirectory}/etc/profile.d/nix.sh"
      # to have nix-store etc. available via non-interactive bash (ssh)
        export PATH="/nix/var/nix/profiles/default/bin:$PATH"
      # the following points to the actual (but probably misconfigured) per-user profile.d ...
      # and should rather be /nix/var/nix/profiles/per-user/${config.home.username}/etc/profile.d/nix.sh" ...
      # which in turn is the same as ${config.home.profileDirectory}/etc/profile.d/nix.sh when configured correctly ...
      # see https://github.com/nix-community/home-manager/blob/0006da1/modules/home-environment.nix#L414
      #. "/nix/var/nix/profiles/per-user/${config.home.username}/profile/etc/profile.d/nix.sh"
      # the following is not visible via nixos-shell, single-user nix (arch wsl - which has no systemd / nix-daemon support)
      #. "/nix/var/nix/profiles/default/etc/profile.d/nix.sh"
      # regarding hm-session-vars: https://github.com/rycee/home-manager/issues/735#issuecomment-501374486
      '')
      (mkAfter ''
      # profileExtra bottom
      '')
    ];

    initExtra = mkMerge [
      (mkBefore ''
        # initExtra top
      '')
      (mkAfter ''
        # initExtra bottom
      '')
    ];

    bashrcExtra = with pkgs; mkMerge [
      (mkBefore ''
        # bashrcExtra top
        source ${gitissueSrc}/gi-completion.sh
      '')
      (mkAfter ''
        # bashrcExtra bottom
        # https://direnv.net/docs/hook.html#bash
        eval "$(direnv hook bash)"

        # https://askubuntu.com/questions/67283/is-it-possible-to-make-writing-to-bash-history-immediate
        shopt -s histappend
        export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"
      '')
    ];

    shellAliases = {
      # do not delete / or prompt if deleting more than 3 files at a time #
      rm = "rm -I --preserve-root";

      # confirmation #
      mv = "mv -i";
      cp = "cp -i";
      ln = "ln -i";

      # Parenting changing perms on / #
      chown = "chown --preserve-root";
      chmod = "chmod --preserve-root";
      chgrp = "chgrp --preserve-root";

      cheat = "function _f() { curl cht.sh/\"$1\"; } ; _f";
      # https://stackoverflow.com/questions/3430330/best-way-to-make-a-shell-script-daemon
      # try this as well:
      # https://unix.stackexchange.com/questions/426862/proper-way-to-run-shell-script-as-a-daemon
      # or:
      # https://wiki.jenkins.io/display/JENKINS/Installing+Jenkins+as+a+Unix+daemon
      nrn_oneoff = "function _f() { \\
      ( neuron ~/meinzettelkasten rib serve </dev/null &>~/rib_serve.out & ) & \\
      } ; _f";
    };
  };

  programs.vim = {
    enable = true;

    extraConfig = ''
      set mouse=a
      set background=dark
      set statusline+=%#warningmsg#
      set statusline+=%{SyntasticStatuslineFlag()}
      set statusline+=%*
      if has("multi_byte")
        " IDK where I got that from but setting termencoding in any case seems crucial
        "if &termencoding == ""
        "  let &termencoding = &encoding
        "endif
        set encoding=utf-8
        setglobal fileencoding=utf-8
        " Uncomment to have 'bomb' on by default for new files.
        " Note, this will not apply to the first, empty buffer created at Vim startup.
        "setglobal bomb
        set fileencodings=ucs-bom,utf-8,latin1
      endif
      " https://www.reddit.com/r/PowerShell/comments/9ya1un/issues_with_git_nano_and_vim/ea0v0yw/
      set termencoding=utf-8

      augroup HiglightTODO
        autocmd!
        " https://github.com/guns/xterm-color-table.vim
        hi CustomDone ctermbg=40 guibg=yellow guifg=black ctermfg=black
        hi CustomNext ctermbg=13 guibg=Cyan guifg=black ctermfg=black
        autocmd WinEnter,VimEnter * :silent! call matchadd('CustomNext', 'NEXT', -1)
        autocmd WinEnter,VimEnter * :silent! call matchadd('CustomDone', '\<DONE\>\|\<FIXED\>', -1)
        autocmd WinEnter,VimEnter * :silent! call matchadd('Todo', 'TODO\|FIXME\|IMPORTANT', -1)
      augroup END

      "set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
      " Not supported by neovim in debian
      " set signcolumn=yes

      function! HandleWindowProgress(params) abort
      echomsg json_encode(a:params)
      endfunction

        " do not run linters while you type
        "let g:ale_lint_on_text_changed = 'never'

        " lightline-ale config
        let g:lightline = {}

      let g:lightline.component_expand = {
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_infos': 'lightline#ale#infos',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }

      let g:lightline.component_type = {
      \     'linter_checking': 'right',
      \     'linter_infos': 'right',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'right',
      \ }

      let g:lightline.active = {
      \ 'right': [ [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
      \            [ 'lineinfo' ],
      \            [ 'percent' ],
      \            [ 'fileformat', 'fileencoding', 'filetype'] ] }

      " Windows note: works i. e. in "Windows-Terminal, Version: 1.8.210524004-release1.8" with font for the profile set to i. e. "NotoMono NF" which needs to be installed

      let g:lightline#ale#indicator_checking = "\uf110"
      let g:lightline#ale#indicator_infos = "\uf129"
      let g:lightline#ale#indicator_warnings = "\uf071"
      let g:lightline#ale#indicator_errors = "\uf05e"
      let g:lightline#ale#indicator_ok = "\uf00c"


      " next two settings relate to https://superuser.com/questions/1284561/why-is-vim-starting-in-replace-mode
      " maybe have to put them at vimrc bottom
      set t_u7=
      "set ambw=double

    '';

    # see https://github.com/nixos/nixpkgs/blob/master/pkgs/misc/vim-plugins/generated.nix and https://github.com/nixos/nixpkgs/blob/master/pkgs/misc/vim-plugins/vim-plugin-names
    plugins = with pkgs.vimPlugins // pkgs.customPlugins; [
      # https://github.com/mbbill/undotree -  The undo history visualizer for VIM
      undotree

      # https://github.com/vim-scripts/SearchComplete - Tab completion of words inside of a search ('/') 
      SearchComplete 

      # https://github.com/itchyny/lightline.vim - A light and configurable statusline/tabline plugin for Vim
      lightline-vim

      # https://github.com/morhetz/gruvbox -  Retro groove color scheme for Vim
      gruvbox

      # https://github.com/junegunn/limelight.vim - Hyperfocus-writing in Vim
      limelight-vim

      # https://github.com/junegunn/goyo.vim - 🌷 Distraction-free writing in Vim
      goyo

      # https://github.com/yegappan/mru - Most Recently Used (MRU) Vim Plugin
      mru

      # https://github.com/justinmk/vim-sneak - Jump to any location specified by two characters
      vim-sneak

      # https://github.com/preservim/nerdtree - The NERDTree is a file system explorer for the Vim editor
      nerdtree

      # https://github.com/Xuyuanp/nerdtree-git-plugin - A plugin of NERDTree showing git status flags
      nerdtree-git-plugin

      # https://github.com/airblade/vim-gitgutter - A Vim plugin which shows a git diff in the sign column
      vim-gitgutter

      # https://github.com/liuchengxu/vista.vim - 🌵 Viewer & Finder for LSP symbols and tags
      vista-vim

      # https://github.com/ntpeters/vim-better-whitespace - This plugin causes all trailing whitespace characters (see Supported Whitespace Characters below) to be highlighted
      vim-better-whitespace

      # https://github.com/dense-analysis/ale - Check syntax in Vim asynchronously and fix files, with Language Server Protocol (LSP) support (https://github.com/dense-analysis/ale/blob/master/doc/ale.txt)
      ale

      # https://github.com/maximbaz/lightline-ale - ALE indicator for the lightline vim plugin (ale lightline integration)
      lightline-ale

      # https://github.com/LnL7/vim-nix - Support for writing Nix expressions in vim (want a good formatexpr for nix files)
      vim-nix

      # https://github.com/autozimu/LanguageClient-neovim - Language Server Protocol support for vim and neovim (https://nixos.wiki/wiki/Vim#Vim_as_a_Python_IDE)
      # Currently I have problems using this as the binary doesn't seem to be generated using my configuration
      # :echo LanguageClient#binaryPath()
      # i. e. find /nix/store/n8f2ag3jlhp4ixl8sn8s6zg3mbyq72sm-vimplugin-LanguageClient-neovim-2021-07-08/share/vim-plugins/LanguageClient-neovim/ -name languageclient
      # is empty
      # Wrong assumption tested with version before nix/sources.nix same: I assume problems with how I use sources.nix (niv) interferes with https://github.com/autozimu/LanguageClient-neovim/blob/075184af2cd5397e2021099ec2495d05af28e5a4/shell.nix somehow
      # DEACTIVATED until fixed https://github.com/NixOS/nixpkgs/issues/129629
      #LanguageClient-neovim
    ];
    settings = { ignorecase = true; };
  };

  programs.ssh = {
    enable = true;
    # FIXME To bypass the problem with changing ips (dhcp) could use list of identityFile with generic host * as in https://github.com/nix-community/home-manager/issues/625
    matchBlocks = {
      "smartphone" = {
        hostname = "192.168.1.120";
        user = "nix-on-droid";
        port = 8023;
        identitiesOnly = true;
        identityFile = "~/.ssh/nix_remote";
      };
      "nixos-shell" = {
        hostname = "localhost";
        user = "root";
        port = 2222;
        identitiesOnly = true;
        identityFile = "~/.ssh/id_rsa";
        extraOptions = {
          StrictHostKeyChecking = "no";
        };
      };
      "builder" = {
        hostname = "192.168.1.30";
        user = "dani";
        identitiesOnly = true;
        identityFile = "~/.ssh/nix_remote_dani";
      };
    };
  };

  programs.git =
    {
      enable = true;
      userEmail = "d.kahlenberg@gmail.com";
      userName = "573";
      aliases = with pkgs; {
        issue = "!${gitissueSrc}/git-issue.sh";
      # https://utcc.utoronto.ca/~cks/space/blog/programming/GitAliasesIUse
      source = "remote get-url origin";
      plog = "log @{1}..";
      slog = "log --pretty=slog";
      pslog = "log --pretty=slog @{1}..";
      ffpull = "pull --ff-only";
      ffmerge = "merge --ff-only";
      pushd = "push -u origin HEAD";
      alias = "config --get-regexp ^alias";
      blameconflict = "blame -L '/^<<<</,/^>>>>/'";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      subtreeadd = "!f() { \\
      git subtree add --prefix $2 $1 master --squash \\
      }; f";
      newcommits = "!sh -c 'git log $1@{1}..$1@{0} \"$@\"'";
      cfg = "config --list";
      sortdiff = "!sh -c 'git diff \"$@\" | grep \"^[+-]\" | sort --key=1.2 | uniq -u -s1'";
      # take all uncommitted and un-staged changes currently in the working directory and add them to the previous commit, amending it before pushing the change up:
      caa = "commit -a --amend -C HEAD";
    };
    extraConfig = {
      core = {
        editor = "vim";
        pager = "diff-so-fancy | less --tabs=4 -RFX";
      };
      pretty = { slog = "format:* %s"; };
      color = {
        ui = true;
        diff-highlight = {
          oldNormal = "red bold";
          oldHighlight = "red bold 52";
          newNormal = "green bold";
          newHighlight = "green bold 22";
        };
        diff = {
          meta = "11";
          frag = "magenta bold";
          commit = "yellow bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    package = pkgs.tmux;
    secureSocket = false;
    #extraConfig = builtins.readFile ./tmux.conf;
    extraConfig = ''
      # List of plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'tmux-plugins/tmux-resurrect'
      set -g @plugin 'tmux-plugins/tmux-continuum'

      # Other examples:
      # set -g @plugin 'github_username/plugin_name'
      # set -g @plugin 'git@github.com/user/plugin'
      # set -g @plugin 'git@bitbucket.com/user/plugin'

      # https://github.com/direnv/direnv/wiki/Tmux
      set-option -g update-environment "DIRENV_DIFF DIRENV_DIR DIRENV_WATCHES"
      set-environment -gu DIRENV_DIFF
      set-environment -gu DIRENV_DIR
      set-environment -gu DIRENV_WATCHES
      set-environment -gu DIRENV_LAYOUT

      # Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
      run -b '~/.tmux/plugins/tpm/tpm'

    '';
  };

  # https://github.com/jwiegley/nix-config/blob/3106daf/config/home.nix#L632
  xdg = {
    enable = true;

    configFile = {

      #"nvim" = {
      #  source = ${pkgs.dotfiles} + "/config/nvim";
      #  recursive = true;
      #};

      "direnv/direnvrc".text = ''
        # ${config.xdg.configHome}/direnv/direnvrc
        : ''${XDG_CACHE_HOME:=$HOME/.cache}
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            echo "''${direnv_layout_dirs[$PWD]:=$(
                echo -n "$XDG_CACHE_HOME"/direnv/layouts/
                echo -n "$PWD" | shasum | cut -d ' ' -f 1
            )}"
        }
      '';

      "searx/settings.yml" = {
        source =
          pkgs.runCommand "searx/settings.yml"
          {
            input = "${pkgs.searx}/searx/settings.yml";
            } ''
            sed \
            -e "s!port : 8888!port : 9888!g" \
            -e "s!secret_key : \"ultrasecretkey\"!secret_key : \"`${pkgs.openssl}/bin/openssl rand -hex 32`\"!g" \
            "$input" > "$out"
            '';
          };

          "ssh/sshd_config".text = ''
# ${config.xdg.configHome}/ssh/sshd_config
# usage: $(which sshd) -d -D -f ~/.config/ssh/sshd_config # (nmap -p 8023 192.168.1.0/24)
            AuthorizedKeysFile   .ssh/authorized_keys
            PasswordAuthentication no
            Port 8023
            ChallengeResponseAuthentication no
            PubkeyAuthentication yes
            PermitRootLogin no
            UsePAM no
            PrintMotd no
            PermitUserEnvironment no
            Banner /etc/issue
# You may generate the host key using: ${pkgs.openssh}/bin/ssh-keygen -q -N "" -t rsa -b 4096 -f ${config.home.homeDirectory}/.ssh/local_sshd/ssh_host_rsa_key
            HostKey ~/.ssh/local_sshd/ssh_host_rsa_key
          '';

          "jrnl/jrnl.yaml".text = ''
            colors:
            body: none
            date: none
            tags: none
            title: none
            default_hour: 9
            default_minute: 0
            editor: 'vim'
            encrypt: false
            highlight: true
            indent_character: '|'
            journals:
            default: ${config.home.homeDirectory}/.local/share/jrnl/journal.txt
            linewrap: 79
            tagsymbols: '@'
            template: false
            timeformat: '%Y-%m-%d %H:%M'
            version: v2.3
          '';
        };
      };

      home.activation.linkMyStuff = dagEntryAfter [ "writeBoundary" ] ''
        ln -sf /mnt/c/Users/$USER/journal.txt ${config.home.homeDirectory}/.local/share/jrnl/journal.txt
      '';

      home.file = with pkgs; let
        patchShebang = ''
          sed -e "s:#!/bin/:#!${pkgs.coreutils}/bin/env :g" \
          -e "s!powershell.exe!pwsh.exe -c!g" \
          "$input" > "$out"
        '';
      in
      {
    # https://discourse.nixos.org/t/fix-collision-with-multiple-jdks/10812/3
    #"jdks/openjdk11".source = pkgs.openjdk11;
    #"jdks/scala".source = pkgs.scala;

    # https://dba.stackexchange.com/a/188807/52882 (psql)
    ".gitignore_global".text = ''
# Direnv stuff
      .direnv
      .envrc
# OS generated files #
######################
      .DS_Store
      ehthumbs.db
      Icon?
      Thumbs.db
# Editor files #
################
      *~
      *.swp
      *.swo
    '';

    # DONE ruby script for gmail-britta
    # TODO mkShell could be a better variant as it has buildInputs, ruby needed here, would make it explicit
    # or https://nixos.wiki/wiki/Nix_Cookbook#Wrapping_packages
    # https://gist.github.com/573/32a30648856bf8d0f5af83dbdfa621fe
    # https://github.com/NixOS/nixpkgs/blob/a71e906e3a0bec9c5fece94262e96de83e58c1f3/pkgs/build-support/trivial-builders.nix
    "mkFilter" = {
      # NOTE careful with indentation in here-doc as '' ... '' try to preserve the former possible breaking EOF handling, see https://github.com/NixOS/nixpkgs/issues/15076
      # TODO Also this might be structured differently, utilizing that instead of here-doc a text variable could be used as input (?) and `executable = true` be set instead of chmodding manually.
      source = runCommand "dummy" {} ''
        # mkdir $out
        cat << EOF > $out
        #! ${wrappedRuby}/bin/ruby
        # TODO using nix-shell would be even better above
        # https://gist.github.com/573/32a30648856bf8d0f5af83dbdfa621fe
        require 'rubygems'
        require 'gmail-britta'

        if File.exist?(File.expand_path("~/.gmail-britta.secret.rb"))
        require "~/.gmail-britta.secret.rb"
        else
        # --- labels ---
        L_CF1 = 'close friend'
        # --- ids ---
        CF1 = ['friendofmine@googlemail.com']
        ME = ['me@gmail.com']
        end

        CF_MAIL = [{:or => CF1.map{|email| "from:#{email}"}}, {:or => ME.map{|email| "to:#{email}"}}, {:or => ME.map{|email| "from:#{email}"}}, {:or => CF1.map{|email| "to:#{email}"}}]

        fs = GmailBritta.filterset(:me => ME) do
        filter {
        has CF_MAIL
        label L_CF1
        never_spam
        }.otherwise {
        #    has CF_MAIL
        #    label L_CF1
        #    never_spam
        }.archive_unless_directed
        end
        puts fs.generate
        EOF
        chmod +x $out
        '';
    };

    "bin/pbcopy" = {
      source = runCommand "ftchScr" {
        input = "${winbinSrc}/pbcopy";
      } "${patchShebang}";
      executable = true;
    };

          "bin/pbpaste" = {
            source =
              runCommand "ftchScr"
              {
                input = "${winbinSrc}/pbpaste";
              } "${patchShebang}";
              executable = true;
            };

            "bin/wsl-open" = {
              source =
                runCommand "ftchScr"
                {
                  input = "${winbinSrc}/open";
                } "${patchShebang}";
                executable = true;
              };


              ".screenrc".text = ''
      # huge scrollback buffer
                defscrollback 5000

      # no welcome message
                startup_message off
              '';

              ".ssh/environment".text = ''
                BASH_ENV=~/.profile
              '';

    # https://github.com/cachix/cachix/issues/239#issuecomment-654868603
    nixConf = {
      text = ''
# most def shoulda work
#extra-platforms = aarch64-linux arm-linux
#builders-use-substitutes = true
#builders = ssh://builder
#build-users-group = nixbld
# https://github.com/NixOS/nix/issues/2964#issuecomment-504097120
        sandbox = false
#    system-features = nixos-test kvm big-parallel
#notworking:plugin-files = ${config.home.profileDirectory}/lib/libnix_doc_plugin.so
# FIXME Rather use https://github.com/lf-/nix-doc/issues/12
# issue with tex2nix: plugin-files = DOLLARHERE{nix-doc}/lib/libnix_doc_plugin.so
# https://github.com/nix-community/nix-direnv#via-home-manager
#keep-derivations = true
#keep-outputs = true
#experimental-features = nix-command flakes
        trusted-substituters = https://hydra.nixos.org/
        allowed-users = ${config.home.username} root
        use-sqlite-wal = false
        system-features = benchmark big-parallel kvm nixos-test
      '';
    };
  };
}
