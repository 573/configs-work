/*{
  # `git ls-remote https://github.com/nixos/nixpkgs-channels nixos-unstable`
  nixpkgs-rev ? "3e7fae8eae52f9260d2e251d3346f4d36c0b3116"
, nixpkgs-ref ? "refs/heads/nixpkgs-unstable"
, pkgsPath ? builtins.fetchGit {
    name = "nixpkgs-${nixpkgs-rev}";
    url = "https://github.com/nixos/nixpkgs/";
    rev = "${nixpkgs-rev}";
    ref = "${nixpkgs-ref}";
  }
, pkgs ? import pkgsPath { }
# oder pkgs.stdenv.hostPlatform.isAarch64 ?
, extraFeatures ? !(pkgs.stdenv.isAarch64) [
    "dbus"
    "inotify"
  ]
  , lib
  , ...
}:*/
#{ pkgs, lib, ... }:
{pkgs, config, ...}:
let
  sources = import ./../../nix/sources.nix;

  in with { overlay = _: pkgs:
    { niv = (import sources.niv {}).niv;
    };
  };
with config;
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
#with lib;
#let
  mach-nix = import (pkgs.fetchFromGitHub {
    owner = sources.mach-nix.owner;
    repo = sources.mach-nix.repo;
    rev = sources.mach-nix.rev;
    sha256 = sources.mach-nix.sha256;
  }) {
    # https://github.com/DavHau/mach-nix/blob/3.0.2/examples.md#import-mach-nix
    python = "python37";
  };
  pyEnvForJupyter = mach-nix.mkPython rec {
    requirements =  ''
        jupyterlab
        geopandas
        pyproj
        pygeos
        shapely>=1.7.0
      '';

    providers.shapely = "sdist,nixpkgs";
  };
  nix-bisect = mach-nix.buildPythonPackage {
    src = sources.nix-bisect.url;
    #extras = "appdirs,numpy,pexpect";
    doCheck = false;
    doInstallCheck = false;
    dontUseSetuptoolsCheck = true;
    pythonImportsCheck = [ ];
  };
  jrnl = mach-nix.buildPythonApplication rec {
    # see https://github.com/DavHau/mach-nix/issues/128
    #  src = "https://github.com/jrnl-org/jrnl/tarball/release";
    version = sources.jrnl.version;
    pname = sources.jrnl.repo;
    src = mach-nix.nixpkgs.python3Packages.fetchPypi {
      inherit pname version;
      sha256 = sources.jrnl.sha256; # "a5f069efcaa3f5d95cc7712178b3f92915f67eed4034e5f257cc063c6b0e74d9";
    };
    doCheck = false;
    doInstallCheck = false;
    dontUseSetuptoolsCheck = true;
    pythonImportsCheck = [ ];
  # &q=pyproject.toml+requirements+comparison+operator+caret, i. e. ^2.7 in pyproject.toml translates to <3.0,>=2.7 in setuptools
    requirements = ''
      pyxdg<0.27,>=0.26.0
      cryptography<3.0,>=2.7
      passlib<1.8,>=1.7
      parsedatetime<2.5,>=2.4
      keyring>19.0,<22.0
      pytz>=2019.1,<2021.0
      tzlocal>1.5,<3.0
      asteval<0.10,>=0.9.14
      colorama<0.5,>=0.4.1
      python-dateutil<2.9,>=2.8
      pyyaml<5.2,>=5.1
      ansiwrap<0.9,>=0.8.4
      packaging<20.5,>=20.4
      # development
      behave<1.3,>=1.2
      mkdocs<1.1,>=1.0
      black<19.11,>=19.10b0
      toml<0.11,>=0.10.0
      pyflakes<2.3,>=2.2.0
      pytest<5.5,>=5.4.3
    '';
    providers = {
      setuptools-scm = "nixpkgs";
    };
  };
  myMachnix = mach-nix.mkPython {
    requirements = ''
      # nix-bisect # braucht eigene Derivation ist weder auf nixpkgs noch pypi (that's why)

      #jrnl
      dropbox
      # for dropbox updown: https://github.com/jjssoftware/asustor-dropbox/blob/master/bin/updown.py
      lockfile
      setuptools

      # springer_free_books download reqs
      #curlify
      #openpyxl
      #xlrd
      #tqdm
      requests
      # pandas already on requirements

      # for emacs, also https://nixos.wiki/wiki/Vim#Vim_as_a_Python_IDE
      #python-language-server

      # https://github.com/DavHau/mach-nix/issues/24
      #pyls-mypy
      #pyls-isort
      #pyls-black # generates duplicate-error

      # proselint, a linter for English prose.
      #proselint
    ''
    + pkgs.lib.optionalString (!pkgs.stdenv.isAarch64) ''
      #pygobject
      #dbus-python
      #gst-python
    ''
    ;

    providers = {
      # python-jsonrpc-server seems to cause a strange bug when installing from pypi.
      # We change its provider to nixpkgs
      #python-mypy = "nixpkgs";
      #python-isort = "nixpkgs";
      #python-black = "nixpkgs";
      python-jsonrpc-server = "nixpkgs";
      setuptools-scm = "nixpkgs";
      cffi = "nixpkgs";
    };
    overridesPost = [
      (
        pythonSelf: pythonSuper: {
          pyls-mypy = pythonSuper.pyls-mypy.overrideAttrs (oa: {
            patches = [ ];
          });
        }
      )
    ];
  };
  #dbusPackages = with pkgs; [
  #  gst_all_1.gstreamer
  #  gtk3
  #];
