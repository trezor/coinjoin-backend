# the last successful build of nixpkgs-unstable as of 2023-02-28
with import
  (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/7785526659fe5885abbd88a85a23a11bd0617e3c.tar.gz";
    sha256 = "0sjsy3jihhdmck6hn9lizwvk25kzf5ags1p21xqqn3kj7fv5ax9x";
  })
{ };

stdenv.mkDerivation rec {
  name = "coinjoin-backend-dev";
  buildInputs = [
    stdenv.cc.cc.lib
    openssl
    dotnet-sdk_8
    docker
    fontconfig
    fontconfig.lib
    git
    xorg.xhost
    xorg.libX11
    xorg.libX11.dev
    xorg.libICE
    xorg.libSM
    zlib
  ];
  LD_LIBRARY_PATH = "${(import <nixpkgs> { }).lib.makeLibraryPath buildInputs}";
}
