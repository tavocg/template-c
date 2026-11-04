# foobar

Print a greeting.

## Usage

```sh
foobar alpha -m "Hello!"
foobar alpha --message="Hello!"
foobar alpha -s -m "Hello!"
foobar --help
foobar --version
foobar alpha --usage
```

## Download

Download prebuilt binaries for Linux, macOS, and Windows from the
[latest release](https://github.com/tavocg/template-c/releases/latest).

## Build

Edit `config.mk` to match your setup, or override with make `NAME=value`.

Requirements:

- `pkg-config`
- GNU Make.
- C89 compiler.
- (Optional) `bear` to generate `compile_commands.json`

```sh
make
# -> target/<triple>/debug/foobar

make TARGET=x86_64-w64-mingw32 CC=x86_64-w64-mingw32-gcc
# -> target/x86_64-w64-mingw32/debug/foobar.exe
```

## Install

Choose install location with `PREFIX`.

```sh
make install PREFIX="$HOME/.local"
```

To uninstall, use the same prefix:

```sh
make uninstall PREFIX="$HOME/.local"
```

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
