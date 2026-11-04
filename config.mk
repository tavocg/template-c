PROGRAM ?= foobar
VERSION ?= 0.1.0

SRC_DIR ?= foobar
OUT_DIR ?= target
MAN_DIR ?= man
TEST_DIR ?= tests

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
#TEST_CPPFLAGS = -UNDEBUG
#TEST_LIB_SRC = $(SRC_DIR)/alpha/alpha.c
