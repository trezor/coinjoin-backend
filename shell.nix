# the last successful build of nixpkgs-unstable as of 2022-05-31
with import
  (builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/b62ada430501de88dfbb08cea4eb98ead3a5e3e7.tar.gz";
    sha256 = "1ppaixbncqyvy2ixskwvzggjsw20j77iy3aqyk4749dvkx0ml27f";
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
