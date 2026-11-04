/* arg.h -- A POSIX compliant argument parser based on plan9's arg(3)
 * Olaf Bernstein <camel-cdr@protonmail.com>
 * Distributed under the MIT license, see license at the end of the file.
 * New versions available at https://github.com/camel-cdr/cauldron
 */

#ifndef ARG_H_INCLUDED

static int
ARG_LONG_func(char **argv0, char const *name)
{
	char *argIt = *argv0;
	while (*argIt == *name && *argIt)
		argIt++, name++;
	if (*argIt == *name || (*argIt == '=' && !*name)) {
		*argv0 = argIt;
		return 1;
	}
	return 0;
}

#define ARG_BEGIN do { \
	for ((void)(argv[0] && (--argc, ++argv)); \
	     argv[0] && argv[0][0] == '-' && argv[0][1]; \
	     (void)(argv[0] && (--argc, ++argv))) { \
		int isFlag = 1; \
		char *arg = argv[0]; \
		if (arg[1] == '-' && arg[2] == 0 && (--argc, ++argv, 1)) \
			break; \
		ARG_BEGIN_REP: \
		switch ((++arg)[0]) { \
		case '-': \
			isFlag = 0; \
			if (arg[-1] == '-') \
				++arg;

#define ARG_LONG(name) ARG_LONG_func(&(arg), (name))

#define ARG_VAL() \
		(isFlag ? (arg[1] ? ++arg : *(--argc, ++argv)) : \
		          (arg[0] == '=' ? ++arg : *(--argc, ++argv)))

#define ARG_FLAG() if (isFlag && arg[1]) goto ARG_BEGIN_REP

#define ARG_END } } } while(0)

#define ARG_H_INCLUDED
#endif

/* Local changes: a lone "-" remains an operand; unused values are explicit. */

/*
 * Copyright (c) 2021 Olaf Berstein
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

