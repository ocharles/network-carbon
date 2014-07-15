let
  pkgs = import <nixpkgs> {};
  haskellPackages = pkgs.haskellPackages.override {
    extension = self: super: {
      networkCarbon = self.callPackage ./. {};
    };
  };

in pkgs.lib.overrideDerivation haskellPackages.networkCarbon (attrs: {
     buildInputs = [ haskellPackages.cabalInstall_1_18_0_3 ] ++ attrs.buildInputs;
   })