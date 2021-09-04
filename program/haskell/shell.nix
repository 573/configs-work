{ sources ? import ./../../nix/sources.nix }:
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
    { compiler.ghc884 =
      (super.haskell.compiler.ghc884.override
        { enableRelocatedStaticLibs = true;
          enableIntegerSimple = true;
          enableShared = false;
        }).overrideAttrs (old:
        { preConfigure = ''
            ${old.preConfigure or ""}
            echo "GhcLibHcOpts += -fPIC -fexternal-dynamic-refs" >> mk/build.mk
            echo "GhcRtsHcOpts += -fPIC -fexternal-dynamic-refs" >> mk/build.mk
          '';
        });
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
  })
    ]; config = {};
  };
in pkgs.mkShell {
  buildInputs = with pkgs.haskell.packages.ghc884; with pkgs.haskell.compiler.ghc884; [
    cryptonite
  ];
}
