{
  description = "foobar - Print a greeting";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          foobar = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
            pname = "foobar";
            version = "0.1.0";
            src = pkgs.lib.fileset.toSource {
              root = ./.;
              fileset = pkgs.lib.fileset.unions [ ./build.zig ./foobar ./man ./tools ];
            };
            nativeBuildInputs = [ pkgs.zig_0_17 ];
            zigBuildFlags = [ "-Dversion=${finalAttrs.version}" ]
              ++ pkgs.lib.optional pkgs.stdenv.hostPlatform.isLinux
                "-Dtarget=${pkgs.stdenv.hostPlatform.parsed.cpu.name}-linux-musl";
            doCheck = true;
            zigCheckFlags = finalAttrs.zigBuildFlags;
            dontStrip = true;
            dontPatchELF = true;
            meta = {
              description = "Print a greeting";
              homepage = "https://github.com/tavocg/template-c";
              license = pkgs.lib.licenses.gpl3Plus;
              mainProgram = "foobar";
              platforms = systems;
            };
          });
        in { inherit foobar; default = foobar; });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [ zig_0_17 clang-tools file ];
          };
        });
    };
}
