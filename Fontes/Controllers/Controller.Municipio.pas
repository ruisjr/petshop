unit Controller.Municipio;

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
  LController: IController;

implementation

uses
  {Classes de Negócio}
  Services.Municipio;

{ TControllerEspecie }


procedure Registry;
begin
  LController := TControllerBase.Create(TServiceMunicipio.Create);

  {Métodos Get}
  THorse.Get('/base/municipio',  TControllerBase(LController).DoGet);
  THorse.Get('/base/municipios', TControllerBase(LController).DoGets);
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
