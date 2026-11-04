ifeq ($(origin CC),default)
undefine CC
endif

include config.mk

ifneq ($(strip $(PACKAGES)),)
ifeq ($(shell $(PKG_CONFIG) --exists --print-errors "$(PACKAGES)" && printf yes),)
$(error Cannot resolve PACKAGES ($(PACKAGES)) with $(PKG_CONFIG))
endif
PACKAGE_CFLAGS := $(shell $(PKG_CONFIG) --cflags "$(PACKAGES)")
override CPPFLAGS := $(CPPFLAGS) $(patsubst -I%,-isystem %,$(PACKAGE_CFLAGS))
override LDLIBS := $(LDLIBS) $(shell $(PKG_CONFIG) $(if $(STATIC),--static) --libs "$(PACKAGES)")
endif

ifeq ($(RELEASE),1)
BUILD_MODE := release
CFLAGS ?= -std=$(CSTD) -O3 -DNDEBUG -Werror -Wall -Wextra
LTOFLAGS ?= -flto
else
BUILD_MODE := debug
CFLAGS ?= -std=$(CSTD) -O0 -g3 -Werror -Wall -Wextra
LTOFLAGS ?=
# Nix's fortify flags require optimization, which debug disables.
export NIX_HARDENING_ENABLE := $(filter-out fortify fortify3,$(NIX_HARDENING_ENABLE))
endif

CC_TARGET := $(shell $(CC) -dumpmachine)

ifeq ($(strip $(TARGET)),)
TARGET := $(CC_TARGET)
endif

ifneq ($(findstring windows,$(TARGET))$(findstring mingw,$(TARGET))$(findstring cygwin,$(TARGET)),)
ifeq ($(strip $(EXT)),)
EXT := .exe
endif
endif

ifdef STATIC
override LDFLAGS += -static
endif

ifeq ($(strip $(STRIP)),)
STRIP := $(shell tool=$$($(CC) -print-prog-name=strip 2>/dev/null) && printf '%s' "$$tool")
endif

ifneq ($(findstring musl,$(TARGET))$(findstring gnu,$(TARGET)),)
ifneq ($(findstring musl,$(TARGET)),$(findstring musl,$(CC_TARGET)))
$(error target $(TARGET) is incompatible with $(CC) ($(CC_TARGET)))
endif
endif

BUILD_DIR ?= $(OUT_DIR)/$(TARGET)/$(BUILD_MODE)
BIN = $(BUILD_DIR)/$(PROGRAM)$(EXT)
SRC := $(shell find "$(SRC_DIR)" -type f -name '*.c' ! -name '*_test.c' | sort)
OBJ = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRC))
DEP = $(OBJ:.o=.d)
MANPAGES = $(wildcard $(MAN_DIR)/man*/*)
BUILD_CONFIG = $(BUILD_DIR)/.build-config
CONFIG_VARS = CC CC_TARGET TARGET BUILD_MODE CPPFLAGS CFLAGS LTOFLAGS LDFLAGS LDLIBS STRIP STRIPFLAGS NIX_HARDENING_ENABLE
shell_quote = '$(subst ','"'"',$(1))'

all: $(BIN)

$(BUILD_CONFIG): config
	@mkdir -p "$(@D)"
	@config=$$(printf '%s\n' $(foreach var,$(CONFIG_VARS),$(call shell_quote,$(var)=$($(var))))); \
	if [ "$$config" != "$$(cat "$@" 2>/dev/null)" ]; then \
		printf '%s\n' "$$config" > "$@"; \
	fi

$(BIN): $(OBJ) Makefile config.mk $(BUILD_CONFIG)
	@mkdir -p "$(@D)"
	$(CC) $(CFLAGS) $(LTOFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LDLIBS)
ifeq ($(BUILD_MODE),release)
ifneq ($(strip $(STRIP)),)
	$(STRIP) $(STRIPFLAGS) $@
endif
endif

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c Makefile config.mk $(BUILD_CONFIG)
	@mkdir -p "$(@D)"
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LTOFLAGS) -MMD -MP -c $< -o $@

run: $(BIN)
	@./$(BIN)

compile_commands.json:
	bear -- $(MAKE) -B all

install: all
	mkdir -p "$(DESTDIR)$(PREFIX)/bin"
	install -m 755 "$(BIN)" "$(DESTDIR)$(PREFIX)/bin/$(notdir $(BIN))"
	set -e; for page in $(MANPAGES); do \
		target="$(DESTDIR)$(MANPREFIX)/$${page#$(MAN_DIR)/}"; \
		mkdir -p "$${target%/*}"; \
		sed 's/@VERSION@/$(VERSION)/g' "$$page" > "$$target"; \
		chmod 644 "$$target"; \
	done

uninstall:
	rm -f "$(DESTDIR)$(PREFIX)/bin/$(notdir $(BIN))"
	set -e; for page in $(MANPAGES); do \
		rm -f "$(DESTDIR)$(MANPREFIX)/$${page#$(MAN_DIR)/}"; \
	done

clean:
	rm -rf "$(OUT_DIR)"

-include $(DEP)

include tests.mk

config:

.PHONY: all run compile_commands.json clean install uninstall config
