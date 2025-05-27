{ description = "zettelkasten";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zeta = {
      url = "github:lentilus/zeta/filetypes";
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
        version = "9c12f535640d8c92c45bd88755a4117f0cf1b015";

        src = pkgs.fetchFromGitHub {
          owner = "lentilus";
          repo  = pname;
          rev   = version;
          hash = "sha256-bzQd2t9lttlNWJOgicchuioILysVpFt30Z3U6pnj32k=";
        };

        cargoHash = "sha256-Z9euToAmOwGo8YpnRDybtuzY3e6oM+gKhYCrY+mq0z8=";
      };
      
      build = pkgs.writeShellScriptBin "build" ''
        root=''${TYPST_ROOT:-.}
        cd "$root"
        ${kodama}/bin/kodama compile --root="$root" --output="$root/../publish" --disable-pretty-urls
      '';

      publish = let
        git = "${pkgs.git}/bin/git";
      in pkgs.writeShellScriptBin "publish" ''
        ${git} add ./trees ./publish
        ${git} commit -m "publish"
        ${git} push
      '';

      serve = pkgs.writeShellScriptBin "serve" ''
        publish=''${TYPST_ROOT:-.}/../publish
        exec ${pkgs.miniserve}/bin/miniserve "$publish" --index-file index.html --launch
      '';

      clean = pkgs.writeShellScriptBin "clean" ''
        root=''${TYPST_ROOT:-.}
        cd "$root"
        ${kodama}/bin/kodama clean --root="$root" --typ --typst
      '';

      watch = pkgs.writeShellScriptBin "watch" ''
        #!/usr/bin/env bash
        root=''${TYPST_ROOT:-.}
        export TYPST_ROOT=$TYPST_ROOT
        publish="$root/../publish"
        cd "$root"

        # initial build
        build

        ${pkgs.nodePackages.live-server}/bin/live-server "$publish" --entry-file=index.html &
        server_pid=$!

        start_server
        trap "kill $server_pid" EXIT INT TERM

        # watch for filesystem events and rebuild+restart
        while ${pkgs.inotify-tools}/bin/inotifywait -e modify,create,delete "$root"; do
          build
        done
      '';

      increment = pkgs.writeShellScriptBin "increment" (builtins.readFile ./new.sh);
    in pkgs.mkShell {
      buildInputs = [
        pkgs.typst
        pkgs.tinymist
        pkgs.nodejs
        pkgs.miniserve

        inputs.zeta.packages.${system}.zeta
        kodama
        build
        clean
        serve
        publish
        increment
        watch
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
