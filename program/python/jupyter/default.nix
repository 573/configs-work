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
	  (self: super:
	  {
	  })
    ]; config = {};
  };
  mach-nix = import (pkgs.fetchFromGitHub {
    owner = sources.mach-nix.owner;
    repo = sources.mach-nix.repo;
    rev = sources.mach-nix.rev;
    sha256 = sources.mach-nix.sha256;
  }) {
    # https://github.com/DavHau/mach-nix/blob/3.0.2/examples.md#import-mach-nix
    # python = "python37";
    # pypiDataRev = "441e9fa6045d43c343f5483c842a1dd127a1fa5e";
  };
  pyEnvForJupyter = mach-nix.mkPython rec {
    requirements =  ''
        jupyterlab
        geopandas
        pyproj
        pygeos
        shapely>=1.7.0
        agentpy
        seaborn
      '';

    providers.shapely = "sdist,nixpkgs";
  };
in
  mach-nix.nixpkgs.mkShell {
    buildInputs = [ pyEnvForJupyter ];

    shellHook = ''
    jupyter lab --notebook-dir=~/
  '';
  }
