{ pkgs ? import <nixpkgs> {},
  system ? builtins.currentSystem }:

let
  zig-overlay = pkgs.fetchFromGitHub {
    owner = "arqv";
    repo = "zig-overlay";
    rev = "bb213addbc8f4cff8124b67ba55cc0a5b1c92ea7";
    sha256 = "03pqmigrlzgkh5g92a0zcnkh53cisnsp0r3d4cms365klqlaklz2";
  };
  # need version 0.8.1
  zig = (import zig-overlay { inherit pkgs system; })."0.8.1";
  buildInputs = [ zig pkgs.SDL2 ];
in pkgs.stdenv.mkDerivation {
  name = "zarzara-env";
  buildInputs = buildInputs;
  LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath buildInputs}";
}