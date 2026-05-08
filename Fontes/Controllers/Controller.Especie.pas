unit Controller.Especie;

interface

uses
  {Classes de Sistema}
   Horse
  ,Horse.Commons
  ,System.SysUtils
  {Classes de Negócio}
  ,Controller.Base;

type
  TControllerEspecie = class(TControllerBase);

  procedure Registry;
  procedure UnRegistry;

var
  LController: TControllerEspecie;

implementation

uses
  {Classes de Sistema}
   System.JSON
  {Classes de Negócio}
  ,Core.Functions
  ,Services.Especie;

{ TControllerEspecie }


procedure Registry;
begin
  LController := TControllerEspecie.Create(TServiceEspecie.Create);

  {Métodos Get}
  THorse.Get('/pet/especie',  LController.DoGet);
  THorse.Get('/pet/especies', LController.DoGet);
end;

procedure UnRegistry;
begin
  if Assigned(LController) then
    FreeAndNil(LController);
end;

initialization;
  Registry;

finalization
  UnRegistry;

end.
