/* SPDX-License-Identifier: GPL-3.0-or-later */
#include <arg.h>
#include <foobar/alpha/alpha.h>
#include <foobar/arg.h>
#include <string.h>

static const struct command commands[] = {{"alpha", alpha}};

void synopsis(FILE* stream, const struct args* args) {
	fprintf(stream, "usage: %s alpha [-s] [-m MESSAGE]\n", args->program);
}

void usage(FILE* stream, const struct args* args) {
	synopsis(stream, args);
	fputs("  -m, --message MESSAGE  Print MESSAGE.\n", stream);
	fputs("  -s, --silent           Suppress message output.\n", stream);
}

int arg_parse(int argc, char* argv[], struct args* args) {
	struct args defaults = {0};
	size_t      i;

	*args = defaults;
	args->program = argc > 0 && argv[0] != NULL ? argv[0] : "foobar";
	if (argc < 2) {
		return 1;
	}
	argc--;
	argv++;
	for (i = 0; i < sizeof(commands) / sizeof(commands[0]); i++) {
		if (strcmp(argv[0], commands[i].name) == 0) {
			args->command = &commands[i];
			break;
		}
	}
	if (args->command == NULL) {
		return 1;
	}
	ARG_BEGIN {
		if (ARG_LONG("message")) {
		case 'm':
			args->message = ARG_VAL();
			if (args->message == NULL) {
				return 1;
			}
			break;
		} else if (strchr(argv[0], '=') != NULL) {
			return 1;
		} else if (ARG_LONG("silent")) {
		case 's':
			args->silent = 1;
			ARG_FLAG();
			break;
		} else {
			/* fall through */
		default:
			return 1;
		}
	}
	ARG_END;

	if (argc > 0) {
		return 1;
	}
	return 0;
}

int arg_run(const struct args* args) {
	return args->command->run(args);
}
