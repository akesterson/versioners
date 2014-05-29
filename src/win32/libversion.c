#include <libversion.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <winsock2.h>
#include <wchar.h>

int lv_system(struct version *ver)
{
  wchar_t infoBuf[32767];
  DWORD bufCharCount = 32767;
  SYSTEM_INFO siSysInfo;
  WSADATA wsaData;
  char hostname[256];

  memset((void *)&infoBuf, 0x00, 32767);
  if ( GetUserNameW((LPWSTR)&infoBuf, (PDWORD) &bufCharCount) == 0 )
    return 0;
  ver->builduser = (wchar_t *)malloc(sizeof(wchar_t) * wcslen((wchar_t *)&infoBuf));
  if ( ver->builduser == NULL )
    return 0;
  memset((void *)ver->builduser, 0x00, ( sizeof(wchar_t) * wcslen((wchar_t *)&infoBuf)));
  wcsncpy(ver->builduser, (wchar_t *)&infoBuf, wcslen((wchar_t *)&infoBuf));

  memset((void *)&hostname, 0x00, 256);
  if ( WSAStartup(MAKEWORD(2, 2), &wsaData) != 0 ) {
    wprintf(L"Unable to initialize winsock (to get hostname)\n");
    return 1;
  }
  if ( gethostname((char *)&hostname, 256) == SOCKET_ERROR ) {
    wprintf(L"WSAGetLastError: %d", WSAGetLastError()) ;
    return 0;
  }
  int tsize = (sizeof(wchar_t) * strlen((char *)&hostname));
  ver->buildhost = (wchar_t *)malloc(tsize);
  if ( ver->buildhost == NULL )
    return 0;
  memset(ver->buildhost, 0x00, tsize);
  wsprintfW((LPWSTR)ver->buildhost, L"%S", (char *)&hostname);

  GetSystemInfo(&siSysInfo);
  memset((wchar_t *)&ver->arch, 0x00, 16);
  switch ( siSysInfo.wProcessorArchitecture ) {
  case PROCESSOR_ARCHITECTURE_AMD64 :
    wsprintfW((wchar_t *)&ver->arch, L"x86_64");
    break;
  case PROCESSOR_ARCHITECTURE_INTEL :
    wsprintfW((wchar_t *)&ver->arch, L"x86");
    break;
  case PROCESSOR_ARCHITECTURE_IA64 :
    wsprintfW((wchar_t *)&ver->arch, L"ia64");
    break;
  case PROCESSOR_ARCHITECTURE_ARM :
    wsprintfW((wchar_t *)&ver->arch, L"arm");
    break;
  }

  return 1;
}
