
{ config, pkgs, ... }:

{

  home.username = "rob";
  xdg.enable = true;
  home.stateVersion = "25.05";

  # Makes sense for user specific applications that shouldn't be available system-wide
  home.packages = [
  ];

  # # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # # plain files is through 'home.file'.
  # home.file = {
  #   ".zshrc".source = ~/Projects/dotfiles/.zshrc;
  #   ".config/nix".source = ~/Projects/dotfiles/nix;
  #   ".config/zed".source = ~/Projects/dotfiles/zed;
  # };

  # home.sessionVariables = {
  # };

  # home.sessionPath = [
  #   "/run/current-system/sw/bin"
  #   "$HOME/.nix-profile/bin"
  # ];
  # programs.home-manager.enable = true;
  # programs.zsh = {
  #   enable = true;
  #   initExtra = ''
  #     # Add any additional configurations here
  #     export PATH=/run/current-system/sw/bin:$HOME/.nix-profile/bin:$PATH
  #     if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  #       . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
  #     fi
  #   '';
  # };
  programs.home-manager.enable = true;
}
