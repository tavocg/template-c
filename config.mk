PROGRAM ?= foobar
VERSION ?= 0.1.0

SRC_DIR ?= foobar
OUT_DIR ?= target
MAN_DIR ?= man

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man

CC ?= gcc
CPPFLAGS ?= -DVERSION=\"$(VERSION)\" -I.
CFLAGS ?= -std=c89 -O3 -pedantic-errors -Werror -Wall -Wextra
LTOFLAGS ?= -flto
LDFLAGS ?=
LDLIBS ?=
STRIPFLAGS ?=

#DESTDIR = /tmp/package
#TARGET = x86_64-unknown-linux-musl
#STATIC = 1
