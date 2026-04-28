unit Core.DataBase.QueryBuilder;

interface

uses
  {Classes de sistema}
   Uni
  ,Data.Db
  ,System.Rtti
  ,System.Classes
  ,System.SysUtils
  ,System.Generics.Collections
  {Classes de negócio}
  ,Core.DataBase.Rtti
  ,Core.DataBase.Types
  ,Core.DataBase.Connection
  ,Core.DataBase.Interfaces;

type
  TQueryBuilder<T: class, constructor> = class(TInterfacedObject, IDataBaseQuery<T>)
  private
    FWhereClause: TStrings;
    FParams: TParams;
    FQuery: TUniQuery;
  public
    constructor Create(const pDBConn: TDataBaseConnection = nil);

    {Functions}
    function Where(const pFieldName: String; const pOperator: TOperatorType; const pValue: TValue): IDataBaseQuery<T>;
    function AndWhere(const pFieldName: String; const pOperator: TOperatorType; const pValue: TValue): IDataBaseQuery<T>;

    function Select(var pSQL: String): IDataBaseQuery<T>;

    function SQL: TStrings;
    function Params: TParams;
    function ExecSQL: IDataBaseQuery<T>;
    function DataSet: TDataSet;
    function Open(pSQL: String): IDataBaseQuery<T>; overload;
    function Open: IDataBaseQuery<T>; overload;

    {Procedures}
    procedure FreeMemory;
    procedure Next;
    procedure First;
    procedure FillParameter(pParameters: TDictionary<String, TValue>); overload;
    procedure FillParameter(pInstance: T; pInsert: Boolean = False); overload;
  end;

implementation


{ TQueryBuilder }

constructor TQueryBuilder<T>.Create(const pDBConn: TDataBaseConnection = nil);
begin
  FWhereClause := TStringList.Create;

  FQuery := TUniQuery.Create(nil);

  if pDBConn <> nil then
    FQuery.Connection := pDBConn.GetConnection
  else
    FQuery.Connection := vgDBConnection.GetConnection;

  FQuery.FetchRows := 25;
  FQuery.UniDirectional := True;
  FQuery.SpecificOptions.Values['FetchAll'] := 'False';
end;

function TQueryBuilder<T>.DataSet: TDataSet;
begin
  Result := TDataSet(FQuery);
end;

procedure TQueryBuilder<T>.FreeMemory;
begin
  FreeAndNil(FWhereClause);

  if FQuery.Active then
    FQuery.Close;

  if Assigned(FQuery) then
    FreeAndNil(FQuery);

  if Assigned(FParams) then
    FreeAndNil(FParams);
end;

