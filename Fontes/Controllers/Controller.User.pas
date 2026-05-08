unit Controller.User;

interface

uses
  {Classes de Sistema}
   Horse
  {Classes de Negócio}
  ,Controller.Base;

var
  LController: TControllerBase;

procedure Registry;
procedure UnRegistry;

implementation

uses
  {Classes de Sistema}
   System.JSON
  {Classes de Negócio}
  ,Services.Users;


procedure Registry;
begin
  LController := TControllerBase.Create(TServiceUsuario.Create);

  {Métodos Get}
  THorse.Get('/user', TControllerBase(LController).DoGet);
  THorse.Get('/users', TControllerBase(LController).DoGets);

  {Métodos Post}
  THorse.Post('/user', TControllerBase(LController).DoPost);
end;

procedure UnRegistry;
begin
  LController := nil;
end;

initialization
  Registry;

finalization
  UnRegistry;

end.
