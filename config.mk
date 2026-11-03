VERSION ?= 0.1.0
CPPFLAGS += -DVERSION=\"$(VERSION)\"

ifneq ($(strip $(SRC_DIR)),)
CPPFLAGS += -I$(SRC_DIR)
endif

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man
DESTDIR ?=

# Respect the compiler supplied by the environment.
ifneq ($(filter default undefined,$(origin CC)),)
CC = gcc
endif

LDFLAGS ?= -static

LDLIBS ?=

CFLAGS += \
					-std=c89 \
					-O2 \
					-pedantic-errors \
					-Werror \
					-Wall \
					-Wextra
