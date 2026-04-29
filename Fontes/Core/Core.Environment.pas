unit Core.Environment;

interface

uses
  {Classes de sistema}
   System.Classes
  ,System.SysUtils
  {Classes de negócio}
  ,Core.Logs;


type
  TEnvironment = class
  strict private
    FLog: ILog;
  public
    {Construtores e destrutores}
    constructor Create; reintroduce;
    destructor Destroy; override;

    property Log: ILog read FLog write FLog;
  end;

  {Função global para utilizar como singleton o objeto Environment}
  function Env: TEnvironment;

var
  gEnv: TEnvironment;

implementation

{ TEnvironment }

constructor TEnvironment.Create;
begin
  inherited;
  FLog := TLog.Create;
end;

destructor TEnvironment.Destroy;
begin
  inherited;
end;

function Env: TEnvironment;
begin
  if not Assigned(gEnv) then
    gEnv := TEnvironment.Create;

  Result := gEnv;
end;

initialization
  gEnv := Env;

finalization
  FreeAndNil(gEnv);

end.
