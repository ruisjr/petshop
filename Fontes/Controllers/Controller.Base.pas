unit Controller.Base;

interface

uses
  {Classes de Sistema}
   System.JSON
  ,Horse.Commons
  ,System.Classes
  ,System.SysUtils;

type
  TControllerBase = class(TPersistent)
  strict private
  public
    {Construtores e Destrutores}
    constructor Create; reintroduce;

    {Functions}
    function GetJsonDefaultError(const pMsg, pDetailedMsg: string; pStatusCode: THTTPStatus): String;
    function GetJsonDefaultSuccess(const pJson: String; pStatusCode: THTTPStatus): String;

    {procedures}
    procedure ValidadeInfoRequest(const pBody: TJSONObject);
  end;

implementation

uses
   Horse
  {Classe de Negócio}
  ,Core.Functions;

{ TServiceBase }

constructor TControllerBase.Create;
begin
  inherited Create;
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
