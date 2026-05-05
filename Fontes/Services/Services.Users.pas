unit Services.Users;

interface

uses
  {Classes de Sistema}
  System.JSON;

type
  TServiceUsuario = class
  strict private
  public
    function GetUsuario(const id: Integer): String;
    function GetUsuarios(): String;
    function PostUsuario(const pBody: String): String;
  end;

implementation

uses
  {Classes de Sistema}
   Rest.Json
  ,System.SysUtils
  ,System.Generics.Collections
  {Classes de Negócio}
  ,Entidade.Usuario
  ,Core.Rest.JsonHelper
  ,Core.DataBase.Types
  ,Core.DataBase.Interfaces
  ,Core.DataBase.Access
  ,Core.Environment;



{ TServiceUsuario }

function TServiceUsuario.GetUsuario(const id: Integer): String;
var
  LUsuario: TUsuario;
  LDAO: IDataBaseDAO<TUsuario>;
begin
  LDAO := TDataBaseDAO<TUsuario>.Create;
  try
    try
      LUsuario := LDAO.Where('id', OtEqual, id).First;
      Result := TJson.ObjectToJsonObject(LUsuario).ToJSON;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar o usuário da base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceUsuario.GetUsuarios(): String;
var
  LUsuarioList: TObjectList<TUsuario>;
  LDAO: IDataBaseDAO<TUsuario>;
begin
  LDAO := TDataBaseDAO<TUsuario>.Create;
  try
    try
      LUsuarioList := LDAO.Fields('id, nome, login, data_cadastro, data_ultimo_acesso, email, bloqueado, ativo, primeiro_acesso').ToList(50, 1);
      Result := TJson.ObjectListToString<TUsuario>(LUsuarioList);
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar usuários da base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceUsuario.PostUsuario(const pBody: String): String;
var
  LDAO: IDataBaseDAO<TUsuario>;
  LUsuario: TUsuario;
begin
  LDAO := TDataBaseDAO<TUsuario>.Create;
  try
    LUsuario := TJson.JsonToObject<TUsuario>(TJSONObject(TJSONObject.ParseJSONValue(pBody)));

    LDAO.Insert(LUsuario);
  finally
    LDAO.FreeMemory;
  end;
end;

end.
