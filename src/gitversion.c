// gitversion.c : Defines the entry point for the console application.
//

#include <stdio.h>
#include <stdlib.h>

#ifdef WIN32
#include <windows.h>
#endif // WIN32

#include "libversion.h"

int main(int argc, char *argv[])
{
    struct version *myver = NULL;
    printf("Wat wat\n");
	myver = lv_new();
	if (myver == NULL) {
        printf("Goddammit\n");
		return 1;
	}
	printf("Got myver at %p\n", (void *)myver);
	lv_system(myver);
	wprintf((wchar_t *)"Build Host: %s\n", myver->buildhost);
	//wprintf((wchar_t *)"Build User: %s\n", myver->builduser);
	// wprintf("Build Arch: %s\n", (T_CHARPTR)&myver->arch);
	lv_free(myver);
	//wprintf((wchar_t *)"Freed myver\n");
	return 0;
}

