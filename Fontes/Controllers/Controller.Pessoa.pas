unit Controller.Pessoa;

interface

uses
  {Classes de Sistema}
   Horse
  ,Horse.Commons
  ,System.SysUtils
  {Classes de Negócio}
  ,Controller.Base;

type
  TControllerPessoa = class(TControllerBase);

var
  LController: TControllerPessoa;

procedure Registry;
procedure UnRegistry;

implementation

uses
  {Classes de Sistema}
   System.JSON
  {Classes de Negócio}
  ,Services.Pessoa;

{ TControllerPessoa }

procedure Registry;
begin
  LController := TControllerPessoa.Create(TServicePessoa.Create);

  {Métodos Get}
  THorse.Get('/pessoa', LController.DoGet);
//  THorse.Get('/pessoas', LController.DoGetPessoas);

  {Métodos Post}
  THorse.Post('/pessoa', LController.DoPost);
end;

procedure UnRegistry;
begin
  FreeAndNil(LController);
end;

initialization
  Registry;

finalization
  UnRegistry;

end.
