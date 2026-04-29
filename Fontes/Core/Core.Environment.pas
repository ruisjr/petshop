unit Core.Environment;

interface

uses
  {Classes de sistema}
   System.Classes
  ,System.SysUtils
  {Classes de negócio}
  ,Core.Logs;

type
  TEnvironment = class(TPersistent)
  strict private
    FLog: ILog;
  public
    {Construtores e destrutores}
    constructor Create; reintroduce;
    destructor Destroy; override;

    property Log: ILog read FLog write FLog;
  end;

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

initialization
  gEnv := TEnvironment.Create;

finalization
  FreeAndNil(gEnv);

end.
