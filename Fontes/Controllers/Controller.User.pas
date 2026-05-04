unit Controller.User;

interface

uses
  System.SysUtils;

procedure Registry;

implementation

uses
  {Classes de Sistema}
   Horse
  ,Services.Users
  ,System.JSON;

procedure DoUser(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
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
      raise EHorseException.New.Error('Ocorreu erro ao processar a solicitação').Status(THTTPStatus.BadRequest);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure DoUsers(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
  LService: TServiceUsuario;
begin
  LService := TServiceUsuario.Create;
  try
    try
      Res.Send(LService.GetUsuarios());
    except
      raise EHorseException.New.Error('Ocorreu erro ao processar a solicitação').Status(THTTPStatus.BadRequest);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure Registry;
begin
  THorse.Get('/user', DoUser);
  THorse.Get('/users', DoUsers);
end;

initialization
  Registry;

end.
