unit Core.DataBase.Connection;

interface

uses
  {Classes de sistema}
   Uni
  ,Data.DB
  ,CRAccess
  ,Vcl.Forms
  ,UniProvider
  ,System.IniFiles
  ,System.SyncObjs
  ,System.SysUtils
  ,OracleUniProvider
  {Classes de Negócio}
  ,Core.Environment
  ,Core.DataBase.Interfaces;

type
  TDataBaseConnection = class(TInterfacedObject, IDBConnection)
  private
    FAppName: String;
    FConnection: TUniConnection;

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
    function GetConnection: TUniConnection;

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
    FConnection.Connect;
  except
    on E: Exception do
    begin
      gEnv.Log.Error(Format('%s | %s #13#10 %s', [Self.UnitName, Self.MethodName(Self), E.Message]));
      raise Exception.Create('Não foi possível abrir a conexão com o banco de dados.'+#13#10 + E.Message);
    end;
  end;
end;

constructor TDataBaseConnection.Create;
begin
  FAppName := 'SrvIntegracaoSimplus';
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
      FConnection.Disconnect;
    except
      on E : Exception do
      begin
        gEnv.Log.Error(Format('%s | %s #13#10 %s', [Self.UnitName, Self.MethodName(Self), E.Message]));
        raise Exception.Create('Não foi possível fechar a conexão com o banco de dados.' + #13#10 + E.Message);
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

function TDataBaseConnection.GetConnection: TUniConnection;
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
  vMessage: String;
begin
  FConnection := TUniConnection.Create(nil);
  try
    FConnection.ProviderName := 'Oracle';

    FConnection.AutoCommit  := False;
    FConnection.LoginPrompt := False;

    FConnection.Pooling := True;
    FConnection.PoolingOptions.Validate := True;

    FConnection.SpecificOptions.Values['Direct']     := 'False';
    FConnection.SpecificOptions.Values['DateFormat'] := 'DD/MM/RRRR';

    FConnection.DefaultTransaction.IsolationLevel := TCRIsolationLevel.ilReadCommitted;

    gEnv.Log.Error(Format('%s | Tentativa de conexão com banco de dados %s.', [Self.UnitName, FConnection.Server]));

    Self.Connect;

    gEnv.Log.Error(Format('%s | Conectado no banco de dados %s com sucesso.', [Self.UnitName, FConnection.Server]));
  except
    on E : Exception do
    begin
      vMessage := Format('%s | %s #13#10 %s #13#10 Aplicação será finalizada.', [Self.UnitName, Self.MethodName(Self), E.Message]);
      gEnv.Log.Error(vMessage);
      raise Exception.Create('Não foi possível carregar os dados da conexão com o banco de dados.' + #13#10 + E.Message);
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
