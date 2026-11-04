#include <arg.h>
#include <assert.h>
#include <stddef.h>
#include <string.h>

struct parsed {
	int         flags;
	const char* output;
	int         argc;
	char**      argv;
};

static int parse(int argc, char* argv[], struct parsed* result) {
	result->flags = 0;
	result->output = NULL;
	/* clang-format off */
	ARG_BEGIN {
		if (ARG_LONG("output")) case 'o': {
			result->output = ARG_VAL();
			if (result->output == NULL) {
				return 1;
			}
			break;
		} else if (strchr(argv[0], '=') != NULL) {
			return 1;
		} else if (ARG_LONG("alpha")) case 'a': {
			result->flags |= 1;
			ARG_FLAG();
			break;
		} else if (ARG_LONG("beta")) case 'b': {
			result->flags |= 2;
			ARG_FLAG();
			break;
		} else {
			/* fall through */
		default:
			return 1;
		}
	} ARG_END;
	/* clang-format on */
	result->argc = argc;
	result->argv = argv;
	return 0;
}

int main(void) {
	struct test_case {
		int         argc;
		char*       argv[7];
		int         status;
		int         flags;
		const char* output;
		int         remaining;
	};
	struct test_case cases[] = {
	    {1, {"bin", NULL}, 0, 0, NULL, 0},
	    {2, {"bin", "-ab", NULL}, 0, 3, NULL, 0},
	    {3, {"bin", "--alpha", "--beta", NULL}, 0, 3, NULL, 0},
	    {3, {"bin", "-o", "value", NULL}, 0, 0, "value", 0},
	    {2, {"bin", "-ovalue", NULL}, 0, 0, "value", 0},
	    {2, {"bin", "--output=value", NULL}, 0, 0, "value", 0},
	    {3, {"bin", "--output", "value", NULL}, 0, 0, "value", 0},
	    {2, {"bin", "--output=", NULL}, 0, 0, "", 0},
	    {2, {"bin", "-abovalue", NULL}, 0, 3, "value", 0},
	    {3, {"bin", "-abo", "value", NULL}, 0, 3, "value", 0},
	    {3, {"bin", "--output", "-a", NULL}, 0, 0, "-a", 0},
	    {2, {"bin", "-o", NULL}, 1, 0, NULL, 0},
	    {2, {"bin", "--output", NULL}, 1, 0, NULL, 0},
	    {2, {"bin", "--unknown", NULL}, 1, 0, NULL, 0},
	    {2, {"bin", "-x", NULL}, 1, 0, NULL, 0},
	    {2, {"bin", "--alpha=value", NULL}, 1, 0, NULL, 0},
	    {3, {"bin", "--", "-a", NULL}, 0, 0, NULL, 1},
	    {2, {"bin", "-", NULL}, 0, 0, NULL, 1},
	    {3, {"bin", "operand", "-a", NULL}, 0, 0, NULL, 2},
	    {0, {NULL}, 0, 0, NULL, 0}
	};
	char* nested[] =
	    {"bin", "-a", "remote", "-b", "add", "--output=value", "operand", NULL};
	struct parsed result;
	struct parsed next;
	size_t        i;
	int           status;

	for (i = 0; i < sizeof(cases) / sizeof(cases[0]); i++) {
		status = parse(cases[i].argc, cases[i].argv, &result);
		assert(status == cases[i].status);
		if (status != 0) {
			continue;
		}
		assert(result.flags == cases[i].flags);
		assert(result.argc == cases[i].remaining);
		assert(result.argv == cases[i].argv + cases[i].argc - result.argc);
		if (cases[i].output == NULL) {
			assert(result.output == NULL);
		} else {
			assert(result.output != NULL);
			assert(strcmp(result.output, cases[i].output) == 0);
		}
	}

	status = parse(7, nested, &result);
	assert(status == 0 && result.flags == 1 && result.argc == 5);
	assert(strcmp(result.argv[0], "remote") == 0);
	status = parse(result.argc, result.argv, &next);
	assert(status == 0 && next.flags == 2 && next.argc == 3);
	assert(strcmp(next.argv[0], "add") == 0);
	status = parse(next.argc, next.argv, &result);
	assert(status == 0 && result.flags == 0 && result.argc == 1);
	assert(strcmp(result.output, "value") == 0);
	assert(strcmp(result.argv[0], "operand") == 0);
	return 0;
}
