# pocnix

A proof-of-concept cli as an alternative to the [Nix CLI](https://nixos.org/nix).

This CLI is an experiment to stream-line the workflow of managing packages on NixOS.

## The problem

Currently there are different workflows for different types of scopes:

To install packages into system-wide, you'd need to edit `/etc/nixos/configuration.nix` and add an entry in the `environment.systemPackages` section. It would look like: `environment.systemPackages = [ ... , package ];`. After that the user needs to run `nixos-rebuild switch`.

To install packages locally for a project directory, you'd need to create a `default.nix` or `shell.nix` and add `{ pkgs }: pkgs.mkShell { buildInputs = [ package ]; }`. After that the user needs to run `nix-shell` or use `direnv` to load the package to be part of the local environment.

To install packages into a user home directory you'd use `nix-env -iA package`. Unlike the above methods, this method does not involve editing a file. This is nice, but it is therefore hard to maintain the state of the home directory. This makes it hard to keep a grip on the state of the user environment. It is recommended in the manual of NixOS, but in the NixOS community it is often regarded as a bad way to manage the user environment.

Many users are starting to use `home-manager`, which allows defining packages in a file. This will give a similar workflow as the system and local environments, but it isn't as easy as using `nix-env`.

This workflow is not user-friendly. It is especially not friendly towards new users. The configuration files do allow setting the environment declaratively.

Many language-specific package managers usually have install commands that install packages, but also alter a configuration file where the installed package will be added, so that it can be shared with others. This is user-friendly as well as declarative.

## The experiment

It would be nice if Nix could act like those language-specific package managers, but then be able to be used for different environments in the same manner. For instance:
```
nix install --local package
nix install --user package
nix install --system package
```

## The implementation

Currently this project is a very small and rough POC. You can use it in the following manner:

### Local/project environment

Navigate to a directory for your project and use:

```
pocnix local init
```

This will create 3 files:

* `default.nix`: a `nix-shell`-compatible file that will reference the files below
* `pkgs.json`: a list of packages (`buildInputs`)
* `nixpkgs.lock.json`: the configuration to pin Nixpkgs

You can optionally create a direnv file by creating `.envrc`:

```
use nix
```

After this it is possible to install packages using:

```
pocnix local install cowsay
```

This will attempt to evaluate `cowsay` in Nix to verify the package actually exists and builds. Once it does, the package is added to `pkgs.json`. If `direnv` is installed, it will automatically `direnv allow` the new configuration.

This project contains an example how this is used. See [shell.nix](/shell.nix).

### User environment

```
pocnix user init
```

* `~/.config/nixpkgs/home.nix`: a `home-manager`-compatible configuration file
* `~/.config/nixpkgs/pkgs.json`
* `~/.config/nixpkgs/nixpkgs.lock.json`

The workflow for the user environment is very similar to the one of the local environment:

```
pocnix user install cowsay
```

This will do the same as for the local environment, but will switch to the new configuration using `home-manager switch`.

### System environment

```
pocnix system init
```

* `/etc/nixos/configuration.nix`: a NixOS configuration file
* `/etc/nixos/pkgs.json`
* `/etc/nixos/nixpkgs.lock.json`

Same thing applies, but will switch to the new configuration using `nixos-rebuild switch`. This command is only applicable under root.

## Installation

When using `direnv` or if you have `node` in your environment, you can use `pocnix` locally.

Otherwise, the easiest way to install is:

```
nix-env -if .
```
