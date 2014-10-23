let
  pkgs = import <nixpkgs> {};
  haskellPackages = pkgs.haskellPackages.override {
    extension = self: super: {
      networkCarbon = self.callPackage ./. {};
    };
  };

in pkgs.myEnvFun {
     name = haskellPackages.networkCarbon.name;
     buildInputs = [
       pkgs.curl
       (haskellPackages.ghcWithPackages (hs: ([
         hs.cabalInstall
         hs.hscolour
       ] ++ hs.networkCarbon.propagatedNativeBuildInputs)))
     ];
   }