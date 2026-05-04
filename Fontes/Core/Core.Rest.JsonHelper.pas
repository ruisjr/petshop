unit Core.Rest.JsonHelper;

interface

uses
  {Classes de Sistema}
   Rest.Json
  ,System.JSON
  ,System.SysUtils
  ,System.Generics.Collections;

type
  TJsonHelper = class Helper for TJson
  public
    class function ObjectListToString<T: class>(const objList: TObjectList<T>): String;
  end;

implementation

{ TJsonHelper }

class function TJsonHelper.ObjectListToString<T>(const objList: TObjectList<T>): String;
var
  LItem: T;
  LJsonArray: TJSONArray;
  LItemJson: string;
begin
  // Criamos um container de array para agrupar os itens
  LJsonArray := TJSONArray.Create;
  try
    for LItem in objList do
    begin
      // Chamada obrigatória ao método solicitado:
      LItemJson := TJson.ObjectToJsonString(LItem);

      // Convertemos a string individual de volta para um objeto
      // para que ele possa ser inserido corretamente no Array final
      LJsonArray.AddElement(TJSONObject.ParseJSONValue(LItemJson));
    end;

    // Retorna a lista completa formatada
    Result := LJsonArray.Format(2); // O parâmetro 2 é para identação (pretty print)
  finally
    LJsonArray.Free;
  end;
end;

end.
