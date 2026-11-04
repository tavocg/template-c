PROGRAM = foobar

SRC_DIR = foobar
OUT_DIR = target
MAN_DIR = man

BUILD_DIR ?= $(OUT_DIR)/$(TARGET)
BIN = $(BUILD_DIR)/$(PROGRAM)$(EXT)
SRC := $(shell find "$(SRC_DIR)" -type f -name '*.c' | sort)
OBJ = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRC))
DEP = $(OBJ:.o=.d)
MANPAGES = $(wildcard $(MAN_DIR)/man*/*)

ifneq ($(filter default undefined,$(origin CC)),)
CC = gcc
endif

ifndef TARGET
TARGET := $(shell $(CC) -dumpmachine)
endif

include config.mk

all: $(BIN)

$(BIN): $(OBJ) Makefile config.mk
	mkdir -p "$(@D)"
	$(CC) $(CFLAGS) $(LTOFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LDLIBS)
	$(STRIP) $(STRIPFLAGS) $@

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c Makefile config.mk
	mkdir -p "$(@D)"
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
	rm -f $(BIN) $(OBJ) $(DEP)

-include $(DEP)

.PHONY: all run compile_commands.json clean install uninstall
