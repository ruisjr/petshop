unit SrvPetShopWindows;

interface

uses
  {Classes de Sistema}
   Vcl.SvcMgr
  ,Vcl.Dialogs
  ,Vcl.Graphics
  ,Vcl.Controls
  ,System.Classes
  ,Winapi.Windows
  ,System.SysUtils
  ,System.SyncObjs
  ,Winapi.Messages
  ;

type
  TSrvPetShopApp = class(TService)
    procedure ServiceExecute(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    { Private declarations }
    FEventoParada: TEvent;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  SrvPetShopApp: TSrvPetShopApp;

implementation

uses
  {Classes de Sistema}
   Horse
  {Classes de Negócio}
  ,Core.Global
  ,Core.Environment;


{$R *.dfm}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  SrvPetShopApp.Controller(CtrlCode);
end;

function TSrvPetShopApp.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TSrvPetShopApp.ServiceExecute(Sender: TService);
begin
  while not terminated do
  begin
    ServiceThread.ProcessRequests(True);
  end;
end;

procedure TSrvPetShopApp.ServiceStart(Sender: TService; var Started: Boolean);
begin
  FEventoParada := TEvent.Create(nil, True, False, '');
  Env.Log.Info('Iniciando serviço.');
  try
    if not THorse.IsRunning then
    begin
      THorse.Listen(GetPortService);
      Env.Log.Debug(Format('Serviço iniciado na porta %d.', [GetPortService]));
      Started := True;
      Env.Log.Info('Serviço iniciado com sucesso.');
    end;
  except
    on E: Exception do
      begin
        Env.Log.Info('Erro ao iniciar serviço.' + #13#10+ E.Message);
        Started := False;
      end;
  end;
end;

procedure TSrvPetShopApp.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  Env.Log.Info('Parando serviço.');
  FEventoParada.SetEvent;

  FreeAndNil(FEventoParada);

  if THorse.IsRunning then
  begin
    THorse.StopListen;
    Stopped := True;
    Env.Log.Debug('Serviço finalizado com sucesso.');
  end;
end;

end.
