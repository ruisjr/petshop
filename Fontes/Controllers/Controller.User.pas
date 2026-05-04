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
    procedure DoUser(Req: THorseRequest; Res: THorseResponse);
    procedure DoUsers(Req: THorseRequest; Res: THorseResponse);
  end;

procedure Registry;

implementation

uses
  {Classes de Sistema}
   System.JSON
  ,Services.Users;

procedure TControllerUser.DoUser(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
  LMsg: string;
  LService: TServiceUsuario;
begin
  LBody := TJsonObject(TJsonObject.ParseJSONValue(Req.Body));
  if not Assigned(LBody) then
    raise EHorseException.New.Error('Corpo da mensagem não foi informado.').Status(THTTPStatus.BadRequest)
  else if (LBody.GetValue<Integer>('id') = 0) then
    raise EHorseException.New.Error('ID não informado.').Status(THTTPStatus.BadRequest);

  LService := TServiceUsuario.Create;
  try
    try
      Res.Send(LService.GetUsuario(LBody.GetValue<Integer>('id')));
    except
      on E: Exception do
        Res.Send(Self.GetJsonDefaultError('Ocorreu erro ao processar a solicitação', E.Message, THTTPStatus.BadRequest)).Status(Integer(THTTPStatus.BadRequest));
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerUser.DoUsers(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServiceUsuario;
begin
  LService := TServiceUsuario.Create;
  try
    try
      Res.Send(LService.GetUsuarios());
    except
      on E: Exception do
        Res.Send(Self.GetJsonDefaultError('Ocorreu erro ao processar a solicitação', E.Message, THTTPStatus.BadRequest)).Status(Integer(THTTPStatus.BadRequest));
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure Registry;
var
  LController: TControllerUser;
begin
  LController := TControllerUser.Create;
  try
    THorse.Get('/user', LController.DoUser);
    THorse.Get('/users', LController.DoUsers);
  finally
    FreeAndNil(LController);
  end;
end;

initialization
  Registry;

end.
