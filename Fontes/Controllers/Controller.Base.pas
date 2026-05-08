unit Controller.Base;

interface

uses
  {Classes de Sistema}
   Horse
  ,System.JSON
  ,Horse.Commons
  ,System.Classes
  ,System.SysUtils
  {Classes de Negócio}
  ,Core.Services.Interfaces;

type
  TControllerBase = class(TInterfacedPersistent, IController)
  strict private
    FService: IService;
    {Functions}
    function GetJsonDefaultError(const pMsg, pDetailedMsg: string; pStatusCode: THTTPStatus): String;
    function GetJsonDefaultSuccess(const pJson: String; pStatusCode: THTTPStatus): String;

    {procedures}
    procedure ValidadeInfoRequest(const pBody: TJSONObject);

    {Errors}
    procedure DoPostError(pMsg, pDetailedMessage: String; Res: THorseResponse);
    procedure DoGetError(pMsg, pDetailedMessage: String; Res: THorseResponse);
    procedure DoSend(pResponse: String; Res: THorseResponse); virtual;
  public
    {Construtores e Destrutores}
    constructor Create(AService: IService); reintroduce;

  published
    procedure DoPost(Req: THorseRequest; Res: THorseResponse);
    procedure DoGet(Req: THorseRequest; Res: THorseResponse);
  end;

implementation

uses
  {Classe de Negócio}
   Core.Functions
  ,Core.Environment;

{ TServiceBase }

constructor TControllerBase.Create(AService: IService);
begin
  FService := AService;
  inherited Create;
end;

procedure TControllerBase.DoSend(pResponse: String; Res: THorseResponse);
var
  LResponse: String;
begin
  LResponse := Self.GetJsonDefaultSuccess(pResponse, THTTPStatus.OK);
  Env.Log.Debug(Self.MethodName(@TControllerBase.DoSend) + ' | Response: ' +LResponse);
  Res.Send(LResponse);
end;

procedure TControllerBase.DoGetError(pMsg, pDetailedMessage: String; Res: THorseResponse);
var
  LResponse: String;
begin
  LResponse := Self.GetJsonDefaultError(pMsg, pDetailedMessage, THTTPStatus.BadRequest);
  Env.Log.Debug(Self.MethodName(@TControllerBase.DoGetError) + ' | Response: ' +LResponse);
  Res.Send(Self.GetJsonDefaultError(pMsg, pDetailedMessage, THTTPStatus.BadRequest)).Status(Integer(THTTPStatus.BadRequest));
end;

procedure TControllerBase.DoGet(Req: THorseRequest; Res: THorseResponse);
var
  LBody: TJsonObject;
begin
  try
    LBody := TJsonObject(TJsonObject.ParseJSONValue(Req.Body));
    try
      Self.ValidadeInfoRequest(LBody);
      Self.DoSend(FService.GetService(LBody.GetValue<Integer>('id')), Res);
    finally
      LBody.ClearAndFreeItems;
    end;
  except
    on E: Exception do
      Self.DoGetError('Ocorreu erro ao processar a solicitação', E.Message, Res);
  end;
end;

procedure TControllerBase.DoPostError(pMsg, pDetailedMessage: String; Res: THorseResponse);
var
  LResponse: String;
begin
  LResponse := Self.GetJsonDefaultError(pMsg, pDetailedMessage, THTTPStatus.BadRequest);
  Env.Log.Debug(Self.MethodName(@TControllerBase.DoPostError) + ' | Response: ' +LResponse);
  Res.Send(LResponse).Status(Integer(THTTPStatus.BadRequest));
end;

procedure TControllerBase.DoPost(Req: THorseRequest; Res: THorseResponse);
var
  LJsonObj: TJSONObject;
begin
  LJsonObj := TJSONObject(TJSONObject.ParseJSONValue(Req.Body));
  try
    try
      Self.DoSend(FService.PostService(LJsonObj), Res);
    except
      on E: Exception do
        Self.DoPostError('Ocorreu erro ao processar a solicitação', E.Message, Res);
    end;
  finally
    LJsonObj.ClearAndFreeItems;
  end;
end;

function TControllerBase.GetJsonDefaultError(const pMsg, pDetailedMsg: string; pStatusCode: THTTPStatus): String;
var
  LJsonObj,
  LJSonObjPair: TJSONObject;
begin
  LJsonObj := TJSONObject.Create;
  LJSonObjPair := TJSONObject.Create;
  try
    LJSonObjPair.AddPair('code', TJSONNumber.Create(Integer(pStatusCode)));
    LJSonObjPair.AddPair('message', TJSONString.Create(pMsg));
    LJSonObjPair.AddPair('detailedMessage', TJSONString.Create(pDetailedMsg));

    LJsonObj.AddPair('details', LJSonObjPair);
    Result := LJsonObj.ToJSON;
  finally
    LJsonObj.ClearAndFreeItems;
  end;
end;

function TControllerBase.GetJsonDefaultSuccess(const pJson: String; pStatusCode: THTTPStatus): String;
var
  LJsonObj: TJSONObject;
begin
  LJsonObj := TJSONObject.Create;
  try
    LJsonObj.AddPair('code', TJSONNumber.Create(Integer(pStatusCode)));
    LJsonObj.AddPair('message', TJSONString.Create('Sucess'));

    LJsonObj.AddPair('details', TJSONObject(TJSONObject.ParseJSONValue(pJson)));
    Result := LJsonObj.ToJSON;
  finally
    LJsonObj.ClearAndFreeItems;
  end;
end;

procedure TControllerBase.ValidadeInfoRequest(const pBody: TJSONObject);
begin
  if not Assigned(pBody) then
    raise EHorseException.New.Error('Corpo da mensagem não foi informado.').Status(THTTPStatus.BadRequest)
  else if (pBody.GetValue<Integer>('id') = 0) then
    raise EHorseException.New.Error('ID não informado.').Status(THTTPStatus.BadRequest);
end;

end.
