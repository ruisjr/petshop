unit Services.Especie;

interface

uses
  {Classes de Sistema}
  System.JSON;

type
  TServiceEspecie = class
  strict private
  public
    function GetEspecie(const id: Integer): String;
    function GetEspecies(): String;
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

function TServiceEspecie.GetEspecie(const id: Integer): String;
var
  LEspecie: TEspecie;
  LDAO: IDataBaseDAO<TEspecie>;
begin
  LDAO := TDataBaseDAO<TEspecie>.Create;
  try
    try
      LEspecie := LDAO.Where('id', OtEqual, id).First;
      try
        Result := TJson.ObjectToJsonObject(LEspecie).ToJSON;
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

function TServiceEspecie.GetEspecies: String;
var
  LEspecieList: TObjectList<TEspecie>;
  LDAO: IDataBaseDAO<TEspecie>;
begin
  LDAO := TDataBaseDAO<TEspecie>.Create;
  try
    try
      LEspecieList := LDAO.ToList(50, 1);
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

end.
