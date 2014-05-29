#include libversion.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>

int lv_system(struct version *ver)
{
  wchar_t infoBuf[32767];
  DWORD bufCharCount = 32767;
  SYSTEM_INFO siSysInfo;

  if ( GetUserName((LPSTR)&infoBuf, (PDWORD) &bufCharCount) == 0 )
    return 0;
  ver->builduser = (wchar_t *)malloc(wcslen((wchar_t *)&infoBuf)+1);
  if ( ver->builduser == NULL )
    return 0;
  wcsncpy(ver->builduser, (wchar_t *)&infoBuf, wcslen((wchar_t *)&infoBuf));

  if ( !GetComputerName((LPSTR)&infoBuf, (PDWORD) &bufCharCount) )
    return 0;
  ver->buildhost = (wchar_t *)malloc(wcslen((wchar_t *)&infoBuf)+1);
  if ( ver->buildhost == NULL )
    return 0;
  wcsncpy(ver->buildhost, (wchar_t *)&infoBuf, wcslen((wchar_t *)&infoBuf));

  GetSystemInfo(&siSysInfo);
  memset((wchar_t *)&ver->arch, 0x00, 16);
  switch ( siSysInfo.wProcessorArchitecture ) {
  case PROCESSOR_ARCHITECTURE_AMD64 :
    swprintf((wchar_t *)&ver->arch, (wchar_t *)"x86_64");
    break;
  case PROCESSOR_ARCHITECTURE_INTEL :
    swprintf((wchar_t *)&ver->arch, (wchar_t *)"x86");
    break;
  case PROCESSOR_ARCHITECTURE_IA64 :
    swprintf((wchar_t *)&ver->arch, (wchar_t *)"ia64");
    break;
  case PROCESSOR_ARCHITECTURE_ARM :
    swprintf((wchar_t *)&ver->arch, (wchar_t *)"arm");
    break;
  }

  return 1;
}
