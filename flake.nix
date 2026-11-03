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

      mkDevShell = pkgs:
        let
          platform = pkgs.stdenv.hostPlatform;
          target = platform.config;
        in
        pkgs.mkShell {
          nativeBuildInputs = with pkgs.buildPackages; [ gnumake pkg-config bear upx ];
          buildInputs = with pkgs; [
            # Add application libraries here, for example SDL2.
          ];

          LDFLAGS = pkgs.lib.optionalString (!platform.isDarwin) "-static";
          LIBRARY_PATH = pkgs.lib.optionalString platform.isLinux "${pkgs.glibc.static}/lib";
          EXT = pkgs.lib.optionalString platform.isWindows ".exe";
          TARGET = target;
          BUILD_DIR = "target/${target}";

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
          default = mkDevShell pkgs;
        } // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          windows = mkDevShell pkgs.pkgsCross.mingw-ucrt-x86_64;
        });
    };
}
