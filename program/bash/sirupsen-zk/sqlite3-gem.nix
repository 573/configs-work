# file ~/.config/nixpkgs/program/ruby-gems/default.nix
# in home.nix packages: (import ./program/ruby-gems { inherit lib; inherit bundlerEnv; inherit bundlerUpdateScript; inherit ruby; }).wrappedRuby
{ lib, bundlerEnv, bundlerUpdateScript, ruby }:
bundlerEnv {
  name = "gmail-britta-bundler-env";
  gemdir = ./.;
  ruby = ruby;
  passthru.updateScript = bundlerUpdateScript "gmail-britta-bundler-env";
  #preConfigure = ''
  #  pushd ~/.config/nixpkgs/program/ruby-gems/
  #  printf "\n**********************************\n"
  #  printf "\nUpdating Ruby Gems nix expressions\n"
  #  printf "\n**********************************\n"
  #  ${self.pkgs.bundix}/bin/bundix --magic
  #  popd
  #  '';
}
