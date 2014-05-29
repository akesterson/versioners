// gitversion.c : Defines the entry point for the console application.
//

#include <stdio.h>
#include <stdlib.h>

#ifdef WIN32
#include <windows.h>
#endif // WIN32

#include <libversion.h>

int main(int argc, char *argv[])
{
    if ( fwide(stdout, 1) <= 0) {
        fprintf(stderr, "Couldn't switch to wide character output and I don't know how to cope with that\n");
        return 1;
    }
    struct version *myver = NULL;
	myver = lv_new();
	if (myver == NULL) {
		return 1;
	}
	wprintf(L"Got myver at %p\n", (void *)myver);
	lv_system(myver);
	wprintf(L"Build Host: %ls\n", myver->buildhost);
	wprintf(L"Build User: %ls\n", myver->builduser);
	wprintf(L"Build Arch: %ls\n", (wchar_t *)&myver->arch);
	lv_free(myver);
	wprintf(L"Freed myver\n");
	return 0;
}

