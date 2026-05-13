unit Controller.Pessoa;

interface

uses
  {Classes de Sistema}
   Horse
  {Classes de Negócio}
  ,Controller.Base
  ,Core.Services.Interfaces;


var
  LController: IController;

procedure Registry;
procedure UnRegistry;

implementation

uses
  {Classes de Negócio}
  Services.Pessoa;

{ TControllerPessoa }

procedure Registry;
begin
  LController := TControllerBase.Create(TServicePessoa.Create);

  {Métodos Get}
  THorse.Get('/pessoa', TControllerBase(LController).DoGet);
  THorse.Get('/pessoas', TControllerBase(LController).DoGets);

  {Métodos Post}
  THorse.Post('/pessoa', TControllerBase(LController).DoPost);
end;

procedure UnRegistry;
begin
  LController.FreeMemory;
end;

initialization
  Registry;

finalization
  UnRegistry;

end.
