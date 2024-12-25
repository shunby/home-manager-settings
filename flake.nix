{
  description = "Home Manager configuration of explosion";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nekopkgs = {
      url = "github:shunby/neko-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, nekopkgs, ... }:
    let
      system = "x86_64-linux";
      overlays = [(self: super: nekopkgs.packages.${system})];
      pkgs = import nixpkgs {inherit system overlays;};
      username = import ./username.nix;
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
