unit Services.Raca;

interface

uses
  {Classes de Sistema}
   System.JSON
  ,System.Classes
  {Classes de Negócio}
  ,Core.Services.Interfaces;

type
  TServiceRaca = class(TInterfacedPersistent, IService)
  strict private
  public
    function GetService(const id: Integer): String;
    function GetServices(): String;

    function PostService(const ABody: TJSONObject): String;
  end;

implementation

uses
  {Classes de Sistema}
   Rest.Json
  ,System.SysUtils
  ,System.Generics.Collections
  {Classes de Negócio}
  ,Entidade.Raca
  ,Core.Environment
  ,Core.DataBase.Types
  ,Core.Rest.JsonHelper
  ,Core.DataBase.Access
  ,Core.DataBase.Interfaces;

{ TServiceRaca }

function TServiceRaca.GetService(const id: Integer): String;
var
  LRaca: TRaca;
  LDAO: IDataBaseDAO<TRaca>;
begin
  LDAO := TDataBaseDAO<TRaca>.Create;
  try
    try
      LRaca := LDAO.Where('id', OtEqual, id).Find;
      try
        Result := TJson.ObjectToJsonString(LRaca);
      finally
        FreeAndNil(LRaca);
      end;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar a especie na base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceRaca.GetServices: String;
var
  LRacaList: TObjectList<TRaca>;
  LDAO: IDataBaseDAO<TRaca>;
begin
  LDAO := TDataBaseDAO<TRaca>.Create;
  try
    try
      LRacaList := LDAO.FindAll(50, 1);
      try
        Result := TJson.ObjectListToString<TRaca>(LRacaList);
      finally
        LRacaList.Clear;
        FreeAndNil(LRacaList);
      end;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar a especie na base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceRaca.PostService(const ABody: TJSONObject): String;
begin

end;

end.
