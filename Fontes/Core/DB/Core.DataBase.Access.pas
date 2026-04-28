unit Core.DataBase.Access;

interface

uses
  {Classes de Sistema}
   Data.DB
  ,Vcl.Forms
  ,System.SysUtils
  ,System.TypInfo
  ,System.Rtti
  ,System.Generics.Collections
  {Classes de negócio}
  ,PrgLog
  ,Core.DataBase.Types
  ,Core.Exceptions
  ,Core.DataBase.Connection
  ,Core.DataBase.RttiHelper
  ,Core.DataBase.Interfaces
  ,Core.DataBase.QueryBuilder
  ,Core.Entidades.CustomAttributes;

type
  TDataBaseDAO<T: class, constructor> = class(TInterfacedObject, IDataBaseDAO<T>)
  protected
    FEntity: T;
    FSQL: String;
    FOrder: String;
    FGroup: String;
    FRowNum: String;
    FWhere: String;
    FFields: String;
    FList: TObjectList<T>;
    FParameters: TDictionary<String, TValue>;
    FDataSource: TDataSource;
  private
    FQuery: IDataBaseQuery<T>;

    {Procedures}
    procedure Clear;
  public
    {Construtores e Destrutores}
    constructor Create(const pDBConn: TDataBaseConnection = nil); overload;
    constructor Create(const pEntity: T); overload;
    destructor Destroy; override;

    {Procedures}
    procedure FreeMemory;

    procedure ToDataSet;

    procedure Insert(pEntity: T); overload;
    procedure Update(pEntity: T); overload;
    procedure Delete(pEntity: T); overload;
    procedure Delete; overload;

    {Functions}
    function DataSet: TDataSet;
    function DataSource(pDataSource: TDataSource): IDataBaseDAO<T>;

    function SQL(const pSQL: String): IDataBaseDAO<T>;
    function GroupBy(const pField: String): IDataBaseDAO<T>;
    function OrderBy(const pField: String): IDataBaseDAO<T>;
    function RowNum(const pRowNum: Integer) : IDataBaseDAO<T>;
    function Fields(const pFields: String) : IDataBaseDAO<T>;
    function Where(const pField: String; const pOperatorType: TOperatorType; const pValue: TValue): IDataBaseDAO<T>;
    function WhereAnd(const pField: String; const pOperatorType: TOperatorType; const pValue: TValue): IDataBaseDAO<T>;

    function ToList: TObjectList<T>;
    function First: T;
  end;

implementation

uses
   Core.DataBase.Rtti
  ,Core.DataBase.SQLMaker;


{ TDataBaseAccess }

constructor TDataBaseDAO<T>.Create(const pDBConn: TDataBaseConnection = nil);
begin
  inherited Create;
  FList := TObjectList<T>.Create;
  FQuery := TQueryBuilder<T>.Create(pDBConn);
  FParameters := TDictionary<String, TValue>.Create;

  if FEntity = nil then
    FEntity := T.Create;
end;

procedure TDataBaseDAO<T>.Clear;
begin
  FOrder := '';
  FGroup := '';
  FRowNum := '';
  FWhere := '';
  FFields := '';
  FParameters.Clear;
end;

constructor TDataBaseDAO<T>.Create(const pEntity: T);
begin
  Self.Create;
  FEntity := pEntity;
end;

function TDataBaseDAO<T>.DataSet: TDataSet;
begin
  Result := TDataSet(FQuery);
end;

