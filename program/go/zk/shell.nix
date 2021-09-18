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
  name = "zk-env";
  src = builtins.fetchGit{
            url = "https://github.com/mickael-menu/zk";
            ref = "better-wikilinks";
            rev = "41c451b2ca935b1ce61ed85583ec3c8a286deba4";
       };
  buildInputs = [ pkgs.git pkgs.gomod2nix ];
}
