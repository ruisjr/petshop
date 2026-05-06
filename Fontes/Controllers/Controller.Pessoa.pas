unit Controller.Pessoa;

interface

uses
  {Classes de Sistema}
   Horse
  ,Horse.Commons
  ,System.SysUtils
  {Classes de Negócio}
  ,Controller.Base;

type
  TControllerPessoa = class(TControllerBase)
  public
    procedure DoGetPessoa(Req: THorseRequest; Res: THorseResponse);
    procedure DoGetPessoas(Req: THorseRequest; Res: THorseResponse);
    procedure DoPostPessoa(Req: THorseRequest; Res: THorseResponse);
  end;

var
  LController: TControllerPessoa;

procedure Registry;
procedure UnRegistry;

implementation

uses
  {Classes de Sistema}
   System.JSON
  {Classes de Negócio}
  ,Core.Functions
  ,Services.Pessoa
  ,Core.Environment;

{ TControllerPessoa }

procedure TControllerPessoa.DoGetPessoa(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
  LService: TServicePessoa;
  LResponse: String;
begin
  LService := TServicePessoa.Create;
  try
    try
      LBody := TJsonObject(TJsonObject.ParseJSONValue(Req.Body));
      try
        Self.ValidadeInfoRequest(LBody);

        LResponse := LService.GetPessoa(LBody.GetValue<Integer>('id'));
        Env.Log.Debug('DoGetPessoa | Response: ' + LResponse);
        Res.Send(LResponse);
      finally
        LBody.ClearAndFreeItems;
      end;
    except
      on E: Exception do
        Res.Send(Self.GetJsonDefaultError('Ocorreu erro ao processar a solicitação', E.Message, THTTPStatus.BadRequest)).Status(Integer(THTTPStatus.BadRequest));
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerPessoa.DoGetPessoas(Req: THorseRequest; Res: THorseResponse);
begin

end;

procedure TControllerPessoa.DoPostPessoa(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServicePessoa;
  LResponse: String;
begin
  LService := TServicePessoa.Create;
  try
    try
      LResponse := Self.GetJsonDefaultSuccess(LService.PostPessoa(Req.Body), THTTPStatus.OK);
      Env.Log.Debug('DoPostPessoa | Response: ' + LResponse);
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
  THorse.Get('/pessoa', LController.DoGetPessoa);
  THorse.Get('/pessoas', LController.DoGetPessoas);

  {Métodos Post}
  THorse.Post('/pessoa', LController.DoPostPessoa);
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
