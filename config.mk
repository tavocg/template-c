VERSION ?= 0.1.0
CPPFLAGS += -DVERSION=\"$(VERSION)\"

ifneq ($(strip $(SRC_DIR)),)
CPPFLAGS += -I$(SRC_DIR)
endif

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man
DESTDIR ?=

ifneq ($(filter default undefined,$(origin CC)),)
CC = gcc
endif

STRIP ?= $(shell $(CC) -print-prog-name=strip)
STRIPFLAGS ?=

LTOFLAGS ?= -flto

LDFLAGS ?= -static

LDLIBS ?=

CFLAGS += \
					-std=c89 \
					-O3 \
					-pedantic-errors \
					-Werror \
					-Wall \
					-Wextra
