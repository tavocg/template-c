#include "alpha.h"
#include <assert.h>
#include <foobar/alpha/alpha.h>
#include <foobar/arg.h>

void call_alpha(void) {
	struct args args = {0};
	int         status;
	status = alpha(&args);
	assert(status == 0);
}
