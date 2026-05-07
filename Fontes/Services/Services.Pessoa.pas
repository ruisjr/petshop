unit Services.Pessoa;

interface

uses
  {Classes de Sistema}
  System.JSON;

type
  TServicePessoa = class
  strict private
  public
    function GetPessoa(const id: Integer): String;
    function GetPessoas(): String;
    function PostPessoa(const pBody: String): String;
  end;


implementation

uses
  {Classes de Sistema}
   Rest.Json
  ,System.SysUtils
  ,System.Generics.Collections
  {Classes de Negócio}
  ,Entidade.Pessoa
  ,Core.Environment
  ,Core.DataBase.Types
  ,Core.Rest.JsonHelper
  ,Core.DataBase.Access
  ,Core.DataBase.Interfaces;

{ TServicePessoa }

function TServicePessoa.GetPessoa(const id: Integer): String;
var
  LPessoa: TPessoa;
  LDAO: IDataBaseDAO<TPessoa>;
begin
  LDAO := TDataBaseDAO<TPessoa>.Create;
  try
    try
      LPessoa := LDAO.Where('id', OtEqual, id).First;
      try
        Result := TJson.ObjectToJsonObject(LPessoa).ToJSON;
      finally
        FreeAndNil(LPessoa);
      end;
    except
      on E: Exception do
      begin
        Env.Log.Error(E.Message);
        raise Exception.Create('Error: Não foi possível recuperar a pessoa da base de dados.');
      end;
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

function TServicePessoa.GetPessoas: String;
var
  LPessoaList: TObjectList<TPessoa>;
  LDAO: IDataBaseDAO<TPessoa>;
begin
  LDAO := TDataBaseDAO<TPessoa>.Create;
  try
    try
      LPessoaList := LDAO.ToList(50, 1);
      try
        Result := TJson.ObjectListToString<TPessoa>(LPessoaList);
      finally
        LPessoaList.Clear;
        FreeAndNil(LPessoaList);
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

function TServicePessoa.PostPessoa(const pBody: String): String;
var
  LDAO: IDataBaseDAO<TPessoa>;
  LPessoa: TPessoa;
begin
  LDAO := TDataBaseDAO<TPessoa>.Create;
  try
    LPessoa := TJson.JsonToObject<TPessoa>(TJSONObject(TJSONObject.ParseJSONValue(pBody)));
    try
      Env.Connection.BeginTransaction;
      try
        {Verifica se já existe o id enviado}
        if (LPessoa.ID > 0) then
          LDAO.Where('id', OtEqual, LPessoa.ID).Update(LPessoa)
        else
          LDAO.Insert(LPessoa);

        {Commita as modificações}
        Env.Connection.CommitTransaction;

        Result := TJson.ObjectToJsonString(LPessoa);
      except
        on E: Exception do
        begin
          Env.Connection.RollBackTransaction;
          Env.Log.Error(E.Message);
          raise E;
        end;
      end;
    finally
      FreeAndNil(LPessoa);
    end;
  finally
    LDAO.FreeMemory;
  end;
end;

end.
