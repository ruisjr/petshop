unit Core.Servico;

interface

Uses
  {Classes de sistema}
   Vcl.Forms
  ,System.Classes
  ,Winapi.Windows
  ,System.SysUtils
  {Classes de Negócio}
  ,PrgLog
  ,Core.DataBase.Types
  ,Core.Thread;


type
  TServicoBase = class(TPersistent)
  private
    FThread: TThreadIntegracaoBase;
  public
    destructor Destroy; override;

    {Procedures}
    procedure Iniciar; virtual;
    procedure Finalizar; virtual;
    procedure ExecutarEnvio; virtual;

    {Functions}
    function GetSituacao: TStatusService; virtual;

    property PThread: TThreadIntegracaoBase read FThread write FThread;
  end;

implementation

{ TServicoProdutos }

destructor TServicoBase.Destroy;
begin
  vgLog.DebugOutThread(Self.UnitName + ' | Destruindo thread...', []);
  FreeAndNil(FThread);
  inherited;
end;

procedure TServicoBase.ExecutarEnvio;
begin
  PThread.ExecutarEnvio;
end;

procedure TServicoBase.Finalizar;
var
  vInicioTick: Cardinal;
begin
  if Assigned(FThread) then
  begin
    vInicioTick := GetTickCount;
    if FThread.Finished then
      Exit;

    // Aguarda terminar com timeout
    while (GetTickCount - vInicioTick) < 10000 do
    begin
      if FThread.Finished then
        Break;
      Application.ProcessMessages;
      Sleep(100);
    end;

    if not FThread.Finished then
    begin
      vgLog.DebugOutThread(Self.UnitName + ' | Finalizando thread...', []);
      FThread.OnTerminate := nil;
      FThread.Terminate;
      FThread.WaitFor;
    end
  end;
end;

function TServicoBase.GetSituacao: TStatusService;
begin
  Result := ssCreated;
  if Assigned(PThread) then
    Result := PThread.Status;
end;

procedure TServicoBase.Iniciar;
begin
  FThread.Start;
end;

end.
