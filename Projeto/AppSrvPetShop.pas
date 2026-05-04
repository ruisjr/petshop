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

{$R *.dfm}

procedure TFrmPrincipal.btnStartClick(Sender: TObject);
begin
  if not THorse.IsRunning then
    THorse.Listen(spePorta.Value);
end;

procedure TFrmPrincipal.btnStopClick(Sender: TObject);
begin
  if THorse.IsRunning then
    THorse.StopListen;
end;

end.
