unit Core.Rest.JsonHelper;

interface

uses
  {Classes de Sistema}
   Rest.Json
  ,System.JSON
  ,System.SysUtils
  ,System.Generics.Collections;

type
  TJsonObjectHelper = class Helper for TJSONObject
  public
    procedure ClearAndFreeItems;
  end;

  TJsonValueHelper = class Helper for TJSONValue
  public
    procedure ClearAndFreeItems;
  end;

  TJsonHelper = class Helper for TJson
  public
    class function ObjectListToString<T: class>(const objList: TObjectList<T>): String;
  end;

implementation

{ TJsonHelper }

class function TJsonHelper.ObjectListToString<T>(const objList: TObjectList<T>): String;
var
  LItem: T;
  LItemJson: string;
  LJSONObj: TJSONObject;
  LJsonArray: TJSONArray;
begin
  LJsonArray := TJSONArray.Create;
  try
    for LItem in objList do
    begin
      LItemJson := TJson.ObjectToJsonString(LItem);
      LJSONObj := TJSONObject(TJSONObject.ParseJSONValue(LItemJson));

      LJsonArray.AddElement(LJSONObj);
    end;

//    Result := LJsonArray.Format(2); // O parâmetro 2 é para identação (pretty print)
    Result := LJsonArray.ToJSON;
  finally
    LJsonArray.ClearAndFreeItems;
    FreeAndNil(LJsonArray);
  end;
end;

{ TJsonObjectHelper }

procedure TJsonObjectHelper.ClearAndFreeItems;
var
  vIx: Integer;
  vPar: TJSONPair;
begin
  if not Assigned(Self) then
    Exit;

  for vIx := Self.Count - 1 downto 0 do
  begin
    vPar := Self.Pairs[vIx];
    if (vPar.JsonValue is TJSONObject) then
      TJSONObject(vPar.JsonValue).ClearAndFreeItems;

    Self.RemovePair(vPar.JsonString.Value);
    vPar.Free;
  end;
end;

{ TJsonValueHelper }

procedure TJsonValueHelper.ClearAndFreeItems;
var
  vIx: Integer;
  vPar: TJSONPair;
  vObj: TJSONObject;
  procedure RemovePair(vObj: TJSONObject);
  var
    I: Integer;
  begin
    for I := vObj.Count - 1 downto 0 do
    begin
      vPar := vObj.Pairs[I];
      vObj.RemovePair(vPar.JsonString.value);
      vPar.Free;
    end;
  end;
begin
  if Self.ClassType = TJSONArray then
  begin
    for vIx := TJSONArray(Self).Count -1 downto 0 do
    begin
      vObj := TJSONArray(Self).Remove(vIx) as TJSONObject;
      RemovePair(vObj);
      if Assigned(vObj) then
        vObj.Free;
    end;
  end
  else
    RemovePair(TJSONObject(Self));
end;

end.
