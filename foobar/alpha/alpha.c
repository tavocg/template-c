/*
 * This file is part of foobar.
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 * © 1998-2000 Terry Jones <terry@jones.com>
 *
 * See foobar/main.c for full copyright and license notice.
 */

#include <foobar/alpha/alpha.h>
#include <foobar/arg.h>

int alpha(const struct args* args) {
	if (!args->silent && args->message != NULL && puts(args->message) == EOF) {
		return 1;
	}
	return 0;
}
