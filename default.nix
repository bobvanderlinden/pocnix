{ pkgs ? import (builtins.fetchTarball (builtins.fromJSON (builtins.readFile ./nixpkgs.lock.json))) { } }:
pkgs.stdenv.mkDerivation {
  name = "pocnix";
  src = ./pocnix;
  unpackPhase = "true";
  buildInputs = builtins.map (name: builtins.getAttr name pkgs) (builtins.fromJSON (builtins.readFile ./pkgs.json));
  dontBuild = true;
  installPhase = ''
    install -Dm755 $src $out/bin/pocnix
  '';
}