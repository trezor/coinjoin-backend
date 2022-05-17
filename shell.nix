# the last successful build of nixpkgs-unstable as of 2021-11-16 compatible to trezor-suite
with import
  (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/5cb226a06c49f7a2d02863d0b5786a310599df6b.tar.gz";
    sha256 = "0dzz207swwm5m0dyibhxg5psccrcqfh1lzkmzzfns27wc4ria6z3";
  })
{ };

stdenv.mkDerivation rec {
  name = "coinjoin-backend-dev";
  buildInputs = [
    stdenv.cc.cc.lib
    openssl
    dotnet-sdk_6
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
