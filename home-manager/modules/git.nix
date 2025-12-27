{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    # Update these with your details
    userName = "Your Name";
    userEmail = "your.email@example.com";

    # Use delta for better diffs
    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
      };
    };

    extraConfig = {
      init.defaultBranch = "main";

      pull.rebase = true;
      push.autoSetupRemote = true;

      core = {
        autocrlf = "input";
        editor = "vim";
      };

      merge = {
        conflictstyle = "diff3";
      };

      diff = {
        colorMoved = "default";
      };

      # Better branch sorting
      branch.sort = "-committerdate";

      # Reuse recorded resolution
      rerere.enabled = true;

      # Credential helper for WSL (uses Windows credential manager)
      # Note: Path contains a space, properly quoted for git config
      credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";
    };

    # Global gitignore
    ignores = [
      # OS files
      ".DS_Store"
      "Thumbs.db"

      # Editor files
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.iml"

      # Environment files
      ".env.local"
      ".env.*.local"
      ".envrc.local"

      # Nix
      "result"
      "result-*"

      # direnv
      ".direnv/"
    ];

    aliases = {
      # Status
      st = "status -sb";

      # Logging
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      last = "log -1 HEAD --stat";

      # Branching
      co = "checkout";
      cob = "checkout -b";
      br = "branch -v";

      # Commit
      ci = "commit";
      cm = "commit -m";
      ca = "commit --amend";

      # Diff
      df = "diff";
      dfs = "diff --staged";

      # Reset
      unstage = "reset HEAD --";
      undo = "reset --soft HEAD~1";

      # Stash
      ss = "stash save";
      sp = "stash pop";
      sl = "stash list";

      # Clean
      cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
    };
  };
}
