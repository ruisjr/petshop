unit Core.DataBase.Connection;

interface

uses
  {Classes de sistema}
   FireDAC.DatS
  ,FireDAC.DApt
  ,FireDAC.Phys
  ,FireDAC.UI.Intf
  ,FireDAC.Phys.PG
  ,FireDAC.Stan.Def
  ,FireDAC.DApt.Intf
  ,FireDAC.Stan.Intf
  ,FireDAC.Phys.Intf
  ,FireDAC.Stan.Pool
  ,FireDAC.VCLUI.Wait
  ,FireDAC.Stan.Param
  ,FireDAC.Stan.Async
  ,FireDAC.Stan.Error
  ,FireDAC.Phys.PGDef
  ,FireDAC.Stan.Option
  ,Firedac.Comp.Client
  ,FireDAC.Comp.DataSet
  ,Data.DB
  ,Vcl.Forms
  ,System.IniFiles
  ,System.SyncObjs
  ,System.SysUtils
  {Classes de Negócio}
  ,Core.Environment
  ,Core.DataBase.Interfaces;

type
  TDataBaseConnection = class(TInterfacedObject, IDBConnection)
  private
    FLink: TFDPhysPGDriverLink;
    FAppName: String;
    FConnection: TFDConnection;

    class var FInstance: IDBConnection;
    class var FConnectionLock: TCriticalSection;
  public
    {Construtores e Destrutores}
    constructor Create;
    destructor Destroy; override;

    {Class Functions}
    class function GetInstance: IDBConnection;
    class procedure FreeInstance; reintroduce;

    {Functions}
    function GetConnection: TFDConnection;

    {procedures}
    procedure Connect;
    procedure Disconnect;
    procedure LoadConfig;
    procedure BeginTransaction;
    procedure CommitTransaction;
    procedure RollBackTransaction;
  end;

var
  vgDBConnection: TDataBaseConnection;

implementation

uses
  Core.Global;

{ TDataBaseConnection }

procedure TDataBaseConnection.BeginTransaction;
begin
  if (not FConnection.InTransaction) then
    FConnection.StartTransaction;
end;

procedure TDataBaseConnection.CommitTransaction;
begin
  if FConnection.InTransaction then
    FConnection.Commit;
end;

procedure TDataBaseConnection.Connect;
begin
  try
    FConnection.Connected := True;
  except
    on E: Exception do
    begin
      gEnv.Log.Error(Format('%s | %s #13#10 %s', [Self.UnitName, Self.MethodName(Self), E.Message]));
      raise Exception.Create('The connection to the database could not be opened.'+#13#10 + E.Message);
    end;
  end;
end;

constructor TDataBaseConnection.Create;
begin
  FAppName := cAppName;
  LoadConfig;
end;

destructor TDataBaseConnection.Destroy;
begin
  if FConnection.Connected then
    FConnection.Close;

  FreeAndNil(FConnection);
  inherited;
end;

procedure TDataBaseConnection.Disconnect;
begin
  if (FConnection.Connected) then
  begin
    try
      FConnection.Connected := False;
    except
      on E : Exception do
      begin
        gEnv.Log.Error(Format('%s | %s #13#10 %s', [Self.UnitName, Self.MethodName(Self), E.Message]));
        raise Exception.Create('The connection to the database could not be closed.' + #13#10 + E.Message);
      end;
    end;
  end;
end;

class procedure TDataBaseConnection.FreeInstance;
begin
  FConnectionLock.Enter;
  try
    FInstance := nil;
  finally
    FConnectionLock.Leave;
  end;
end;

function TDataBaseConnection.GetConnection: TFDConnection;
begin
  Result := FConnection;
end;

class function TDataBaseConnection.GetInstance: IDBConnection;
begin
  FConnectionLock.Enter;
  try
    if FInstance = nil then
      FInstance := TDataBaseConnection.Create;

    Result := FInstance;
  finally
    FConnectionLock.Leave;
  end;
end;

procedure TDataBaseConnection.LoadConfig;
var
  path: String;
  arqIni: TIniFile;
  vMessage: String;
begin
  try
    path := StringReplace(ExtractFilePath(Application.ExeName),'bin\', '', [rfReplaceAll]) + 'drivers\FDConnectionDefs.ini';
    arqIni := TIniFile.Create(path);
    try
      FLink := TFDPhysPGDriverLink.Create(nil);
      FLink.Release;
      FLink.VendorLib := StringReplace(ExtractFilePath(Application.ExeName), 'bin\', '', [rfReplaceAll]) + 'lib\libpq.dll';

      FConnection := TFDConnection.Create(nil);

      FConnection.DriverName        := arqIni.ReadString(FAppName, 'DriverID', 'PG');
      FConnection.ConnectionName    := FAppName;
      FConnection.ConnectionDefName := FAppName;
      FConnection.LoginPrompt       := False;
      FConnection.Name              := 'conn' + FAppName;

      with (TFDPhysPGConnectionDefParams(FConnection.Params)) do
      begin
        Port            := arqIni.ReadInteger(FAppName, 'Port', 5432);
        Server          := arqIni.ReadString(FAppName, 'Server', 'localhost');
        DriverID        := arqIni.ReadString(FAppName, 'DriverID', '');
        Database        := arqIni.ReadString(FAppName, 'Database', '');
        Password        := arqIni.ReadString(FAppName, 'Password', 'postgres');
        UserName        := arqIni.ReadString(FAppName, 'User_Name', 'postgres');
        LoginTimeout    := arqIni.ReadInteger(FAppName, 'Timeout', 30);
        ApplicationName := FAppName;
        CharacterSet    := csUTF8;
      end;

      FConnection.Params.UserName := arqIni.ReadString(FAppName, 'User_Name', 'postgres');
      FConnection.Params.Password := arqIni.ReadString(FAppName, 'Password', 'postgres');

      gEnv.Log.Info(Self.UnitName + Format(' | Connected to the database %s.', [FConnection.ConnectionName]));
//      Self.Connect;
    finally
      FreeAndNil(arqIni);
    end;
  except
    on E: Exception do
    begin
      vMessage := Self.UnitName + ' | ' + Self.MethodName(Self) + #13#10 + E.Message + #13#10 + 'The application will be finalized.';
      gEnv.Log.Error(vMessage);
      raise Exception.Create('The database connection data could not be loaded.' + #13#10 + E.Message);
    end;
  end;
end;

procedure TDataBaseConnection.RollBackTransaction;
begin
  if FConnection.InTransaction then
    FConnection.Rollback;
end;

initialization
begin
  vgDBConnection := TDataBaseConnection.Create;
  vgDBConnection.FConnectionLock := TCriticalSection.Create;
end;

finalization
begin
  vgDBConnection.Disconnect;

  TDataBaseConnection.FreeInstance;
  FreeAndNil(TDataBaseConnection.FConnectionLock);
  FreeAndNil(vgDBConnection);
end;


end.
