# foobar

Print a greeting

## Download

Download prebuilt binaries for Linux, macOS, and Windows from the
[latest release](https://github.com/tavocg/template-c/releases/latest).

## Build

Edit `config.mk` to match your setup.

Requirements:

- GNU Make.
- GCC/Clang-compatible C89 compiler.

```sh
# Output in target/machine/
make
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
