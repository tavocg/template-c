{
  description = "foobar - Print a greeting";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      muslPkgs = pkgs:
        if pkgs.stdenv.hostPlatform.isx86_64 then pkgs.pkgsCross.musl64
        else if pkgs.stdenv.hostPlatform.isAarch64 then pkgs.pkgsCross.aarch64-multiplatform-musl
        else pkgs;

      mkDevShell = pkgs:
        let
          platform = pkgs.stdenv.hostPlatform;
        in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs.buildPackages; [ gnumake pkg-config ];
          buildInputs = with pkgs; [
            # Add application libraries here, for example SDL2.
          ];

          TARGET = platform.config;

          shellHook = ''
            export PS1="(foobar) $PS1"
          '';
        };
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = mkDevShell
            (if pkgs.stdenv.hostPlatform.isLinux then muslPkgs pkgs else pkgs);
        } // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          windows = mkDevShell pkgs.pkgsCross.mingw-ucrt-x86_64;
          windows-arm64 = mkDevShell pkgs.pkgsCross.mingw-ucrt-aarch64;
        } // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
          linux-arm64 = mkDevShell pkgs.pkgsCross.aarch64-multiplatform-musl;
        });
    };
}
