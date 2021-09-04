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

  # might be wrong, see https://github.com/NixOS/nixpkgs/blob/1248f5ac43d2f6d7975f872395a2fc0cca821b51/pkgs/applications/version-management/gitlab/default.nix
  rubyEnv = pkgs.bundlerEnv rec {
    name = "zk-sqlite3";
    inherit (pkgs) ruby;
    gemdir = ./.;
    gemset =
      let x = import (gemdir + "/gemset.nix");
      in x // {
        # sqlite3 needs openssl include files and cacert
        sqlite3 = x.sqlite3 // {
          buildInputs = [ pkgs.openssl ];
          nativeBuildInputs = [ pkgs.cacert ];
        };
      };
  };

  # for available attrs check
  # nix-repl> :l default.nix
  # nix-repl> out.drvAttrs
in pkgs.stdenv.mkDerivation {
  name = "sirupsen-zk";

  src = builtins.fetchGit{
      url = "https://github.com/sirupsen/zk";
      ref = "master";
      rev = "e30732162ed63038706ebcdc45d6ec954560ceb4";
    };

    buildInputs = [ rubyEnv rubyEnv.wrappedRuby rubyEnv.bundler ];

    nativeBuildInputs = [ pkgs.makeWrapper rubyEnv.wrappedRuby rubyEnv.bundler ];

    builder = pkgs.writeScript "builder.sh" ''
      source $stdenv/setup

      installPhase() {
        mkdir -p "$out/bin"
        pushd "$src/bin"
        for i in *; do
          ln -s "$src/bin/$i" "$out/bin"
          sed -i "s:#!/bin/sh:#!${pkgs.coreutils}/bin/env bash:g" \
            "$out/bin/$i"
          wrapProgram "$out/bin/$i" \
              --prefix PATH : ${pkgs.lib.makeBinPath [ pkgs.ripgrep pkgs.fzf pkgs.bat pkgs.coreutils-prefixed.out (pkgs.python3.withPackages (python-packages: with python-packages; [ scikit-learn pandas ])) ]};
        done
        popd
      }

      genericBuild
      '';
}
