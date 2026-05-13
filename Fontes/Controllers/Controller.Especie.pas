unit Controller.Especie;

interface

uses
  {Classes de Sistema}
   Horse
  {Classes de Negócio}
  ,Controller.Base
  ,Core.Services.Interfaces;

  procedure Registry;
  procedure UnRegistry;

var
  LController: TControllerBase;

implementation

uses
  {Classes de Negócio}
  Services.Especie;

{ TControllerEspecie }


procedure Registry;
begin
  LController := TControllerBase.Create(TServiceEspecie.Create);

  {Métodos Get}
  THorse.Get('/pet/especie',  TControllerBase(LController).DoGet);
  THorse.Get('/pet/especies', TControllerBase(LController).DoGets);
end;

procedure UnRegistry;
begin
  LController.FreeMemory;
end;

initialization;
  Registry;

finalization
  UnRegistry;

end.
