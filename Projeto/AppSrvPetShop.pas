unit AppSrvPetShop;

interface

uses
  {Classes de Sistema}
   Horse
  ,Vcl.Forms
  ,Vcl.Dialogs
  ,Vcl.StdCtrls
  ,Vcl.Graphics
  ,Vcl.Controls
  ,Winapi.Windows
  ,Winapi.Messages
  ,System.SysUtils
  ,System.Variants
  ,System.Classes
  ,Vcl.Samples.Spin;

type
  TFrmPrincipal = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    lblPorta: TLabel;
    spePorta: TSpinEdit;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

uses
  {Classes de Negócio}
  Core.Environment;

{$R *.dfm}

procedure TFrmPrincipal.btnStartClick(Sender: TObject);
begin
  if not THorse.IsRunning then
  begin
    THorse.Listen(spePorta.Value);d
    Env.Log.Info(Format('Serviço iniciado na porta %d.', [spePorta.Value]));
  end;
end;

procedure TFrmPrincipal.btnStopClick(Sender: TObject);
begin
  if THorse.IsRunning then
  begin
    THorse.StopListen;
    Env.Log.Info('Serviço finalizado com sucesso.');
  end;
end;

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  btnStopClick(Sender);
end;

end.
