{ description = "zettelkasten";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zeta = {
      url = "github:lentilus/zeta";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    scribe = {
      url = "github:lentilus/typst-scribe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    system = "x86_64-linux";
    pkgs   = import nixpkgs { inherit system; };

  in {
    devShells.${system}.default = let
      scribe   = inputs.scribe.packages.${system}.default;
      ctheorem = pkgs.typstPackages.ctheorems;
      kodama   = pkgs.rustPlatform.buildRustPackage rec {
        pname = "kodama";
        version = "541bfffa3e31f6150ed6922e490d7dca00798cb2";

        src = pkgs.fetchFromGitHub {
          owner = "kokic";
          repo  = pname;
          rev   = version;
          hash = "sha256-duzvvNbxSmqddX3K+ICDCejrXZaF4v4kVowZUtRPjJA=";
        };

        cargoHash = "sha256-GKwD/f2oEq01g99JmYXQpLpxz5UsvB91fh/zrxNIuMs=";
      };

      ankiexport = pkgs.stdenv.mkDerivation {
        name = "genanki";
        propagatedBuildInputs = [
          (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
            genanki
          ]))
        ];
        dontUnpack = true;
        installPhase = "install -Dm755 ${./genanki.py} $out/bin/ankiexport";
      };
      
      build = pkgs.writeShellScriptBin "build" ''
        ${kodama}/bin/kodama build
      '';

      publish = let
        git = "${pkgs.git}/bin/git";
      in pkgs.writeShellScriptBin "publish" ''
        ${git} add ./trees ./publish
        ${git} commit -m "publish"
        ${git} push
      '';

      serve = pkgs.writeShellScriptBin "serve" ''
        ${kodama}/bin/kodama serve
      '';

      increment = pkgs.writeShellScriptBin "increment" (builtins.readFile ./new.sh);
    in pkgs.mkShell {
      buildInputs = [
        pkgs.typst
        pkgs.tinymist
        pkgs.nodejs
        pkgs.miniserve
        (pkgs.agda.withPackages (ps: [
              ps.standard-library
              ps.cubical
            ]))

        inputs.zeta.packages.${system}.zeta
        kodama
        build
        serve
        publish
        increment
        ankiexport
      ];

      shellHook = ''
        FLAKE_ROOT="$(git rev-parse --show-toplevel)"
        export TYPST_ROOT=$FLAKE_ROOT/trees
        export TYPST_FEATURES="html"

        CACHE_DIR="$FLAKE_ROOT/.typst-cache"
        if [ ! -d "$CACHE_DIR" ]; then
          mkdir -p "$CACHE_DIR/preview"
          cp -r ${scribe}/lib/typst-packages/* "$CACHE_DIR/preview/"
        fi
        export TYPST_PACKAGE_CACHE_PATH="$CACHE_DIR"
      '';
    };
  };
}
