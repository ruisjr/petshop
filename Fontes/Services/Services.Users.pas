unit Services.Users;

interface

uses
  {Classes de Sistema}
   System.JSON
  ,System.Classes
  {Classes de Negócio}
  ,Core.Services.Interfaces;

type
  TServiceUsuario = class(TInterfacedPersistent, IService)
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
  ,Entidade.Usuario
  ,Core.Environment
  ,Core.DataBase.Types
  ,Core.Rest.JsonHelper
  ,Core.DataBase.Access
  ,Core.DataBase.Interfaces;

{ TServiceUsuario }

function TServiceUsuario.GetService(const id: Integer): String;
var
  LUsuario: TUsuario;
  LDAO: IDataBaseDAO<TUsuario>;
begin
  LDAO := TDataBaseDAO<TUsuario>.Create;
  try
    try
      LUsuario := LDAO
                    .Fields('id, nome, login, data_cadastro, data_ultimo_acesso, email, bloqueado, ativo, primeiro_acesso')
                    .Where('id', OtEqual, id)
                  .Find;
      try
        Result := TJson.ObjectToJsonString(LUsuario);
      finally
        FreeAndNil(LUsuario);
      end;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar usuário da base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServiceUsuario.GetServices(): String;
var
  LDAO: IDataBaseDAO<TUsuario>;
  LUsuarioList: TObjectList<TUsuario>;
begin
  LDAO := TDataBaseDAO<TUsuario>.Create;
  try
    try
      LUsuarioList := LDAO.Fields('id, nome, login, data_cadastro, data_ultimo_acesso, email, bloqueado, ativo, primeiro_acesso').FindAll(50, 1);
      try
        Result := TJson.ObjectListToString<TUsuario>(LUsuarioList);
      finally
        LUsuarioList.Clear;
        FreeAndNil(LUsuarioList);
      end;
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


function TServiceUsuario.PostService(const ABody: TJSONObject): String;
begin
  inherited;
end;

end.
