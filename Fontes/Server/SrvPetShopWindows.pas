unit SrvPetShopWindows;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.SvcMgr, Vcl.Dialogs;

type
  TSrvPetShopApp = class(TService)
    procedure ServiceExecute(Sender: TService);
  private
    { Private declarations }
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

end.
