# Each *_test.c provides main(). Other C files in its TEST_DIR folder are helpers.
# Application sources are linked without SRC_DIR/main.c.
TEST_LIB_SRC ?= $(filter-out $(SRC_DIR)/main.c,$(SRC))
TEST_LIB_OBJ = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(TEST_LIB_SRC))
TEST_CPPFLAGS ?= -UNDEBUG
TEST_SRC := $(shell find $(wildcard $(SRC_DIR) $(TEST_DIR)) -type f -name '*_test.c' | sort)
TEST_BINS :=
TEST_OBJ :=
TEST_CONFIG = $(BUILD_DIR)/test-objects/.test-config

define add_test
TEST_BINS += $(BUILD_DIR)/tests/$(1:.c=)$(EXT)
TEST_OBJ += $(patsubst %.c,$(BUILD_DIR)/test-objects/%.o,$(2))

$(BUILD_DIR)/tests/$(1:.c=)$(EXT): $(patsubst %.c,$(BUILD_DIR)/test-objects/%.o,$(2)) $(TEST_LIB_OBJ) Makefile config.mk tests.mk $(BUILD_CONFIG) $(TEST_CONFIG)
	@mkdir -p "$$(@D)"
	$$(CC) $$(CFLAGS) $$(LTOFLAGS) $$(LDFLAGS) -o $$@ $$(filter %.o,$$^) $$(LDLIBS)
endef

$(foreach src,$(TEST_SRC), \
  $(eval $(call add_test,$(src),$(src) \
    $(if $(filter $(TEST_DIR)/%,$(src)),$(filter-out %_test.c,$(wildcard $(dir $(src))*.c))))))
TEST_OBJ := $(sort $(TEST_OBJ))

$(TEST_CONFIG): config
	@mkdir -p "$(@D)"
	@config=$$(printf '%s\n' $(foreach var,TEST_CPPFLAGS TEST_LIB_SRC TEST_OBJ,$(call shell_quote,$(var)=$($(var))))); \
	if [ "$$config" != "$$(cat "$@" 2>/dev/null)" ]; then \
		printf '%s\n' "$$config" > "$@"; \
	fi

$(BUILD_DIR)/test-objects/%.o: %.c Makefile config.mk tests.mk $(BUILD_CONFIG) $(TEST_CONFIG)
	@mkdir -p "$(@D)"
	$(CC) $(CPPFLAGS) $(CFLAGS) $(LTOFLAGS) $(TEST_CPPFLAGS) -MMD -MP -c $< -o $@

test: $(TEST_BINS)
	@status=0; \
	for test in $(foreach src,$(TEST_SRC),$(call shell_quote,$(src:.c=))); do \
		if "$(BUILD_DIR)/tests/$$test$(EXT)"; then \
			printf '%-4s %s\n' OK "$$test"; \
		else \
			printf '%-4s %s\n' FAIL "$$test"; \
			status=1; \
		fi; \
	done; \
	exit $$status

-include $(TEST_OBJ:.o=.d)

.PHONY: test
