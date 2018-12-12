{ pkgs ? import (builtins.fetchTarball (builtins.fromJSON (builtins.readFile ./nixpkgs.lock.json))) { } }:
pkgs.mkShell {
  buildInputs = builtins.map (name: builtins.getAttr name pkgs) (builtins.fromJSON (builtins.readFile ./pkgs.json));
}      
