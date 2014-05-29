#ifndef _LIBVERSION_H_

#ifdef WIN32
#include <windows.h>
#endif

#ifndef WIN32
#include <sys/utsname.h>
#endif

#include <wchar.h>

struct version {
  wchar_t *tag;
  wchar_t *branch;
  wchar_t *major;
  unsigned int build;
  char sha1[64];
  wchar_t *os_name;
  wchar_t *os_version;
  wchar_t arch[16];
  wchar_t *version;
  wchar_t *buildhost;
  wchar_t *builduser;
  wchar_t *source;
  char rebuilding;
  wchar_t *changelog;
};

extern struct version *lv_new(void);
extern int lv_free(struct version *);
extern int lv_system(struct version *);
#endif // _LIBVERSION_H_
