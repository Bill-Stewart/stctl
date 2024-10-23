{ Copyright (C) 2024 by Bill Stewart (bstewart at iname.com)

  This Source Code Form is subject to the terms of the Mozilla Public License,
  v. 2.0. If a copy of the MPL was not distributed with this file, You can
  obtain one at https://mozilla.org/MPL/2.0/.

}

program stctl;

{$MODE OBJFPC}
{$MODESWITCH UNICODESTRINGS}
{$R *.res}

// wargcv and wgetopts: https://github.com/Bill-Stewart/wargcv
uses
  Windows,
  wargcv,
  wgetopts,
  WindowsMessages,
  Paths,
  Processes;

const
  PROGRAM_NAME = 'stctl';
  MSGBOX_TITLE = 'Syncthing';
  PROGRAM_COPYRIGHT = 'Copyright (C) 2024 by Bill Stewart';

type
  TAction = (None, Start, Stop);

procedure Usage();
var
  Msg: string;
begin
  Msg := PROGRAM_NAME + ' ' + GetFileVersion(ParamStr(0)) +  ' - ' + PROGRAM_COPYRIGHT + sLineBreak
    + 'This is free software and comes with ABSOLUTELY NO WARRANTY.' + sLineBreak
    + sLineBreak
    + 'SYNOPSIS' + sLineBreak
    + sLineBreak
    + 'Starts or stops Syncthing for the current user.' + sLineBreak
    + sLineBreak
    + 'USAGE' + sLineBreak
    + sLineBreak
    + PROGRAM_NAME + ' --start [-q] [-- <syncthing parameters>]' + sLineBreak
    + '* Starts Syncthing for the current user' + sLineBreak
    + sLineBreak
    + PROGRAM_NAME + ' --stop [-q]' + sLineBreak
    + '* Stops Syncthing for the current user' + sLineBreak
    + sLineBreak
    + '(Optional) -q suppresses dialog boxes.';

    MessageBoxW(0,          // HWND    hWnd
      PChar(Msg),           // LPCWSTR lpText
      MSGBOX_TITLE,         // LPCWSTR lpCaption
      MB_ICONINFORMATION);  // UINT    uType
end;

function IsProcessRunning(const PathName: string): Boolean;
var
  Found: Boolean;
begin
  result := false;
  if TestProcess(PathName, Found) = ERROR_SUCCESS then
    result := Found;
end;

var
  Opts: array[1..5] of TOption;
  Action: TAction;
  Quiet: Boolean;
  I: Integer;
  Opt: Char;
  StartDir, Msg, CommandTail: string;
  ProcStartInfo: TProcStartInfo;
  RC: DWORD;

begin
  OptErr := false;
  with Opts[1] do
  begin
    Name := 'help';
    Has_arg := No_Argument;
    Flag := nil;
    Value := 'h';
  end;
  with Opts[2] do
  begin
    Name := 'quiet';
    Has_arg := No_Argument;
    Flag := nil;
    Value := 'q';
  end;
  with Opts[3] do
  begin
    Name := 'start';
    Has_arg := No_Argument;
    Flag := nil;
    Value := 's';
  end;
  with Opts[4] do
  begin
    Name := 'stop';
    Has_arg := No_Argument;
    Flag := nil;
    Value := 't';
  end;
  with Opts[5] do
  begin
    Name := '';
    Has_arg := No_Argument;
    Flag := nil;
    Value := #0;
  end;
  Action := None;
  Quiet := false;
  repeat
    Opt := GetLongOpts('hqst', @Opts[1], I);
    case Opt of
      'h':
      begin
      end;
      'q':
      begin
        Quiet := true;
      end;
      's':
      begin
        if Action = None then
          Action := Start;
      end;
      't':
      begin
        if Action = None then
          Action := Stop;
      end;
    end;
  until Opt = EndOfOptions;

  if Action = None then
  begin
    Usage();
    exit;
  end;

  StartDir := ExtractFileDir(ParamStr(0));
  with ProcStartInfo do
  begin
    FileName := JoinPath(StartDir, 'syncthing.exe');
    StartDirectory := StartDir;
    WindowStyle := Hide;
    ProcessPriority := BelowNormal;
  end;

  if not FileExists(ProcStartInfo.FileName) then
  begin
    RC := ERROR_FILE_NOT_FOUND;
    Msg := ProcStartInfo.FileName + sLineBreak
      + sLineBreak
      + GetWindowsMessage(RC, true);
    MessageBoxW(0,    // HWND    hWnd
      PChar(Msg),     // LPCWSTR lpText
      MSGBOX_TITLE,   // LPCWSTR lpCaption
      MB_ICONERROR);  // UINT    uType
    ExitCode := Integer(RC);
    exit;
  end;

  RC := ERROR_SUCCESS;

  case Action of
    Start:
    begin
      if not IsProcessRunning(ProcStartInfo.FileName) then
      begin
        ProcStartInfo.CommandLine := '--no-browser';
        CommandTail := string(GetCommandTail(GetCommandLineW(), OptInd));
        if CommandTail <> '' then
          ProcStartInfo.CommandLine := ProcStartInfo.CommandLine + ' ' + CommandTail;
        RC := StartProcess(ProcStartInfo);
      end
      else
      begin
        if not Quiet then
          MessageBoxW(0,                      // HWND    hWnd
            'Syncthing is already running.',  // LPCWSTR lpText
            MSGBOX_TITLE,                     // LPCWSTR lpCaption
            MB_ICONINFORMATION);              // UINT    uType
      end;
    end;
    Stop:
    begin
      if IsProcessRunning(ProcStartInfo.FileName) then
      begin
        ProcStartInfo.CommandLine := 'cli operations shutdown';
        RC := StartProcess(ProcStartInfo);
      end
      else
      begin
        if not Quiet then
          MessageBoxW(0,                  // HWND    hWnd
            'Syncthing is not running.',  // LPCWSTR lpText
            MSGBOX_TITLE,                 // LPCWSTR lpCaption
            MB_ICONINFORMATION);          // UINT    uType
      end;
    end;
  end;

  if RC <> ERROR_SUCCESS then
    MessageBoxW(0,                         // HWND    hWnd
      PChar(GetWindowsMessage(RC, true)),  // LPCWSTR lpText
      MSGBOX_TITLE,                        // LPCWSTR lpCaption
      MB_ICONERROR);                       // UINT    uType

  ExitCode := Integer(RC);
end.
