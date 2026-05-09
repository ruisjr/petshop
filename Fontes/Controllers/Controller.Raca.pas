unit Controller.Raca;

interface

uses
  {Classes de Sistema}
   Horse
  {Classes de Negócio}
  ,Controller.Base;

  procedure Registry;
  procedure UnRegistry;

var
  LController: TControllerBase;

implementation

uses
  {Classes de Sistema}
   System.JSON
  {Classes de Negócio}
  ,Core.Functions
  ,Services.Raca;

{ TControllerEspecie }


procedure Registry;
begin
  LController := TControllerBase.Create(TServiceRaca.Create);

  {Métodos Get}
  THorse.Get('/pet/raca',  TControllerBase(LController).DoGet);
  THorse.Get('/pet/racas', TControllerBase(LController).DoGets);
end;

procedure UnRegistry;
begin
  LController := nil;
end;

initialization;
  Registry;

finalization
  UnRegistry;

end.
