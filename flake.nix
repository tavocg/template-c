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

      mkBuildConfig = pkgs:
        let
          platform = pkgs.stdenv.hostPlatform;
          target = platform.config;
        in
        {
          nativeBuildInputs = with pkgs.buildPackages; [ gnumake pkg-config ];
          buildInputs = with pkgs; [
            # Add application libraries here, for example SDL2.
          ];

          LDFLAGS = pkgs.lib.optionalString (!platform.isDarwin) "-static";
          LIBRARY_PATH = pkgs.lib.optionalString platform.isLinux "${pkgs.glibc.static}/lib";
          EXT = pkgs.lib.optionalString platform.isWindows ".exe";
          TARGET = target;
          BUILD_DIR = "target/${target}";
        };

      mkPackage = pkgs:
        pkgs.stdenv.mkDerivation (finalAttrs: (mkBuildConfig pkgs) // {
          pname = "foobar";
          version = "0.1.0";
          src = pkgs.lib.cleanSource ./.;

          enableParallelBuilding = true;
          makeFlags = [ "PREFIX=$(out)" "VERSION=${finalAttrs.version}" ];

          meta = {
            description = "Print a greeting";
            homepage = "https://github.com/tavocg/template-c";
            license = pkgs.lib.licenses.gpl3Plus;
            mainProgram = "foobar";
            platforms = systems;
          };
        });

      mkDevShell = pkgs:
        let
          config = mkBuildConfig pkgs;
        in
        pkgs.mkShell (config // {
          nativeBuildInputs = config.nativeBuildInputs ++ [ pkgs.buildPackages.bear ];

          shellHook = ''
            export PS1="(foobar) $PS1"
          '';
        });
    in
    {
      packages = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          foobar = mkPackage pkgs;
        in
        {
          inherit foobar;
          default = foobar;
        });

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
