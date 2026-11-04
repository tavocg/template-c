VERSION ?= 0.1.0

CPPFLAGS += -DVERSION=\"$(VERSION)\"
CPPFLAGS += -I.

PREFIX ?= /usr/local
MANPREFIX ?= $(PREFIX)/share/man
DESTDIR ?=

ifneq ($(findstring windows,$(TARGET))$(findstring mingw,$(TARGET))$(findstring cygwin,$(TARGET)),)
ifeq ($(strip $(EXT)),)
EXT := .exe
endif
endif

ifdef STATIC
override LDFLAGS += -static
endif

ifneq ($(findstring musl,$(TARGET))$(findstring gnu,$(TARGET)),)
ifneq ($(findstring musl,$(TARGET)),$(findstring musl,$(CC_TARGET)))
$(error target $(TARGET) is incompatible with $(CC) ($(CC_TARGET)))
endif
endif

STRIP ?= $(shell $(CC) -print-prog-name=strip)
STRIPFLAGS ?=

LTOFLAGS ?= -flto

LDLIBS ?=

CFLAGS += \
					-std=c89 \
					-O3 \
					-pedantic-errors \
					-Werror \
					-Wall \
					-Wextra
