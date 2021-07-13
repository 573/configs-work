{
# nix-instantiate --eval <home-manager/home-manager/home-manager.nix>  --argstr confPath /my/config.nix --argstr confAttr "" -A activationPackage.outPath

  # see https://nixos.org/nix/manual/#conf-allowed-users and https://github.com/rycee/home-manager/tree/release-19.09#installation
  # https://nixos.org/nixos/manual/options.html#opt-nix.allowedUsers
  # (...) make sure that your user is (...) able to successfully run a command like nix-instantiate '<nixpkgs>' -A hello without having to switch to the root user. For a multi-user install of Nix this means that your user must be covered by the allowed-users Nix option. On NixOS you can control this option using the nix.allowedUsers system option.
  nix.allowedUsers = [ "dkahlenberg" ]; # TODO or should that be in ~/.config/nix/nix.conf when not on NixOS ?
  nix.useSandbox = false;
  nix.trustedBinaryCaches = [ "https://hydra.nixos.org/" ];
  nix.distributedBuilds = true;

  # the next two options should only be supported on NixOS,
  # see https://nix-community.github.io/home-manager/index.html#sec-install-nixos-module for background
  #users.users.dkahlenberg.isNormalUser = true;

  #users.users.dkahlenberg.extraGroups = [ "wheel" "kvm" ];

#  For `nix-env`, `nix-build`, `nix-shell` or any other Nix command you can add { allowUnfree = true; } to ~/.config/nixpkgs/config.nix.
allowUnfree = true;
allowBroken = false;

# other interesting stuff https://nixos.org/nixos/manual/options.html#opt-nix.systemFeatures, for the syntax check https://github.com/NixOS/nix/issues/2964#issuecomment-504097120
#  services.openssh = {
#    enable = true;
#    authorizedKeysFiles = [ "~/.ssh/authorized_keys" ];
#    passwordAuthentication = false;
#    ports = [8022];
#    challengeResponseAuthentication = false;
#    permitRootLogin = "no";
#    banner = null;
    # for hostKeys use default value
#    extraConfig = ''
#      RSAAuthentication yes
#      PubkeyAuthentication yes
#      UsePAM no
#      PrintMotd no
#      PermitUserEnvironment no
#      '';
#  };
}

