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
    # also this seems to be needed for pypiData*, https://github.com/DavHau/mach-nix/issues/269#issuecomment-841825674
    python = "python38";
    # pypiDataRev = "441e9fa6045d43c343f5483c842a1dd127a1fa5e";
    pypiDataRev = "441e9fa6045d43c343f5483c842a1dd127a1fa5e";           #
    pypiDataSha256 = "1xr5xla2h0x84n9lkkjfmjkphnnjp5wsnw786him5n1imjv740i6";
  };

  # load your requirements
  machNix = mach-nix.mkPython rec {
    requirements = ''
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

  jupyter = import (builtins.fetchGit {
    url = "https://github.com/${sources.jupyterWith.owner}/${sources.jupyterWith.repo}";
    ref = sources.jupyterWith.branch;
    rev = sources.jupyterWith.rev;
  }) {};

  iPython = jupyter.kernels.iPythonWith {
    name = "mach-nix-jupyter";
    python3 = machNix.python;
    packages = machNix.python.pkgs.selectPkgs;
  };

  jupyterEnvironment = jupyter.jupyterlabWith {
    kernels = [ iPython ];
  };
in
  jupyterEnvironment.env
