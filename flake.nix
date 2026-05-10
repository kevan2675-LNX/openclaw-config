{
  description = "My local declarative OpenClaw agent";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Ambil home-manager langsung dari upstream biar fungsinya pas
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Official OpenClaw Nix package
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    nix-openclaw.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, nix-openclaw, ... }: {
    homeConfigurations."vashlinux@nixos" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        nix-openclaw.homeManagerModules.openclaw
        
        ({ config, pkgs, ... }: {
          home.username = "vashlinux";
          home.homeDirectory = "/home/vashlinux";
          home.stateVersion = "25.11"; 

          programs.openclaw = {
            enable = true;
            documents = ./documents; # Di sinilah Personality.md & Heartbeat.md kamu dibaca!
            config = {
              gateway = {
                mode = "local";
              };
              env.vars = {
                GEMINI_API_KEY_FILE = "/home/vashlinux/.secrets/gemini-api-key";
              };
            };
          };
        })
      ];
    };
  };
}
