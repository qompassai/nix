{
  config,
  pkgs,
  username,
  ...
}: {
  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = config.gitUsername;
      extraGroups = [
        "audio"
        "input"
        "networkmanager"
        "libvirtd"
        "lp"
        "scanner"
        "render"
        "video"
        "wheel"
      ];
      shell = pkgs.bash;
      packages = with pkgs; [];
    };
  };
  users.defaultUserShell = pkgs.bash;
  environment.shells = with pkgs; [zsh bashInteractive];
  environment.systemPackages = with pkgs; [lsd fzf];
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      ohMyZsh = {
        enable = true;
        plugins = ["git"];
        theme = "agnoster";
      };
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      promptInit = ''
        fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc
        alias ls='lsd'
        alias l='ls -l'
        alias la='ls -a'
        alias lla='ls -la'
        alias lt='ls --tree'
        source <(fzf --zsh)
        HISTFILE=~/.zsh_history
        HISTSIZE=10000
        SAVEHIST=10000
        setopt appendhistory
      '';
    };
  };
}
