#include <assert.h>
#include <foobar/alpha/alpha.h>
#include <foobar/arg.h>
#include <string.h>

int main(void) {
	struct test_case {
		char*       argv[7];
		int         status;
		const char* message;
		int         silent;
	};
	struct test_case cases[] = {
	    {{"bin", "alpha", NULL}, 0, NULL, 0},
	    {{"bin", "alpha", "-m", "hello", NULL}, 0, "hello", 0},
	    {{"bin", "alpha", "-mhello", NULL}, 0, "hello", 0},
	    {{"bin", "alpha", "--message", "hello", NULL}, 0, "hello", 0},
	    {{"bin", "alpha", "--message=hello", NULL}, 0, "hello", 0},
	    {{"bin", "alpha", "--message=", NULL}, 0, "", 0},
	    {{"bin", "alpha", "-m", "-v", NULL}, 0, "-v", 0},
	    {{"bin", "alpha", "-m", "first", "--message", "last", NULL},
	     0,
	     "last",
	     0},
	    {{"bin", "alpha", "--", NULL}, 0, NULL, 0},
	    {{"bin", "alpha", "-s", NULL}, 0, NULL, 1},
	    {{"bin", "alpha", "-sm", "hello", NULL}, 0, "hello", 1},
	    {{"bin", "alpha", "-smhello", NULL}, 0, "hello", 1},
	    {{"bin", "alpha", "--silent", "--message=hello", NULL}, 0, "hello", 1},
	    {{"bin", "alpha", "-m", "hello", "-s", NULL}, 0, "hello", 1},
	    {{"bin", "alpha", "-m", "-s", NULL}, 0, "-s", 0},
	    {{"bin", "alpha", "--silent=value", NULL}, 1, NULL, 0},
	    {{"bin", "--help=value", NULL}, 1, NULL, 0},
	    {{"bin", "--usage=value", NULL}, 1, NULL, 0},
	    {{"bin", "--version=value", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "--help=value", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "--usage=value", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "-V", NULL}, 1, NULL, 0},
	    {{"bin", "-s", "alpha", NULL}, 1, NULL, 0},
	    {{"bin", NULL}, 1, NULL, 0},
	    {{"bin", "beta", NULL}, 1, NULL, 0},
	    {{"bin", "-v", "alpha", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "-m", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "--message", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "--messagex=hello", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "-f", "file", NULL}, 1, NULL, 0},
	    {{"bin", "alpha", "--", "-m", "hello", NULL}, 1, NULL, 0},
	    {{NULL}, 1, NULL, 0}
	};
	struct args args;
	struct info_case {
		char*           argv[5];
		enum arg_action action;
		int             command;
	};
	struct info_case info[] = {
	    {{"bin", "--help", NULL}, ARG_HELP, 0},
	    {{"bin", "-h", NULL}, ARG_HELP, 0},
	    {{"bin", "--usage", NULL}, ARG_USAGE, 0},
	    {{"bin", "--version", NULL}, ARG_VERSION, 0},
	    {{"bin", "-V", NULL}, ARG_VERSION, 0},
	    {{"bin", "-hV", NULL}, ARG_HELP, 0},
	    {{"bin", "alpha", "--help", NULL}, ARG_HELP, 1},
	    {{"bin", "alpha", "-h", NULL}, ARG_HELP, 1},
	    {{"bin", "alpha", "--usage", NULL}, ARG_USAGE, 1},
	    {{"bin", "alpha", "--help", "--usage", NULL}, ARG_HELP, 1}
	};
	size_t i;
	int    argc;
	int    status;

	for (i = 0; i < sizeof(cases) / sizeof(cases[0]); i++) {
		for (argc = 0; cases[i].argv[argc] != NULL; argc++) {
		}
		status = arg_parse(argc, cases[i].argv, &args);
		assert(status == cases[i].status);
		if (status != 0) {
			continue;
		}
		assert(args.silent == cases[i].silent);
		assert(args.action == ARG_EXECUTE);
		assert(strcmp(args.program, "bin") == 0);
		assert(args.command != NULL);
		assert(strcmp(args.command->name, "alpha") == 0);
		assert(args.command->run == alpha);
		if (cases[i].message == NULL) {
			assert(args.message == NULL);
		} else {
			assert(args.message != NULL);
			assert(strcmp(args.message, cases[i].message) == 0);
		}
	}
	for (i = 0; i < sizeof(info) / sizeof(info[0]); i++) {
		for (argc = 0; info[i].argv[argc] != NULL; argc++) {
		}
		status = arg_parse(argc, info[i].argv, &args);
		assert(status == 0);
		assert(args.action == info[i].action);
		assert((args.command != NULL) == info[i].command);
	}
	return 0;
}
