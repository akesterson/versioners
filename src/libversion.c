#include <libversion.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>

struct version *lv_new(void)
{
  struct version *newversion = NULL;

  newversion = (struct version *)malloc(sizeof(struct version));
  if ( newversion == NULL ) {
        printf("Goddammit\n");
        return NULL;
    }
  memset((void *)newversion, 0x00, sizeof(struct version));
  return newversion;
}

int lv_free(struct version *tofree)
{
  if ( tofree == NULL )
    return 0;
  free((void *)tofree);
  return 1;
}
