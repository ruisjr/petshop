unit Services.Municipio;

interface

uses
  {Classes de Sistema}
   System.JSON
  ,System.Classes
  {Classes de Negócio}
  ,Core.Services.Interfaces;

type
  TServiceMunicipio = class(TInterfacedPersistent, IService)
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
  ,Entidade.Municipio
  ,Core.Environment
  ,Core.DataBase.Types
  ,Core.Rest.JsonHelper
  ,Core.DataBase.Access
  ,Core.DataBase.Interfaces;

{ TServicePessoa }

function TServiceMunicipio.GetServices: String;
var
  LEspecieList: TObjectList<TMunicipio>;
  LDAO: IDataBaseDAO<TMunicipio>;
begin
  inherited;
  LDAO := TDataBaseDAO<TMunicipio>.Create;
  try
    try
      LEspecieList := LDAO.ToList(50, 1);
      try
        Result := TJson.ObjectListToString<TMunicipio>(LEspecieList);
      finally
        LEspecieList.Clear;
        FreeAndNil(LEspecieList);
      end;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar municípios na base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceMunicipio.GetService(const id: Integer): String;
var
  LDAO: IDataBaseDAO<TMunicipio>;
  LEspecie: TMunicipio;
begin
  inherited;
  LDAO := TDataBaseDAO<TMunicipio>.Create;
  try
    try
      LEspecie := LDAO.Where('id', OtEqual, id).First;
      try
        Result := TJson.ObjectToJsonString(LEspecie);
      finally
        FreeAndNil(LEspecie);
      end;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar a município na base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceMunicipio.PostService(const ABody: TJSONObject): String;
begin
  inherited;
end;

end.
