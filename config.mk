PROGRAM ?= foobar
VERSION ?= 0.1.0

SRC_DIR ?= foobar
OUT_DIR ?= target
MAN_DIR ?= man

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man

CC ?= gcc
CPPFLAGS ?= -DVERSION=\"$(VERSION)\" -I.
LDFLAGS ?=
LDLIBS ?=
STRIPFLAGS ?=

#DESTDIR = /tmp/package
#TARGET = x86_64-unknown-linux-musl
#STATIC = 1
#RELEASE = 1
