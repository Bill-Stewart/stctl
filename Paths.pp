{ Copyright (C) 2024 by Bill Stewart (bstewart at iname.com)

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v. 2.0. If a copy of the MPL was not distributed with this file, You can
  obtain one at https://mozilla.org/MPL/2.0/.

}

unit Paths;

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}

interface

function ExtractFileDir(const FileName: string): string;

function FileExists(const FileName: string): Boolean;

function JoinPath(Path1, Path2: string): string;

function GetFileVersion(const FileName: string): string;

implementation

uses
  Windows;

const
  INVALID_FILE_ATTRIBUTES = $FFFFFFFF;

function ExtractFileDir(const FileName: string): string;
var
  I: Integer;
begin
  I := Length(FileName);
  while (I > 0) and (not ((FileName[I] = ':') or (FileName[I] = '\'))) do
    Dec(I);
  if (I > 1) and (FileName[I] = '\') and
    (not ((FileName[I - 1] = ':') or (FileName[I - 1] = '\'))) then
    Dec(I);
  result := Copy(FileName, 1, I);
end;

function FileExists(const FileName: string): Boolean;
var
  Attrs: DWORD;
begin
  Attrs := GetFileAttributesW(PChar(FileName));  // LPCWSTR lpFileName
  result := (Attrs <> INVALID_FILE_ATTRIBUTES) and
    ((Attrs and FILE_ATTRIBUTE_DIRECTORY) = 0);
end;

// Appends Path2 to Path1, eliminating duplicate '\', using a single '\'
function JoinPath(Path1, Path2: string): string;
begin
  if (Length(Path1) > 0) and (Length(Path2) > 0) then
  begin
    while Path1[Length(Path1)] = '\' do
      Path1 := Copy(Path1, 1, Length(Path1) - 1);
    while Path2[1] = '\' do
      Path2 := Copy(Path2, 2, Length(Path2) - 1);
    result := Path1 + '\' + Path2;
  end
  else
    result := '';
end;

function IntToStr(const I: LongInt): string;
begin
  Str(I, result);
end;

function GetFileVersion(const FileName: string): string;
var
  VerInfoSize, Handle: DWORD;
  pBuffer: Pointer;
  pFileInfo: ^VS_FIXEDFILEINFO;
  Len: UINT;
begin
  result := '';
  VerInfoSize := GetFileVersionInfoSizeW(PChar(FileName),  // LPCWSTR lptstrFilename
    Handle);                                               // LPDWORD lpdwHandle
  if VerInfoSize > 0 then
  begin
    GetMem(pBuffer, VerInfoSize);
    if GetFileVersionInfoW(PChar(FileName),  // LPCWSTR lptstrFilename
      Handle,                                // DWORD   dwHandle
      VerInfoSize,                           // DWORD   dwLen
      pBuffer) then                          // LPVOID  lpData
    begin
      if VerQueryValueW(pBuffer,  // LPCVOID pBlock
        '\',                      // LPCWSTR lpSubBlock
        pFileInfo,                // LPVOID  *lplpBuffer
        Len) then                 // PUINT   puLen
      begin
        with pFileInfo^ do
        begin
          result := IntToStr(HiWord(dwFileVersionMS)) + '.' +
            IntToStr(LoWord(dwFileVersionMS)) + '.' +
            IntToStr(HiWord(dwFileVersionLS));
          // LoWord(dwFileVersionLS) intentionally omitted
        end;
      end;
    end;
    FreeMem(pBuffer);
  end;
end;

begin
end.
