/*
 * foobar - Print a greeting
 *
 * © 1998-2000 Terry Jones <terry@jones.com>
 *
 * foobar is free software: you can redistribute it and/or modify it under the
 * terms of the GNU General Public License as published by the Free Software
 * Foundation, either version 3 of the License, or (at your option) any later
 * version.
 *
 * foobar is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * foobar. If not, see <https://www.gnu.org/licenses/>.
 */

#include <foobar/arg.h>

int main(int argc, char* argv[]) {
	struct args args;

	if (arg_parse(argc, argv, &args) != 0) {
		usage(stderr, &args);
		return 1;
	}

	return arg_run(&args);
}
