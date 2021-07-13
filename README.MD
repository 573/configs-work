Most of the times when changing this config I do

```sh
NIX_PATH=nixpkgs=http://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz nix-shell --run "home-manager switch --show-trace"
```

Another often used command, this time to manage exact versions is

```sh
NIX_PATH=nixpkgs=http://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz nix run nixpkgs.niv -c niv --help
```

I. e. (use other artifacts to your liking here)

```sh
NIX_PATH=nixpkgs=http://nixos.org/channels/nixpkgs-unstable/nixexprs.tar.xz nix run nixpkgs.niv -c niv modify pandoc-plantuml-filter -a homepage=https://github.com/timofurrer/pandoc-plantuml-filter
```

