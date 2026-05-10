#(1) BLOK UTAMA FLAKE
{
  description = "My local declarative OpenClaw agent";

  #(2) BLOK SUMBER (INPUTS)
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Ambil home-manager langsung dari upstream biar fungsinya pas
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Official OpenClaw Nix package
    nix-openclaw.url = "github:openclaw/nix-openclaw";
    nix-openclaw.inputs.nixpkgs.follows = "nixpkgs";
  }; # Menutup daftar sumber file luar

  #(3) BLOK OUTPUTS (Hasil Racikan)
  outputs = { self, nixpkgs, home-manager, nix-openclaw, ... }: {

    #(4) BLOK DEFINISI TARGET
    homeConfigurations."vashlinux@nixos" = home-manager.lib.homeManagerConfiguration {

      #(5) BLOK IMPORT & ATURAN PAKET
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "openclaw-2026.4.22"
          ];
        };
      }; # Menutup pengaturan sistem paket (pkgs)

      #(6) BLOK DAFTAR MODUL AKTIF
      modules = [
        nix-openclaw.homeManagerModules.openclaw

        #(7) BLOK KONFIGURASI USER (LOKAL)
        ({ config, pkgs, lib, ... }: {
          home.username = "vashlinux";
          home.homeDirectory = "/home/vashlinux";
          home.stateVersion = "25.11";

	# TAMBAHKAN INI: Sediakan NodeJS dan NPM secara global untuk user kamu
          home.packages = [
            pkgs.nodejs
          ];

	#SUNTIKKAN API KEY LANGSUNG KE SERVICE OPENCLAW (CARA PALING AMPUH!)
          systemd.user.services.openclaw-gateway = {
            Service = {
              Environment = [
                "GEMINI_API_KEY=AIzaSyCtbn8gJrQWfeSNV7Jj-3ONuCS-t0i1Y6Y"
                "GOOGLE_API_KEY=AIzaSyCtbn8gJrQWfeSNV7Jj-3ONuCS-t0i1Y6Y"
              ];
            };
          };



	# TRICK UTAMA: Salin API key sebagai file fisik murni pasca-aktivasi
          home.activation = {
            setupOpenclawAuth = lib.hm.dag.entryAfter ["writeBoundary"] ''
              # Buat direktori tujuan jika belum ada
              mkdir -p /home/vashlinux/.openclaw/agents/main/agent

              # Hapus paksa jika ada symlink macet di sana
              rm -f /home/vashlinux/.openclaw/agents/main/agent/auth-profiles.json

              # Salin file aslinya secara fisik agar bukan berbentuk symlink!
              cat /home/vashlinux/.secrets/gemini-api-key | read key
              echo "{\"google\":{\"apiKey\":\"$key\"}}" > /home/vashlinux/.openclaw/agents/main/agent/auth-profiles.json
              
              # Kunci aksesnya agar tidak sengaja diobrak-abrik OpenClaw
              chmod 600 /home/vashlinux/.openclaw/agents/main/agent/auth-profiles.json
            '';
          };


          #(8) BLOK KONFIGURASI KHUSUS APLIKASI
          programs.openclaw = {
            enable = true;
            documents = ./documents; # Di sinilah SOUL.md, AGENTS.md, & TOOLS.md kamu dibaca

            #(9) BLOK PARAMETER INTERNAL APLIKASI
            config = {
              gateway = {
                mode = "local";
              };

              agents = {
                defaults = {
                  model = "google/gemini-1.5-pro"; # Kunci ke jenis Gemini Pro
                };
              };

              # CARA PAMUNGKAS: Masukkan variable lingkungan agar dibaca otomatis oleh gateway
              env.vars = {
                GEMINI_API_KEY_FILE = "/home/vashlinux/.secrets/gemini-api-key";
                GOOGLE_API_KEY_FILE = "/home/vashlinux/.secrets/gemini-api-key";
              };
            }; # Menutup config (9)
          }; # Menutup programs.openclaw (8)
        }) # Menutup inline module (7)
      ]; # Menutup daftar modul (6)
    }; # Menutup homeConfigurations (4)
  }; # Menutup outputs (3)
} # Menutup flake (1)
