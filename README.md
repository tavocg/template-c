# foobar

Print a greeting.

## Download

Download prebuilt binaries for Linux, macOS, and Windows from the
[latest release](https://github.com/tavocg/template-c/releases/latest).

## Build

Edit `config.mk` to match your setup.

Requirements:

- GNU Make.
- GCC/Clang-compatible C89 compiler.

```sh
make
# -> target/<triple>/

make TARGET=x86_64-w64-mingw32 CC=x86_64-w64-mingw32-gcc
# -> target/x86_64-w64-mingw32/
```

## Version

The version lives in the `VERSION` file. It is embedded in the binary and the
man page, and `make version` prints it.

```sh
./target/<triple>/foobar --version
make version
```

Bump `VERSION` before tagging a release; CI checks that the tag matches.

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
