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
  ,Services.Pessoa;

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
        Self.DoGet(LService.GetPessoa(LBody.GetValue<Integer>('id')), Res);
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

procedure TControllerPessoa.DoGetPessoas(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServicePessoa;
  LResponse: String;
  LMetodo: String;
begin
  LService := TServicePessoa.Create;
  try
    try
      Self.DoGet(LService.GetPessoas(), Res);
    except
      on E: Exception do
        Self.DoGetError('Ocorreu erro ao processar a solicitação', E.Message, Res);
    end;
  finally
    FreeAndNil(LService);
  end;
end;

procedure TControllerPessoa.DoPostPessoa(Req: THorseRequest; Res: THorseResponse);
var
  LService: TServicePessoa;
  LResponse: String;
begin
  LService := TServicePessoa.Create;
  try
    try
      Self.DoPost(LService.PostPessoa(Req.Body), Res);
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
  LController := TControllerPessoa.Create;

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
