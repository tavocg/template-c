/* SPDX-License-Identifier: GPL-3.0-or-later */
#ifndef FOOBAR_ARG_H
#define FOOBAR_ARG_H

#include <stdio.h> /* IWYU pragma: keep */

struct args;

struct command {
	const char* name;
	int (*run)(const struct args*);
};

struct args {
	const char*           program;
	const struct command* command;
	const char*           message;
	int                   silent;
};

void synopsis(FILE* stream, const struct args* args);
void usage(FILE* stream, const struct args* args);
int  arg_parse(int argc, char* argv[], struct args* args);
int  arg_run(const struct args* args);

#endif
