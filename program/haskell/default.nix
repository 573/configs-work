{ pkgs, ... }:
let
  sources = import ./../../nix/sources.nix;

  in #with { overlay = _: pkgs:
#    { niv = (import sources.niv {}).niv;
#    };
#  };

let
   overlay = _: pkgs:
    { niv = (import sources.niv {}).niv;
  };

   nixpkgs = sources."nixpkgs-haskell-updates";

   pkgs = import nixpkgs {
     overlays = [
       overlay
  (self: super: {
   haskell = self.lib.recursiveUpdate super.haskell
    { #compiler.ghc884 =
      #(super.haskell.compiler.ghc884.override
      #  { enableRelocatedStaticLibs = true;
      #    enableIntegerSimple = true;
      #    enableShared = false;
      #  }).overrideAttrs (old:
      #  { preConfigure = ''
      #      ${old.preConfigure or ""}
      #      echo "GhcLibHcOpts += -fPIC -fexternal-dynamic-refs" >> mk/build.mk
      #      echo "GhcRtsHcOpts += -fPIC -fexternal-dynamic-refs" >> mk/build.mk
      #    '';
      #  });
      #compiler.ghc8104 =
      #(super.haskell.compiler.ghc8104.override
      #  { enableRelocatedStaticLibs = true;
      #    enableIntegerSimple = true;
      #    enableShared = false;
      #  }).overrideAttrs (old:
      #  { preConfigure = ''
      #      ${old.preConfigure or ""}
      #      echo "GhcLibHcOpts += -fPIC -fexternal-dynamic-refs" >> mk/build.mk
      #      echo "GhcRtsHcOpts += -fPIC -fexternal-dynamic-refs" >> mk/build.mk
      #    '';
      #  });
      packages.ghc8104 =
      (super.haskell.packages.ghc8104.override # see https://github.com/NixOS/nixpkgs/issues/26561#issuecomment-397350884
        (old: { overrides = super.lib.composeExtensions (old.overrides or (_: _: {})) (hself: hsuper: rec {
          mkDerivation = args: hsuper.mkDerivation (args // {
            # https://github.com/NixOS/nixpkgs/blob/52b2fec43ba8d39c003627fe5f7fa59195bd40f2/pkgs/development/haskell-modules/lib.nix#L168-L169
          doCheck = false;
          doHaddock = false;
          enableLibraryProfiling = false;
        });
      });
    }));
      packages.ghc884 =
      (super.haskell.packages.ghc884.override
        (old: { overrides = super.lib.composeExtensions (old.overrides or (_: _: {})) (hself: hsuper: rec {
        mkDerivation = args: hsuper.mkDerivation (args // {
          doCheck = false;
          doHaddock = false;
          enableLibraryProfiling = false;
        });
        });
      }));
    };

#    # https://discourse.nixos.org/t/nix-haskell-development-2020/6170/2
#    haskellPackages = super.haskell.packages.ghc884.override {
#      overrides = hself: hsuper: rec {
#        mkDerivation = args: hsuper.mkDerivation (args // {
#          doCheck = false;
#          doHaddock = false;
#          jailbreak = true;
#        });
#      };
#    };
  })
    ]; config = {};
  };
in {
  # finding out haskell compiler version to use a compatible one, i. e. ghc88x:
  # ```sh
  # nix-env -f "<nixpkgs>" -qaP -A haskell.compiler
  # ```
  home.packages = /*with pkgs.haskellPackages;*/ /*with pkgs.lib.trivial; with pkgs.haskell.lib;*/ /* this is commented out as we use the overridden pkgs from the overlay now: */ with pkgs.haskell.packages.ghc884; with pkgs.haskell.compiler.ghc884; /*let hledgerrepo = builtins.fetchTarball "https://github.com/simonmichael/hledger/archive/b203822cd15aae1b2009d0f3e737b740c0d6f073.tar.gz"; in*/ [
    #pkgs.haskell.packages.ghc8104.git-annex
    #pkgs.haskell.packages.ghc8104.neuron
#    (justStaticExecutables (dontCheck (doJailbreak hledger-ui)))
#    (justStaticExecutables (dontCheck (doJailbreak hledger-web)))
    ShellCheck

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
    #neuron # rib-core needs base ==4.13.0.0 (ghc884)
    #git-annex # base >=4.13 (ghc884)
  ] ++ (with pkgs.haskell.packages.ghc8104; with pkgs.haskell.compiler.ghc8104; [
    hledger
  ]);

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
