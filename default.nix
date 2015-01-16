{ mkDerivation, base, bytestring, network, stdenv, text, time
, vector
}:
mkDerivation {
  pname = "network-carbon";
  version = "1.0.2";
  src = ./.;
  buildDepends = [ base bytestring network text time vector ];
  homepage = "http://github.com/ocharles/network-carbon";
  description = "A Haskell implementation of the Carbon protocol (part of the Graphite monitoring tools)";
  license = stdenv.lib.licenses.bsd3;
}