in
{
  home.packages = with pkgs; [
    #jrnl
    #nix-bisect
    pyEnvForJupyter 
    #myMachnix
  ]
  ++ lib.optionals (!pkgs.stdenv.isAarch64) (with pkgs; [
    #gst_all_1.gstreamer
    #gtk3
  ])
  ;

  systemd.user.sockets.dbus = {
    Unit = {
      Description = "D-Bus User Message Bus Socket";
    };
    Socket = {
      ListenStream = "%t/bus";
      ExecStartPost = "${pkgs.systemd}/bin/systemctl --user set-environment DBUS_SESSION_BUS_ADDRESS=unix:path=%t/bus";
    };
    Install = {
      WantedBy = [ "sockets.target" ];
      Also = [ "dbus.service" ];
    };
  };

  systemd.user.services.dbus = {
    Unit = {
      Description = "D-Bus User Message Bus";
      Requires = [ "dbus.socket" ];
    };
    Service = {
      ExecStart = "${pkgs.dbus}/bin/dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation";
      ExecReload = "${pkgs.dbus}/bin/dbus-send --print-reply --session --type=method_call --dest=org.freedesktop.DBus / org.freedesktop.DBus.ReloadConfig";
    };
    Install = {
      Also = [ "dbus.socket" ];
    };
  };

  # https://serverfault.com/questions/892465/starting-systemd-services-sharing-a-session-d-bus-on-headless-system
  systemd.user.services.test-dbus = {
    Unit = {
      Description = "Example Service to test D-Bus";
      Requires = [ "dbus.socket" ];
    };
    Service = {
      Type = "dbus";
      ExecStart = "${config.home.homeDirectory}/test-dbus.py";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file = {
    "test-dbus.py" = {
      text = ''
        #!${pkgs.coreutils}/bin/env python3
        # This file is ${config.home.homeDirectory}/test-dbus.py
        # Remember to make it executable if you want dbus to launch it
        # It works with both Python2 and Python3

        import dbus
        import dbus.service
        from gi.repository import GLib
        from dbus.mainloop.glib import DBusGMainLoop

        class MyDBUSService(dbus.service.Object):
            def __init__(self):
                bus_name = dbus.service.BusName('org.me.test', bus=dbus.SessionBus())
                dbus.service.Object.__init__(self, bus_name, '/org/me/test')

            @dbus.service.method('org.me.test')
            def hello(self):
                mainloop.quit() # terminate after running. daemons don't use this
                return "Hello,World!"

            @dbus.service.method('org.me.test')
            def Exit(self):
                mainloop.quit()

        DBusGMainLoop(set_as_default=True)
        myservice = MyDBUSService()
        mainloop = GLib.MainLoop()
        mainloop.run()
      '';
      executable = true;
    };

    "bin/orgzlysync.py" = {
      source = pkgs.runCommand "orgzlysync.py"
        {
          input = pkgs.fetchFromGitHub {
            owner = sources.asustor-dropbox.owner;
            repo = sources.asustor-dropbox.repo;
            rev = sources.asustor-dropbox.rev;
            sha256 = sources.asustor-dropbox.sha256;
          } + "/bin/updown.py";
        } ''
        sed -e "s!import locale!#import locale!g" \
        -e "s!locale.setlocale!#locale.setlocale!g" \
        -e "s!log_filename = ensure_and_get_folder('log')!log_filename = ensure_and_get_folder('log', False)!g" \
        -e "s!processLockFile = ensure_and_get_folder('lock')!processLockFile = ensure_and_get_folder('lock', False)!g" \
        -e "s!ascii_msg += '? \[Y/n\] '!ascii_msg += '? \[Y/n\] '\.encode('ascii', 'ignore')!g" \
        -e "s!ascii_msg += '? \[N/y\] '!ascii_msg += '? \[N/y\] '\.encode('ascii', 'ignore')!g" \
        -e "s:#!/usr/local/bin/:#!${pkgs.coreutils}/bin/env :g" \
          "$input" > "$out"
      '';
      executable = true;
    };

    "jupytertest.ipynb" = {
      source = pkgs.runCommand "generate-jupytertest.ipynb" {
          input = pkgs.fetchurl {
            name = "jupytertest.ipynb";
            url = "https://raw.githubusercontent.com/mwouts/jupytext/32303a6c997ce651d96c675f860282d73d5ccd6a/demo/World%20population.pandoc.md";
            sha256 = "0bz70wllqiy5hhhy5l26z7krk9pikwikvs15lpnnyxmr1203d2s4";
          };
        } ''
          echo ${pkgs.pandoc}/bin/pandoc --from markdown --to ipynb -s --atx-headers --wrap=preserve --preserve-tabs $src -o $out
          ${pkgs.pandoc}/bin/pandoc --from markdown --to ipynb -s --atx-headers --wrap=preserve --preserve-tabs $src -o $out
          '';
      };
    };
}