function TQueryBuilder<T>.ExecSQL: IDataBaseQuery<T>;
begin
  Result := Self;

  if Assigned(FParams) then
    FQuery.Params.Assign(FParams);

  try
    FQuery.Prepare;
    FQuery.ExecSQL;
  except
    on E: Exception do
      raise Exception.Create('Ocorreu erro ao executar instrução na base de dados'+#10#13+E.Message);
  end;

  if Assigned(FParams) then
    FreeAndNil(FParams);
end;

procedure TQueryBuilder<T>.FillParameter(pInstance: T; pInsert: Boolean);
var
  Key: String;
  DictionaryFields: TDictionary<String, Variant>;
  DictionaryTypeFields: TDictionary<String, TFieldType>;
  FieldType: TFieldType;
begin
  DictionaryFields := TDictionary<String, Variant>.Create;
  DictionaryTypeFields := TDictionary<String, TFieldType>.Create;
  TDataBaseRtti<T>.New(pInstance).DictionaryFields(DictionaryFields);
  TDataBaseRtti<T>.New(pInstance).DictionaryTypeFields(DictionaryTypeFields);
  try
    for Key in DictionaryFields.Keys do
    begin
      if FQuery.Params.FindParam(Key) <> nil then
      begin
        if DictionaryTypeFields.TryGetValue(Key, FieldType ) then
        begin
          if (FieldType = ftOraClob) then
          begin
            FQuery.Params.ParamByName(Key).ParamType := ptOutPut;
            if pInsert then
              FQuery.Params.ParamByName(Key).ParamType := ptInput
          end;
          FQuery.Params.ParamByName(Key).DataType := FieldType;
        end;

        FQuery.Params.ParamByName(Key).Value := DictionaryFields.Items[Key];
      end;
    end;
  finally
    FreeAndNil(DictionaryFields);
    FreeAndNil(DictionaryTypeFields);
  end;
end;

procedure TQueryBuilder<T>.FillParameter(pParameters: TDictionary<String, TValue>);
var
  Key: String;
  KeyPar: String;
  FieldType: TFieldType;
  DictionaryTypeFields: TDictionary<String, TFieldType>;
begin
  DictionaryTypeFields := TDictionary<String, TFieldType>.Create;
  try
    TDataBaseRtti<T>.New(nil).DictionaryTypeFields(pParameters, DictionaryTypeFields);

    for Key in pParameters.Keys do
    begin
      KeyPar := 'PAR_'+Key;
      if (FQuery.Params.FindParam(KeyPar) <> nil) or
         (FQuery.Params.FindParam(Key) <> nil) then
      begin
        if DictionaryTypeFields.TryGetValue(Key, FieldType) then
        begin
          if (FQuery.Params.FindParam(KeyPar) <> nil) then
            FQuery.Params.ParamByName(KeyPar).DataType := FieldType
          else
            FQuery.Params.ParamByName(Key).DataType := FieldType
        end;

        if (FQuery.Params.FindParam(KeyPar) <> nil) then
          FQuery.Params.ParamByName(KeyPar).Value := pParameters.Items[Key].AsVariant
        else
          FQuery.Params.ParamByName(Key).Value := pParameters.Items[Key].AsVariant
      end;
    end;
  finally
    FreeAndNil(DictionaryTypeFields);
  end;
end;

procedure TQueryBuilder<T>.First;
begin
  FQuery.First;
end;

procedure TQueryBuilder<T>.Next;
begin
  FQuery.Next;
end;

function TQueryBuilder<T>.Open(pSQL: String): IDataBaseQuery<T>;
begin
  Result := Self;

  FQuery.Close;
  FQuery.SQL.Add(pSQL);
  FQuery.Open;
end;

function TQueryBuilder<T>.Open: IDataBaseQuery<T>;
begin
  Result := Self;
  FQuery.Close;

  if Assigned(FParams) then
    FQuery.Params.Assign(FParams);

  FQuery.Prepare;
  FQuery.Open;

  if Assigned(FParams) then
    FreeAndNil(FParams);
end;

function TQueryBuilder<T>.Params: TParams;
begin
  if not Assigned(FParams) then
  begin
    FParams := TParams.Create(nil);
    FParams.Assign(FQuery.Params);
  end;
  Result := FParams;
end;

function TQueryBuilder<T>.Select(var pSQL: String): IDataBaseQuery<T>;
begin
  Result := Self;
end;

function TQueryBuilder<T>.SQL: TStrings;
begin
  Result := FQuery.SQL;
end;

function TQueryBuilder<T>.Where(const pFieldName: String; const pOperator: TOperatorType; const pValue: TValue): IDataBaseQuery<T>;
var
  vOperator: String;
begin
  vOperator := cOperator[pOperator];
  FWhereClause.Add(Format('%s %s :%s', [pFieldName, vOperator, pValue.AsVariant] ) );

  FParams.Add;
  FParams.ParamByName(pFieldName).Value := pValue.AsVariant;

  Result := Self;
end;

function TQueryBuilder<T>.AndWhere(const pFieldName: String; const pOperator: TOperatorType; const pValue: TValue): IDataBaseQuery<T>;
begin
  Exit(AndWhere(pFieldName, pOperator, pValue));
end;

end.
