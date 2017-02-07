{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, base, bytestring, network, stdenv, text, time
      , vector
      }:
      mkDerivation {
        pname = "network-carbon";
        version = "1.0.7";
        src = ./.;
        libraryHaskellDepends = [
          base bytestring network text time vector
        ];
        homepage = "http://github.com/ocharles/network-carbon";
        description = "A Haskell implementation of the Carbon protocol (part of the Graphite monitoring tools)";
        license = stdenv.lib.licenses.bsd3;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = haskellPackages.callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
