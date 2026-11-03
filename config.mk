VERSION ?= 0.1.0
CPPFLAGS += -DVERSION=\"$(VERSION)\"

ifneq ($(strip $(SRC_DIR)),)
CPPFLAGS += -I$(SRC_DIR)
endif

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man
DESTDIR ?=

CC = gcc

LDFLAGS ?= -static

LDLIBS ?=

CFLAGS += \
					-std=c89 \
					-O2 \
					-pedantic-errors \
					-Werror \
					-Wall \
					-Wextra
