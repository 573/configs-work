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
    ]; config = {};
  };
  # for available attrs check
  # nix-repl> :l default.nix
  # nix-repl> out.drvAttrs
in pkgs.stdenv.mkDerivation {
  name = "naps62-zk";

  src = builtins.fetchGit{
      url = "https://github.com/naps62/zk";
      ref = "master";
      rev = "d8f7ab926c188a44783764951065050f8af12ec1";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];

    builder = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup

      installPhase() {
        mkdir -p "$out/bin"
        ln -s "$src/bin/zk" \
            "$out/bin"
        sed -i "s:#!/bin/sh:#!${pkgs.coreutils}/bin/env bash:g" \
            "$out/bin/zk"
        wrapProgram "$out/bin/zk" \
            --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ripgrep pkgs.fzf ]}

        mkdir -p "$out/libexec"
        pushd "$src/libexec"
        for i in *; do
          ln -s "$src/libexec/$i" "$out/libexec"
#          sed -i "s:#!/bin/sh:#!${pkgs.coreutils}/bin/env bash:g" \
#            "$out/libexec/$i"
#          wrapProgram "$out/libexec/$i" \
#              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ripgrep pkgs.fzf ]}
        done
        popd
      }

      genericBuild
      '';
}
