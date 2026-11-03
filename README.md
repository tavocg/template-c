# foobar

Print a greeting

## Build

Edit `config.mk` to match your setup.

Requirements:

- GNU Make.
- GCC/Clang-compatible C89 compiler.

```sh
make
```

## Run

```sh
make run
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
