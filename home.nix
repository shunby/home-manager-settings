{ config, pkgs, ... }:
let
  username = import ./username.nix;
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = username;
  home.homeDirectory = "/home/${username}";
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.radare2
    pkgs.rp-lin
    pkgs.pwninit
    pkgs.gh
    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-medium collection-langjapanese;
    })
    pkgs.pandoc
    pkgs.bc
    pkgs.nil # nix language server
    pkgs.ffmpeg
    pkgs.python3

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/explosion/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lsah";
      "r2riscv" = "r2 -e asm.arch=riscv";
    };
    initExtra = ''
      # Home/End/Del keybind
      bindkey  "^[[H"   beginning-of-line
      bindkey  "^[[F"   end-of-line
      bindkey  "^[[3~"  delete-char
      
      # enable $EPOCHREALTIME
      zmodload zsh/datetime
      # Define colors for prompt
      autoload -U colors && colors
      PROMPT_COLOR_DIR='%F{cyan}'         # Current directory
      PROMPT_COLOR_STATUS='%F{red}'      # Status code (red if non-zero)
      PROMPT_COLOR_TIME='%F{green}'      # Execution time
      PROMPT_COLOR_RESET='%f'            # Reset to default color

      # Function to display execution time
      function preexec() {
        TIMER_START=$EPOCHREALTIME
      }

      function precmd() {
        local TIMER_END=$EPOCHREALTIME
        local TIMER_DIFF=$(printf "%.2f" $(echo "$TIMER_END - $TIMER_START" | bc -l 2>/dev/null))
        TIMER_DIFF=$(printf "%.2f" "''${TIMER_DIFF:-0}")

        # Display non-zero exit code
        if [[ $? -ne 0 ]]; then
          local STATUS="''${PROMPT_COLOR_STATUS}[$?]''${PROMPT_COLOR_RESET} "
        else
          local STATUS=""
        fi

        # Display execution time only if not 0.00
        if [[ "$TIMER_DIFF" != "0.00" ]]; then
          local TIME_DISPLAY=" ''${PROMPT_COLOR_TIME}[''${TIMER_DIFF}s]''${PROMPT_COLOR_RESET}"
        else
          local TIME_DISPLAY=""
        fi

        # Display python venv
        if [[ -n "$VIRTUAL_ENV" ]]; then
          local VENV_DISPLAY="(venv) "
        else
          local VENV_DISPLAY=""
        fi

        unset PREEXEC_CALLED

        # Build prompt
        PROMPT="''${VENV_DISPLAY}''${STATUS}''${PROMPT_COLOR_DIR}%~''${PROMPT_COLOR_RESET}''${TIME_DISPLAY} %# "
      }

      # Enable the prompt updates
      setopt PROMPT_SUBST
      '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
