VERSION ?= 0.1.0
CPPFLAGS += -DVERSION=\"$(VERSION)\"

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man
DESTDIR ?=

CC = gcc

CFLAGS += \
					-std=c99 \
					-O2 \
					-pedantic-errors \
					-Werror \
					-Wall \
					-Wextra
