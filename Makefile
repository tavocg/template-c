PROGRAM = program

SRC_DIR = program
BUILD_DIR = build
MAN_DIR = man

BIN = $(BUILD_DIR)/$(PROGRAM)
SRC := $(shell find "$(SRC_DIR)" -type f -name '*.c' | sort)
OBJ = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(SRC))
DEP = $(OBJ:.o=.d)
MANPAGES = $(wildcard $(MAN_DIR)/man*/*)

include config.mk

all: $(BIN)

build: all

$(BIN): $(OBJ) Makefile config.mk
	@mkdir -p "$(@D)"
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJ) $(LDLIBS)

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c Makefile config.mk
	@mkdir -p "$(@D)"
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

run: $(BIN)
	./$(BIN)

install: all
	mkdir -p "$(DESTDIR)$(PREFIX)/bin"
	install -m 755 "$(BIN)" "$(DESTDIR)$(PREFIX)/bin/$(notdir $(BIN))"
	set -e; for page in $(MANPAGES); do \
		target="$(DESTDIR)$(MANPREFIX)/$${page#$(MAN_DIR)/}"; \
		mkdir -p "$${target%/*}"; \
		sed 's/VERSION/$(VERSION)/g' "$$page" > "$$target"; \
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

.PHONY: all build run clean install uninstall
