{
  description = "haskell.nix#1339";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.haskellNix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  inputs.a.url = "github:angerman/hs.nix-1339-a";
  inputs.a.flake = false;

  outputs = { self, haskellNix, nixpkgs, flake-utils, a }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let pkgs = haskellNix.legacyPackages.${system}; in
      let proj = pkgs.haskell-nix.project {
        compiler-nix-name = "ghc8107";
        index-state = "2022-01-10T00:00:00Z";
        src = pkgs.haskell-nix.haskellLib.cleanGit {
          name = "haskell.nix-1339-example";
          src = ./.;
        };
	# For this to work it is *essential* that we have a local `cabal.project` file.
        # It think this could be considered a bug in haskell.nix to ignore the cabalProjectLocal
        # if no cabal.project file was found.
        cabalProjectLocal = ''
        packages:
          ${a}
        '';
        modules = [{ packages.a.src = a.outPath; }];
      }; in {
        packages.b = proj.b.components.exes.b; 
      }
    );
}
