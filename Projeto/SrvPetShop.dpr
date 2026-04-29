program SrvPetShop;

uses
  Vcl.SvcMgr,
  SrvPetShopWindows in '..\Fontes\Server\SrvPetShopWindows.pas' {SrvPetShopApp: TService},
  Core.Api in '..\Fontes\Core\Core.Api.pas',
  Core.Email in '..\Fontes\Core\Core.Email.pas',
  Core.Environment in '..\Fontes\Core\Core.Environment.pas',
  Core.Exceptions in '..\Fontes\Core\Core.Exceptions.pas',
  Core.Functions in '..\Fontes\Core\Core.Functions.pas',
  Core.Global in '..\Fontes\Core\Core.Global.pas',
  Core.Logs in '..\Fontes\Core\Core.Logs.pas',
  Core.Servico in '..\Fontes\Core\Core.Servico.pas',
  Core.DataBase.Interfaces in '..\Fontes\Core\DB\Interfaces\Core.DataBase.Interfaces.pas',
  Core.DataBase.Access in '..\Fontes\Core\DB\Core.DataBase.Access.pas',
  Core.DataBase.Connection in '..\Fontes\Core\DB\Core.DataBase.Connection.pas',
  Core.DataBase.QueryBuilder in '..\Fontes\Core\DB\Core.DataBase.QueryBuilder.pas',
  Core.DataBase.Rtti in '..\Fontes\Core\DB\Core.DataBase.Rtti.pas',
  Core.DataBase.RttiHelper in '..\Fontes\Core\DB\Core.DataBase.RttiHelper.pas',
  Core.DataBase.SQLMaker in '..\Fontes\Core\DB\Core.DataBase.SQLMaker.pas',
  Core.DataBase.Types in '..\Fontes\Core\DB\Core.DataBase.Types.pas',
  Core.Entidades.CustomAttributes in '..\Fontes\Core\Entidades\Core.Entidades.CustomAttributes.pas',
  Core.Entidades.ModelBase in '..\Fontes\Core\Entidades\Core.Entidades.ModelBase.pas',
  Core.Thread in '..\Fontes\Core\Core.Thread.pas',
  Services.Users in '..\Fontes\Services\Services.Users.pas';

{$R *.RES}

begin
  // Windows 2003 Server requires StartServiceCtrlDispatcher to be
  // called before CoRegisterClassObject, which can be called indirectly
  // by Application.Initialize. TServiceApplication.DelayInitialize allows
  // Application.Initialize to be called from TService.Main (after
  // StartServiceCtrlDispatcher has been called).
  //
  // Delayed initialization of the Application object may affect
  // events which then occur prior to initialization, such as
  // TService.OnCreate. It is only recommended if the ServiceApplication
  // registers a class object with OLE and is intended for use with
  // Windows 2003 Server.
  //
  // Application.DelayInitialize := True;
  //
  if not Application.DelayInitialize or Application.Installing then
    Application.Initialize;
  Application.CreateForm(TSrvPetShopApp, SrvPetShopApp);
  Application.Run;
end.
