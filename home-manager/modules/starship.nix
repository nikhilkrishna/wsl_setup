{ config, pkgs, lib, ... }:

{
  # ============================================
  # Starship Prompt
  # ============================================
  programs.starship = {
    enable = true;
    enableBashIntegration = true;

    settings = {
      # Minimal, informative prompt
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$python"
        "$nodejs"
        "$golang"
        "$java"
        "$kubernetes"
        "$aws"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      # Directory
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      # Git
      git_branch = {
        format = "[$symbol$branch]($style) ";
        style = "bold purple";
        symbol = " ";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style)) ";
        style = "bold red";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "*";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»";
        deleted = "✘";
      };

      # Languages (only show when in relevant project)
      python = {
        format = "[$symbol$version]($style) ";
        style = "yellow";
        symbol = " ";
      };

      nodejs = {
        format = "[$symbol$version]($style) ";
        style = "green";
        symbol = " ";
      };

      golang = {
        format = "[$symbol$version]($style) ";
        style = "cyan";
        symbol = " ";
      };

      java = {
        format = "[$symbol$version]($style) ";
        style = "red";
        symbol = " ";
      };

      # Kubernetes context
      kubernetes = {
        disabled = false;
        format = "[$symbol$context]($style) ";
        style = "bold blue";
        symbol = "⎈ ";
      };

      # AWS profile
      aws = {
        format = "[$symbol$profile]($style) ";
        style = "bold orange";
        symbol = " ";
      };

      # Command duration (only show if > 2 seconds)
      cmd_duration = {
        min_time = 2000;
        format = "took [$duration]($style) ";
        style = "yellow";
      };

      # Prompt character
      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };
    };
  };
}
