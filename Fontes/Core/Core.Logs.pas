unit Core.Logs;

interface

uses
  {Classes de Sistema}
   Vcl.Forms
  ,Quick.Logger
  ,System.SysUtils
  ,Quick.Logger.Provider.Files
  ,Quick.Logger.Provider.Console;

Type
  iLog = interface
    ['{EBF2E3E8-9699-41AE-AC7C-0A06C4757E7D}']
    function Info(vMessage: String): iLog;
    function Debug(vMessage: String): iLog;
    function Error(vMessage: String): iLog;
    function Warning(vMessage: String): iLog;
  end;

  TLog = class(TInterfacedObject, iLog)
  strict private

  public
    class function New: iLog;

    function Info(vMessage: String): iLog;
    function Debug(vMessage: String): iLog;
    function Error(vMessage: String): iLog;
    function Warning(vMessage: String): iLog;
  end;

implementation

uses
  {Classes de Sistema}
  System.IOUtils;

{ TLog }

function TLog.Debug(vMessage: String): iLog;
begin
  Log(vMessage, etDebug);
end;

function TLog.Error(vMessage: String): iLog;
begin
  Log(vMessage, etError);
end;

function TLog.Info(vMessage: String): iLog;
begin
  Log(vMessage, etInfo);
end;

class function TLog.New: iLog;
begin
  Result := Self.create;
end;

function TLog.Warning(vMessage: String): iLog;
begin
  Log(vMessage, etWarning);
end;

initialization
  //Add Log File and console providers
  Logger.Providers.Add(GlobalLogFileProvider);
  Logger.Providers.Add(GlobalLogConsoleProvider);
  {Configure provider options}
  GlobalLogFileProvider.FileName := StringReplace(ExtractFilePath(Application.ExeName), 'Bin\', 'Log\', [rfReplaceAll])
                                  + StringReplace(ExtractFileName(Application.ExeName), 'exe', 'log', [rfReplaceAll]);

  if not TDirectory.Exists(StringReplace(ExtractFilePath(Application.ExeName), 'Bin\', 'Log\', [rfReplaceAll])) then
    TDirectory.CreateDirectory(StringReplace(ExtractFilePath(Application.ExeName), 'Bin\', 'Log\', [rfReplaceAll]));

  GlobalLogFileProvider.Enabled         := True;
  GlobalLogFileProvider.LogLevel        := LOG_DEBUG;
  GlobalLogFileProvider.DailyRotate     := True;
  GlobalLogFileProvider.MaxFileSizeInMB := 20;


  with GlobalLogConsoleProvider do
  begin
    Enabled         := True;
    LogLevel        := LOG_DEBUG;
    ShowEventColors := True;
  end;
end.
