/* SPDX-License-Identifier: GPL-3.0-or-later */
#include <arg.h>
#include <foobar/alpha/alpha.h>
#include <foobar/arg.h>
#include <string.h>

static const struct command commands[] = {{"alpha", alpha}};

void synopsis(FILE* stream, const struct args* args) {
	if (args->command != NULL) {
		fprintf(
		    stream,
		    "usage: %s [-s] alpha [-hsV] [-m MESSAGE] [--usage]\n",
		    args->program
		);
	} else {
		fprintf(
		    stream,
		    "usage: %s [-hVs] [--usage] command [options]\n",
		    args->program
		);
	}
}

void usage(FILE* stream, const struct args* args) {
	synopsis(stream, args);
	if (args->command != NULL) {
		fputs("  -m, --message MESSAGE  Print MESSAGE.\n", stream);
	} else {
		fputs("Commands:\n  alpha  Print a message.\n", stream);
	}
	fputs(
	    "Global options (before or after the command):\n"
	    "  -s, --silent   Suppress message output.\n"
	    "  -V, --version  Show the version and exit.\n"
	    "  -h, --help     Show help and exit.\n"
	    "      --usage    Show a brief usage message and exit.\n",
	    stream
	);
}

static int parse_global_option(
    const char*  option,
    int          is_short,
    struct args* args
) {
	static const struct {
		const char*     name;
		char            key;
		enum arg_action action;
	} options[] = {
	    {"silent", 's', ARG_EXECUTE},
	    {"help", 'h', ARG_HELP},
	    {"version", 'V', ARG_VERSION},
	    {"usage", '\0', ARG_USAGE}
	};

	size_t i;

	for (i = 0; i < sizeof(options) / sizeof(options[0]); i++) {
		if (is_short ? option[0] == options[i].key
		             : strcmp(option, options[i].name) == 0) {
			if (options[i].key == 's') {
				args->silent = 1;
			} else if (args->action < options[i].action) {
				args->action = options[i].action;
			}
			return 1;
		}
	}

	return 0;
}

static int parse_command(int argc, char* argv[], struct args* args) {
	ARG_BEGIN {
		if (ARG_LONG("message")) {
		case 'm':
			args->message = ARG_VAL();
			if (args->message == NULL) {
				return 1;
			}
			break;
		} else {
			/* fall through */
		default:
			if (!parse_global_option(arg, isFlag, args)) {
				return 1;
			}
			ARG_FLAG();
			break;
		}
	}
	ARG_END;

	return argc > 0 && args->action == ARG_EXECUTE;
}

int arg_parse(int argc, char* argv[], struct args* args) {
	struct args defaults = {0};
	size_t      i;

	*args = defaults;
	args->program = argc > 0 && argv[0] != NULL ? argv[0] : "foobar";

	ARG_BEGIN {
		/* fall through */
	default:
		if (!parse_global_option(arg, isFlag, args)) {
			return 1;
		}
		ARG_FLAG();
		break;
	}
	ARG_END;

	if (args->action != ARG_EXECUTE) {
		return 0;
	}

	for (i = 0; argc > 0 && i < sizeof(commands) / sizeof(commands[0]); i++) {
		if (strcmp(argv[0], commands[i].name) == 0) {
			args->command = &commands[i];
			return parse_command(argc, argv, args);
		}
	}

	return 1;
}

int arg_run(const struct args* args) {
	switch (args->action) {
	case ARG_HELP:
		usage(stdout, args);
		return 0;
	case ARG_USAGE:
		synopsis(stdout, args);
		return 0;
	case ARG_VERSION:
		return puts("foobar " VERSION) == EOF;
	default:
		return args->command->run(args);
	}
}
