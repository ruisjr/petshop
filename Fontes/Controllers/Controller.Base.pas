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
  end;

implementation

uses
  {Classe de Negócio}
  Core.Functions;

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

end.
