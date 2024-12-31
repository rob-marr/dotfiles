{
  description = "πbook air Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util.url = "github:hraban/mac-app-util";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, mac-app-util, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, home-manager, nixpkgs }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = [
        pkgs.alacritty
        pkgs.gnupg
        pkgs.mkalias
        pkgs.neovim
        pkgs.nixd
        pkgs.pinentry_mac
        pkgs.tmux
        pkgs.spotify
      ];

      users.users.rob = {
        home = /Users/rob;
      };

      homebrew = {
        enable = true;
        casks = [
          "chatgpt"
          "elgato-camera-hub"
          "firefox"
          "iina"
          "proton-drive"
          "rambox"
          "zed"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      system.defaults = {
        NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain.AppleTemperatureUnit = "Celsius";
        dock.autohide = true;
        dock.persistent-apps = [
            "/Applications/Rambox.app"
            "${pkgs.alacritty}/Applications/Alacritty.app"
            "/Applications/Firefox.app"
            "/Applications/Zed.app"
            "${pkgs.spotify}/Applications/Spotify.app"
        ];
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#pibook
    darwinConfigurations."pibook" = nix-darwin.lib.darwinSystem {
      modules = [
        # fix `Error: Refusing to untap` https://github.com/zhaofengli/nix-homebrew/issues/5
        ({ config, ... }: {
            homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
        })
        configuration
        home-manager.darwinModules.home-manager
        {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.rob = import ./home.nix;
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
            ];
        }
        mac-app-util.darwinModules.default
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "rob";
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
            mutableTaps = true;
          };
        }
      ];
      specialArgs = { inherit inputs; };
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."pibook".pkgs;
  };
}
