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
  TControllerUser = class(TControllerBase)
  public
    procedure DoGetUser(Req: THorseRequest; Res: THorseResponse);
    procedure DoGetUsers(Req: THorseRequest; Res: THorseResponse);
    procedure DoPostUser(Req: THorseRequest; Res: THorseResponse);
  end;

var
  LController: TControllerUser;

procedure Registry;
procedure UnRegistry;

implementation

uses
  {Classes de Sistema}
   System.JSON
  {Classes de Negócio}
  ,Core.Functions
  ,Services.Users;

procedure TControllerUser.DoGetUser(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
  LService: TServiceUsuario;
begin
  LService := TServiceUsuario.Create;
  try
    try
      LBody := TJsonObject(TJsonObject.ParseJSONValue(Req.Body));
      try
        Self.ValidadeInfoRequest(LBody);
        Self.DoGet(LService.GetUsuario(LBody.GetValue<Integer>('id')), Res);
      finally
        LBody.ClearAndFreeItems;
      end;
    except
      on E: Exception do
        Self.DoGetError('Ocorreu erro ao processar a solicitação', E.Message, Res);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerUser.DoGetUsers(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServiceUsuario;
begin
  LService := TServiceUsuario.Create;
  try
    try
      Self.DoGet(LService.GetUsuarios(), Res);
    except
      on E: Exception do
        Self.DoGetError('Ocorreu erro ao processar a solicitação', E.Message, Res);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerUser.DoPostUser(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServiceUsuario;
begin
  LService := TServiceUsuario.Create;
  try
    try
      Self.DoPost(LService.PostUsuario(Req.Body), Res);
    except
      on E: Exception do
        Self.DoPostError('Ocorreu erro ao processar a solicitação', E.Message, Res);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure Registry;
begin
  LController := TControllerUser.Create;

  {Métodos Get}
  THorse.Get('/user', LController.DoGetUser);
  THorse.Get('/users', LController.DoGetUsers);

  {Métodos Post}
  THorse.Post('/user', LController.DoPostUser);
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
