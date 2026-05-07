unit Controller.Base;

interface

uses
  {Classes de Sistema}
   Horse
  ,System.JSON
  ,Horse.Commons
  ,System.Classes
  ,System.SysUtils;

type
  TControllerBase = class(TPersistent)
  strict private
    {Functions}
    function GetJsonDefaultError(const pMsg, pDetailedMsg: string; pStatusCode: THTTPStatus): String;
    function GetJsonDefaultSuccess(const pJson: String; pStatusCode: THTTPStatus): String;
  public
    {Construtores e Destrutores}
    constructor Create; reintroduce;

    {procedures}
    procedure ValidadeInfoRequest(const pBody: TJSONObject);
  published
    {Procedures}
    procedure DoPost(pResponse: String; Res: THorseResponse); virtual;
    procedure DoGet(pResponse: String; Res: THorseResponse); virtual;
    {Errors}
    procedure DoPostError(pMsg, pDetailedMessage: String; Res: THorseResponse); virtual;
    procedure DoGetError(pMsg, pDetailedMessage: String; Res: THorseResponse); virtual;
  end;

implementation

uses
  {Classe de Negócio}
   Core.Functions
  ,Core.Environment;

{ TServiceBase }

constructor TControllerBase.Create;
begin
  inherited Create;
end;

procedure TControllerBase.DoGet(pResponse: String; Res: THorseResponse);
var
  LResponse: String;
begin
  LResponse := Self.GetJsonDefaultSuccess(pResponse, THTTPStatus.OK);
  Env.Log.Debug(Self.MethodName(@TControllerBase.DoGet) + ' | Response: ' +LResponse);
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

procedure TControllerBase.DoPost(pResponse: String; Res: THorseResponse);
var
  LResponse: String;
begin
  LResponse := Self.GetJsonDefaultSuccess(pResponse, THTTPStatus.OK);
  Env.Log.Debug(Self.MethodName(@TControllerBase.DoPost) + ' | Response: ' +LResponse);
  Res.Send(LResponse);
end;

procedure TControllerBase.DoPostError(pMsg, pDetailedMessage: String; Res: THorseResponse);
var
  LResponse: String;
begin
  LResponse := Self.GetJsonDefaultError(pMsg, pDetailedMessage, THTTPStatus.BadRequest);
  Env.Log.Debug(Self.MethodName(@TControllerBase.DoPostError) + ' | Response: ' +LResponse);
  Res.Send(LResponse).Status(Integer(THTTPStatus.BadRequest));
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
