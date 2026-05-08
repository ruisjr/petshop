unit Controller.User;

interface

uses
  {Classes de Sistema}
   Horse
  ,Horse.Commons
  ,System.SysUtils
  {Classes de Negócio}
  ,Controller.Base;

type
  TControllerUser = class(TControllerBase);

var
  LController: TControllerUser;

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
//  LController := TControllerUser.Create;

  {Métodos Get}
  THorse.Get('/user', LController.DoGet);
  THorse.Get('/users', LController.DoGet);

  {Métodos Post}
  THorse.Post('/user', LController.DoPost);
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
