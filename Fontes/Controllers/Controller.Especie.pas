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
  TControllerEspecie = class(TControllerBase)
  public
    procedure DoGetEspecies(Req: THorseRequest; Res: THorseResponse);
  end;

  procedure Registry;
  procedure UnRegistry;

var
  LController: TControllerEspecie;

implementation

procedure Registry;
begin
  LController := TControllerEspecie.Create;
  {Métodos Get}
  THorse.Get('/pet/especie', LController.DoGetEspecies);
//  THorse.Get('/pet/raca', LController.DoGerRaca);

  {Métodos Post}
//  THorse.Post('/user', LController.DoPostUser);
end;

procedure UnRegistry;
begin
  if Assigned(LController) then
    FreeAndNil(LController);
end;

{ TControllerEspecie }

procedure TControllerEspecie.DoGetEspecies(Req: THorseRequest; Res: THorseResponse);
begin

end;

initialization;
  Registry;

finalization
  UnRegistry;

end.
