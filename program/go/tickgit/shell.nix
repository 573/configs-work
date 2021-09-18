{pkgs ? import <nixpkgs> {}}:
let
  sources = import ./../../../nix/sources.nix;

  in with { overlay = _: pkgs:
    { niv = (import sources.niv {}).niv;
    };
  };
let
   nixpkgs = sources."nixpkgs";

   pkgs = import nixpkgs {
     overlays = [
       overlay
       (import "${builtins.fetchTarball {
          url = "https://github.com/${sources.gomod2nix.owner}/${sources.gomod2nix.repo}/archive/${sources.gomod2nix.rev}.tar.gz";
          sha256 = sources.gomod2nix.sha256;
        }}/overlay.nix")
    ]; config = {};
  };
  # for available attrs check
  # nix-repl> :l default.nix
  # nix-repl> out.drvAttrs
in pkgs.stdenv.mkDerivation rec {
  name = "tickgit-env";
  src = builtins.fetchGit{
            url = "https://github.com/augmentable-dev/tickgit";
            ref = "master";
            rev = "9d0b1519973da3a4f50d45ca8bdcdf7e70638e75";
       };
  buildInputs = [ pkgs.git pkgs.gomod2nix ];
}
