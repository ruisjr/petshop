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
  ,Services.Users
  ,Core.Environment;

procedure TControllerUser.DoGetUser(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
  LService: TServiceUsuario;
  LResponse: String;
begin
  LBody := TJsonObject(TJsonObject.ParseJSONValue(Req.Body));
  if not Assigned(LBody) then
    raise EHorseException.New.Error('Corpo da mensagem não foi informado.').Status(THTTPStatus.BadRequest)
  else if (LBody.GetValue<Integer>('id') = 0) then
    raise EHorseException.New.Error('ID não informado.').Status(THTTPStatus.BadRequest);

  LService := TServiceUsuario.Create;
  try
    try
      LResponse := LService.GetUsuario(LBody.GetValue<Integer>('id'));
      Env.Log.Debug('DoGetUser | Response: ' + LResponse);
      Res.Send(LResponse);
    except
      on E: Exception do
        Res.Send(Self.GetJsonDefaultError('Ocorreu erro ao processar a solicitação', E.Message, THTTPStatus.BadRequest)).Status(Integer(THTTPStatus.BadRequest));
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerUser.DoGetUsers(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServiceUsuario;
  LResponse: String;
begin
  LService := TServiceUsuario.Create;
  try
    try
      LResponse := Self.GetJsonDefaultSuccess(LService.GetUsuarios(), THTTPStatus.OK);
      Env.Log.Debug('DoGetUsers | Response: ' + LResponse);
      Res.Send(LResponse);
    except
      on E: Exception do
        Res.Send(Self.GetJsonDefaultError('Ocorreu erro ao processar a solicitação', E.Message, THTTPStatus.BadRequest)).Status(Integer(THTTPStatus.BadRequest));
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerUser.DoPostUser(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServiceUsuario;
  LResponse: String;
begin
  LService := TServiceUsuario.Create;
  try
    try
      LResponse := Self.GetJsonDefaultSuccess(LService.PostUsuario(Req.Body), THTTPStatus.OK);
      Env.Log.Debug('DoPostUser | Response: ' + LResponse);
      Res.Send(LResponse);
    except
      on E: Exception do
        Res.Send(Self.GetJsonDefaultError('Ocorreu erro ao processar a solicitação', E.Message, THTTPStatus.BadRequest)).Status(Integer(THTTPStatus.BadRequest));
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure Registry;
begin
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
