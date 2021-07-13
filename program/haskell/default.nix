{ pkgs, ... }:
let
  sources = import ./../../nix/sources.nix;

  in with { overlay = _: pkgs:
    { niv = (import sources.niv {}).niv;
    };
  };

let
   nixpkgs = sources."nixpkgs-haskell-updates";

   pkgs = import nixpkgs {
     overlays = [
  (self: super: {
    # https://discourse.nixos.org/t/nix-haskell-development-2020/6170/2
    haskellPackages = super.haskellPackages.override {
      overrides = hself: hsuper: rec {
        mkDerivation = args: hsuper.mkDerivation (args // {
          doCheck = false;
          doHaddock = false;
          dontStrip = true;
          #enableLibraryProfiling = false;
          #enableExecutableProfiling = false;
          jailbreak = true;
        });
      };
    };
  })
    ]; config = {};
  };
in {
  # finding out haskell compiler version to use a compatible one, i. e. ghc88x:
  # ```sh
  # nix-env -f "<nixpkgs>" -qaP -A haskell.compiler
  # ```
  home.packages = with pkgs.haskellPackages; with pkgs.lib.trivial; with pkgs.haskell.lib; /*with pkgs.haskell.packages.ghc884;*/ /*let hledgerrepo = builtins.fetchTarball "https://github.com/simonmichael/hledger/archive/b203822cd15aae1b2009d0f3e737b740c0d6f073.tar.gz"; in*/ [
    #(justStaticExecutables (dontCheck (doJailbreak cachix))) # building with default ghc (8.10.4) in nixpkgs, revision e68dfcb4a53c8abad243d4e2f06079b56a8bcf38 breaks with "ghc-pkg: Couldn't open database /tmp/nix-build-Diff-0.4.0.drv-0/setup-package.conf.d for modification: {handle: /tmp/nix-build-Diff-0.4.0.drv-0/setup-package.conf.d/package.cache.lock}: hLock: invalid argument (Invalid argument)" https://paste.c-net.org/16af6c0b-022f-8898-1368-82d5aca82d79 
#    (justStaticExecutables (dontCheck (doJailbreak git-annex)))
#    (justStaticExecutables (dontCheck (doJailbreak hledger)))
#    (justStaticExecutables (dontCheck (doJailbreak hledger-ui)))
#    (justStaticExecutables (dontCheck (doJailbreak hledger-web)))
#    (justStaticExecutables (dontCheck (doJailbreak ShellCheck)))
#    (pkgs.haskell.lib.overrideSrc pkgs.hledger-ui {
#          src = "${hledger}/hledger-ui";
#              version = "unstable";
#                })
    ###(import neuronSrc {}) # TODO Use the bundle
    #        (override {
    #          overrides = se: su: {
    # https://github.com/NixOS/nixpkgs/blob/32c8e793bce08a7ec53c9da4d3924a681173c1e0/pkgs/development/haskell-modules/lib.nix#L60
    #servant-auth-server = dontCheck (doJailbreak su.servant-auth-server);
    #cachix-api-test = dontCheck (doJailbreak su.cachix-api-test);
    #            cachix-api = dontCheck (doJailbreak su.cachix-api);
    #          };
    #        }).cachix)
  ];

  #systemd.user.services.neuron = let
  #  zettels_path = "${config.home.homeDirectory}/meinzettelkasten";
  #in {
  #  Unit.Description = "Serve zettelkasten";
  #  Install.WantedBy = [ "default.target" ];
  #  Service = {
  #    ExecStart = "${(import neuronSrc {})}/bin/neuron -d ${zettels_path} rib -wS";
  #  };
  #};
}
