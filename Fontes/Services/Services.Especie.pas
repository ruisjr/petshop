unit Services.Especie;

interface

uses
  {Classes de Sistema}
   System.JSON
  ,System.Classes
  {Classes de Negócio}
  ,Core.Services.Interfaces;

type
  TServiceEspecie = class(TInterfacedPersistent, IService)
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
  ,Entidade.Especie
  ,Core.Environment
  ,Core.DataBase.Types
  ,Core.Rest.JsonHelper
  ,Core.DataBase.Access
  ,Core.DataBase.Interfaces;

{ TServicePessoa }

function TServiceEspecie.GetServices: String;
var
  LEspecieList: TObjectList<TEspecie>;
  LDAO: IDataBaseDAO<TEspecie>;
begin
  LDAO := TDataBaseDAO<TEspecie>.Create;
  try
    try
      LEspecieList := LDAO.FindAll(50, 1);
      try
        Result := TJson.ObjectListToString<TEspecie>(LEspecieList);
      finally
        LEspecieList.Clear;
        FreeAndNil(LEspecieList);
      end;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar especie na base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceEspecie.GetService(const id: Integer): String;
var
  LEspecie: TEspecie;
  LDAO: IDataBaseDAO<TEspecie>;
begin
  LDAO := TDataBaseDAO<TEspecie>.Create;
  try
    try
      LEspecie := LDAO.Where('id', OtEqual, id).Find;
      try
        Result := TJson.ObjectToJsonString(LEspecie);
      finally
        FreeAndNil(LEspecie);
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

function TServiceEspecie.PostService(const ABody: TJSONObject): String;
begin
  inherited;
end;

end.
