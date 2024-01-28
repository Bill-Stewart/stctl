{ Copyright (C) 2024 by Bill Stewart (bstewart at iname.com)

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v. 2.0. If a copy of the MPL was not distributed with this file, You can
  obtain one at https://mozilla.org/MPL/2.0/.

}

unit Processes;

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}

interface

uses
  Windows;

type
  TProcessPriority = (
    Normal      = $00000020,
    Idle        = $00000040,
    High        = $00000080,
    Realtime    = $00000100,
    BelowNormal = $00004000,
    AboveNormal = $00008000);
  TWindowStyle = (
    Hide            = 0,
    ShowNormal      = 1,
    ShowMinimized   = 2,
    ShowMaximized   = 3,
    ShowNoActivate  = 4,
    Show            = 5,
    Minimize        = 6,
    ShowMinNoActive = 7,
    ShowNA          = 8,
    Restore         = 9,
    ShowDefault     = 10);
  TProcStartInfo = record
    FileName:        string;
    CommandLine:     string;
    StartDirectory:  string;
    WindowStyle:     TWindowStyle;
    ProcessPriority: TProcessPriority;
  end;

function StartProcess(var ProcStartInfo: TProcStartInfo): DWORD;

// Finds a process by full path and file name; returns zero for success, or
// non-zero for failure; Found = true if process found, or false otherwise
function TestProcess(const PathName: string; out Found: Boolean): DWORD;

implementation

const
  TH32CS_SNAPPROCESS = 2;

type
  PROCESSENTRY32W = record
    dwSize:              DWORD;
    cntUsage:            DWORD;
    th32ProcessID:       DWORD;
    th32DefaultHeapID:   ULONG_PTR;
    th32ModuleID:        DWORD;
    cntThreads:          DWORD;
    th32ParentProcessID: DWORD;
    pcPriClassBase:      LONG;
    dwFlags:             DWORD;
    szExeFile:           array[0..MAX_PATH - 1] of WCHAR;
  end;

function CreateToolhelp32Snapshot(DwFlags: DWORD;
  th32ProcessID: DWORD): HANDLE;
  stdcall; external 'kernel32.dll';

function Process32FirstW(hSnapshot: HANDLE;
  var lppe: PROCESSENTRY32W): BOOL;
  stdcall; external 'kernel32.dll';

function Process32NextW(hSnapshot: HANDLE;
  var lppe: PROCESSENTRY32W): BOOL;
  stdcall; external 'kernel32.dll';

function StartProcess(var ProcStartInfo: TProcStartInfo): DWORD;
var
  FullCommandLine: string;
  StartInfo: STARTUPINFOW;
  CreationFlags: DWORD;
  ProcInfo: PROCESS_INFORMATION;
begin
  result := ERROR_SUCCESS;
  FullCommandLine := '"' + ProcStartInfo.FileName + '" ' +
    ProcStartInfo.CommandLine;
  FillChar(StartInfo, SizeOf(StartInfo), 0);
  StartInfo.cb := SizeOf(StartInfo);
  StartInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartInfo.wShowWindow := Ord(ProcStartInfo.WindowStyle);
  CreationFlags := CREATE_NEW_CONSOLE or CREATE_UNICODE_ENVIRONMENT or
    Ord(ProcStartInfo.ProcessPriority);
  if not CreateProcessW(nil,              // LPCWSTR               lpApplicationName
    PChar(FullCommandLine),               // LPWSTR                lpCommandLine
    nil,                                  // LPSECURITY_ATTRIBUTES lpProcessAttributes
    nil,                                  // LPSECURITY_ATTRIBUTES lpThreadAttributes
    false,                                // BOOL                  bInheritHandles
    CreationFlags,                        // DWORD                 dwCreationFlags
    nil,                                  // LPVOID                lpEnvironment
    PChar(ProcStartInfo.StartDirectory),  // LPCWSTR               lpCurrentDirectory
    StartInfo,                            // LPSTARTUPINFOW        lpStartupInfo
    ProcInfo) then                        // LPPROCESS_INFORMATION lpProcessInformation
  begin
    result := GetLastError();
  end;
end;

// Gets executable filename for current process
function GetProcessExecutable(const ProcessID: DWORD): string;
const
  MAX_LEN = 32768;
var
  Access, NumChars: DWORD;
  ProcHandle: HANDLE;
  pName: PChar;
begin
  result := '';
  Access := PROCESS_QUERY_LIMITED_INFORMATION;
  ProcHandle := OpenProcess(Access,  // DWORD dwDesiredAccess
    false,                           // BOOL  bInheritHandle
    ProcessID);                      // DWORD dwProcessId
  if ProcHandle = 0 then
    exit;
  NumChars := MAX_LEN;
  GetMem(pName, NumChars);
  if QueryFullProcessImageNameW(ProcHandle,  // HANDLE hProcess
    0,                                       // DWORD  dwFlags
    pName,                                   // LPWSTR lpExeName
    @NumChars) then                          // PDWORD lpdwSize
  begin
    SetLength(result, NumChars);
    Move(pName^, result[1], NumChars * SizeOf(Char));
  end;
  FreeMem(pName);
  CloseHandle(ProcHandle);  // HANDLE hObject
end;

function SameText(const S1, S2: string): Boolean;
const
  CSTR_EQUAL = 2;
begin
  result := CompareStringW(GetThreadLocale(),  // LCID    Locale
    LINGUISTIC_IGNORECASE,                     // DWORD   dwCmpFlags
    PChar(S1),                                 // PCNZWCH lpString1
    -1,                                        // int     cchCount1
    PChar(S2),                                 // PCNZWCH lpString2
    -1) = CSTR_EQUAL;                          // int     cchCount2
end;

function TestProcess(const PathName: string; out Found: Boolean): DWORD;
var
  Snapshot: HANDLE;
  ProcessEntry: PROCESSENTRY32W;
  OK: BOOL;
  Name: string;
begin
  result := ERROR_SUCCESS;
  Snapshot := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS,  // DWORD dwFlags
    0);                                                     // DWORD th32ProcessID
  if Snapshot = INVALID_HANDLE_VALUE then
  begin
    result := GetLastError();
    exit;
  end;
  ProcessEntry.dwSize := SizeOf(PROCESSENTRY32W);
  if Process32FirstW(Snapshot,  // HANDLE            hSnapshot
    ProcessEntry) then          // LPPROCESSENTRY32W lppe
  begin
    Found := false;
    repeat
      Name := GetProcessExecutable(ProcessEntry.th32ProcessID);
      if (Name <> '') and SameText(Name, PathName) then
      begin
        Found := true;
        break;
      end;
      OK := Process32NextW(Snapshot,  // HANDLE            hSnapshot
        ProcessEntry);                // LPPROCESSENTRY32W lppe
    until not OK;
  end
  else
    result := GetLastError();
  CloseHandle(Snapshot);  // HANDLE hObject
end;

begin
end.
