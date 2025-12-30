{ config, pkgs, userConfig, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = userConfig.git.name;
        email = userConfig.git.email;
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      core = {
        autocrlf = "input";
        editor = "nvim";
      };

      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      branch.sort = "-committerdate";
      rerere.enabled = true;

      # Credential helper for WSL
      credential.helper = "/mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe";

      # Aliases
      alias = {
        st = "status -sb";
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        last = "log -1 HEAD --stat";
        co = "checkout";
        cob = "checkout -b";
        br = "branch -v";
        ci = "commit";
        cm = "commit -m";
        ca = "commit --amend";
        df = "diff";
        dfs = "diff --staged";
        unstage = "reset HEAD --";
        undo = "reset --soft HEAD~1";
        ss = "stash save";
        sp = "stash pop";
        sl = "stash list";
        cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d";
      };
    };

    ignores = [
      ".DS_Store"
      "Thumbs.db"
      "*.swp"
      "*.swo"
      "*~"
      ".idea/"
      ".vscode/"
      "*.iml"
      ".env.local"
      ".env.*.local"
      ".envrc.local"
      "result"
      "result-*"
      ".direnv/"
    ];
  };

  # Delta configuration (better diffs)
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      light = false;
      side-by-side = true;
      line-numbers = true;
    };
  };
}
