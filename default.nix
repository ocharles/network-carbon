{ cabal, network, vector }:
cabal.mkDerivation (self: {
  pname = "network-carbon";
  version = "1.0.0";
  src = ./.;
  buildDepends = [ network vector ];
})