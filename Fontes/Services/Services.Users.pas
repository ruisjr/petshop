unit Services.Users;

interface

type
  TServiceUsuario = class
  strict private
  public
    function GetUsuario(const id: Integer): String;
    function GetUsuarios(): String;
  end;

implementation

uses
  {Classes de Sistema}
   System.JSON
  ,Rest.Json
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
      LUsuarioList := LDAO.ToList(50, 1);
      Result := TJson.ObjectListToString<TUsuario>(LUsuarioList);
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar usu[arios da base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

end.
