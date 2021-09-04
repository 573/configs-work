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
  in pkgs.poetry2nix.mkPoetryApplication rec {
  inherit (pkgs) python3;
  projectDir = src;

  #overrides = pkgs.poetry2nix.overrides.withDefaults(self: super: {
  #  keyring = super.keyring.overridePythonAttrs(old: {
  #    postPatch = ''
  #      substituteInPlace setup.py --replace 'setuptools.setup()' 'setuptools.setup(version="${old.version}")'
  #    '';
  #    propagatedBuildInputs = old.propagatedBuildInputs ++ [ self.toml ];
  #  });
  #});

  src = pkgs.fetchFromGitHub {
    owner = sources.jrnl.owner;
    repo = sources.jrnl.repo;
    rev = sources.jrnl.rev;
    sha256 = sources.jrnl.sha256;
  };
  doCheck = false;
  doInstallCheck = false;
  dontUseSetuptoolsCheck = true;
  pythonImportsCheck = [ ];
}

