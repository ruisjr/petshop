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
  ,Vcl.Samples.Spin
  {Classes de Negócio}
  ,Controller.User;

type
  TFrmPrincipal = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    lblPorta: TLabel;
    spePorta: TSpinEdit;
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
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
    THorse.Listen(spePorta.Value);
    Env.Log.Debug(Format('Serviço iniciado na porta %d.', [spePorta.Value]));
  end;
end;

procedure TFrmPrincipal.btnStopClick(Sender: TObject);
begin
  if THorse.IsRunning then
  begin
    THorse.StopListen;
    Env.Log.Debug('Serviço finalizado com sucesso.');
  end;
end;

end.