function TDataBaseDAO<T>.DataSource(pDataSource: TDataSource): IDataBaseDAO<T>;
begin
  try
    Result := Self;
    FDataSource := pDataSource;
    FDataSource.DataSet := TDataSet(FQuery.DataSet);
  except
    on E: Exception do
    begin
      vgLog.DebugOut('Ocorreu um erro ao obter os dados provenientes do banco de dados.'+ #13#10 + 'Detalhes: ' + E.Message, []);
    end;
  end;
end;

procedure TDataBaseDAO<T>.Delete(pEntity: T);
var
  vSQL: String;
begin
  try
    TSQLMaker<T>.New(pEntity).Delete(vSQL);

    FQuery.SQL.Clear;
    FQuery.SQL.Add(vSQL);
    FQuery.FillParameter(pEntity);
    FQuery.ExecSQL;
  except
    on E: Exception do
      vgLog.DebugOut('Ocorreu erro ao deletar o registro!' + #13#10 + 'Detalhes: ' + E.Message, [])
  end;
end;

procedure TDataBaseDAO<T>.Delete;
var
  vSQL: String;
begin
  try
    TSQLMaker<T>.New(FEntity).Where(FParameters).Delete(vSQL);

    FQuery.SQL.Clear;
    FQuery.SQL.Add(vSQL);
    FQuery.FillParameter(FParameters);
    FQuery.ExecSQL;
  except
    on E: Exception do
      vgLog.DebugOut('Ocorreu erro ao deletar o registro!' + #13#10 + 'Detalhes: ' + E.Message, [])
  end;
end;

destructor TDataBaseDAO<T>.Destroy;
begin
  FreeAndNil(FParameters);
  inherited;
end;

function TDataBaseDAO<T>.RowNum(const pRowNum: Integer): IDataBaseDAO<T>;
begin
  Result := Self;
  FRowNum := pRowNum.ToString();
end;

function TDataBaseDAO<T>.SQL(const pSQL: String): IDataBaseDAO<T>;
begin
  Result := Self;
  FSQL := pSQL;
end;

function TDataBaseDAO<T>.OrderBy(const pField: String): IDataBaseDAO<T>;
begin
  Result := Self;
  FOrder := pField;
end;

procedure TDataBaseDAO<T>.ToDataSet;
var
  vSQL: String;
begin
  TSQLMaker<T>.New(FEntity).Select(vSQL);

  FQuery.DataSet.DisableControls;
  try
    FQuery.SQL.Clear;
    FQuery.Open(vSQL);
  finally
    Self.Clear;
    FQuery.DataSet.EnableControls;
  end;
end;

function TDataBaseDAO<T>.Fields(const pFields: String): IDataBaseDAO<T>;
begin
  FFields := pFields;
end;

function TDataBaseDAO<T>.First: T;
var
  vSQL: String;
begin
  if FSQL.IsEmpty then
  begin
    TSQLMaker<T>.New(FEntity)
      .Fields(FFields)
      .Where(FParameters)
      .RowNum('1')
      .GroupBy(FGroup)
      .OrderBy(FOrder)
    .Select(vSQL);
  end
  else
    vSQL := FSQL;

  FQuery.DataSet.DisableControls;
  try
    FQuery.SQL.Clear;
    FQuery.SQL.Add(vSQL);
    FQuery.FillParameter(FParameters);
    FQuery.Open;

    TDataBaseRtti<T>.New(FEntity).DataSetToEntity(FQuery.DataSet, Result);
  finally
    Self.Clear;

    FQuery.DataSet.EnableControls;
    FQuery.DataSet.Close;
  end;
end;

procedure TDataBaseDAO<T>.FreeMemory;
begin
  if Assigned(FQuery) then
  begin
    FQuery.FreeMemory;
    FQuery := Nil;
  end;

  if Assigned(FList) then
    FreeAndNil(FList);
  if Assigned(FDataSource) then
    FreeAndNil(FDataSource);
  if Assigned(FEntity) then
    FreeAndNil(FEntity);
end;

function TDataBaseDAO<T>.GroupBy(const pField: String): IDataBaseDAO<T>;
begin
  Result := Self;
  if Trim(FGroup).IsEmpty then
    FGroup := pField
  else
    FGroup := FGroup + ', ' + pField;
end;

procedure TDataBaseDAO<T>.Insert(pEntity: T);
var
  vSQL: String;
begin
  try
    TSQLMaker<T>.New(pEntity).Insert(vSQL);

    FQuery.SQL.Clear;
    FQuery.SQL.Add(vSQL);
    FQuery.FillParameter(pEntity, True);
    FQuery.ExecSQL;
  except
    on E: Exception do
    begin
      vgLog.DebugOut('Ocorreu erro ao inserir o registro!' + #13#10 + 'Detalhes: ' + E.Message, []);
      raise EDataBaseDAOError.Create(format('Ocorreu erro ao inserir o registro na base de dados.'+#13+'Classe %s.', [pEntity.ClassName]));
    end;
  end;
end;

function TDataBaseDAO<T>.ToList: TObjectList<T>;
var
  vSQL: String;
begin
  TSQLMaker<T>.New(FEntity)
    .Fields(FFields)
    .Where(FParameters)
    .RowNum(FRowNum)
    .GroupBy(FGroup)
    .OrderBy(FOrder)
  .Select(vSQL);

  FQuery.DataSet.DisableControls;
  try
    FQuery.SQL.Clear;
    FQuery.SQL.Add(vSQL);
    FQuery.FillParameter(FParameters);
    FQuery.Open;

    Result := TObjectList<T>.Create;

    TDataBaseRtti<T>.New(Self).DataSetToEntityList(FQuery.DataSet, Result);
  finally
    FQuery.DataSet.EnableControls;
    FQuery.DataSet.Close;
  end;
end;

procedure TDataBaseDAO<T>.Update(pEntity: T);
var
  vSQL: String;
begin
  try
    TSQLMaker<T>.New(pEntity).Where(FParameters).Update(vSQL);

    FQuery.SQL.Clear;
    FQuery.SQL.Add(vSQL);
    FQuery.FillParameter(pEntity);
    FQuery.FillParameter(FParameters);
    FQuery.ExecSQL;
  except
    on E: Exception do
    begin
      vgLog.DebugOut('Ocorreu erro ao atualizar o registro!' + #13#10 + 'Detalhes: ' + E.Message, []);
      raise EDataBaseDAOError.Create(format('Ocorreu erro ao atualizar o registro na base de dados.'+#13+'Classe %s.', [pEntity.ClassName]));
    end;
  end;
end;

function TDataBaseDAO<T>.Where(const pField: String; const pOperatorType: TOperatorType; const pValue: TValue): IDataBaseDAO<T>;
begin
  Result := Self;
  if pOperatorType = TOperatorType.otIsNotNull then
    FParameters.Add(pField, cOperator[pOperatorType])
  else
    FParameters.Add(pField, pValue);
end;

function TDataBaseDAO<T>.WhereAnd(const pField: String; const pOperatorType: TOperatorType; const pValue: TValue): IDataBaseDAO<T>;
begin
  Result := Self;
  if pOperatorType = TOperatorType.otIsNotNull then
    FParameters.Add(pField, cOperator[pOperatorType])
  else
    FParameters.Add(pField, pValue);
end;

end.
