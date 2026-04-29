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
  {Classes de Negócio}
  ,Core.Environment
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
  gEnv.Log.Info('Iniciando serviço.');
  try
    Started := True;
    gEnv.Log.Info('Serviço iniciado com sucesso.');
  except
    on E: Exception do
      begin
        gEnv.Log.Info('Erro ao iniciar serviço.' + #13#10+ E.Message);
        Started := False;
      end;
  end;
end;

procedure TSrvPetShopApp.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  gEnv.Log.Info('Parando serviço.');
  FEventoParada.SetEvent;

  FreeAndNil(FEventoParada);

  Stopped := True;
  gEnv.Log.Info('Serviço parado com sucesso.');
end;

end.
