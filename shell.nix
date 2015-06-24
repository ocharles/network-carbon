let
  pkgs = import <nixpkgs> {};
  haskellPackages = pkgs.haskellngPackages.override {
    overrides = self: super: {
      network-carbon = self.callPackage ./. {};
    };
  };
in haskellPackages.network-carbon.env
