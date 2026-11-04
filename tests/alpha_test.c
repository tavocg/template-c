#include <assert.h>
#include <foobar/alpha/alpha.h>
#include <foobar/arg.h>

int main(void) {
	int         i;
	int         status;
	struct args args = {0};
	for (i = 0; i < 3; i++) {
		status = alpha(&args);
		assert(status == 0);
	}
	return 0;
}
