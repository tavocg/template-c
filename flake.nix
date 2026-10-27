{
  description = "program: print a greeting";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ gcc gnumake ];
            LIBRARY_PATH = "${pkgs.glibc.static}/lib";
            shellHook = ''
              export PS1="(program) $PS1"
            '';
          };
        });
    };
}
