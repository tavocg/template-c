# foobar

Print a greeting.

## Download

Download prebuilt binaries for Linux, macOS, and Windows from the
[latest release](https://github.com/tavocg/template-c/releases/latest).

## Build

Requirements:
- Zig v0.17.0

```sh
zig build
# -> zig-out/bin/foobar
```

```sh
zig build compdb
# -> compile_commands.json
```

## Install

Install the executable and versioned manpage into a chosen prefix:

```sh
zig build --release=fast --prefix "$HOME/.local"
zig build uninstall --prefix "$HOME/.local"
```

### Nix

```sh
nix profile add github:tavocg/template-c#foobar
```

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
