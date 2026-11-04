ifeq ($(origin CC),default)
undefine CC
endif

include config.mk

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
STRIP := $(shell $(CC) -print-prog-name=strip)
endif

ifneq ($(findstring musl,$(TARGET))$(findstring gnu,$(TARGET)),)
ifneq ($(findstring musl,$(TARGET)),$(findstring musl,$(CC_TARGET)))
$(error target $(TARGET) is incompatible with $(CC) ($(CC_TARGET)))
endif
endif

BUILD_DIR ?= $(OUT_DIR)/$(TARGET)
BIN = $(BUILD_DIR)/$(PROGRAM)$(EXT)
SRC := $(shell find "$(SRC_DIR)" -type f -name '*.c' | sort)
OBJ = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRC))
DEP = $(OBJ:.o=.d)
MANPAGES = $(wildcard $(MAN_DIR)/man*/*)

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
	rm -rf "$(OUT_DIR)"

-include $(DEP)

.PHONY: all run compile_commands.json clean install uninstall
