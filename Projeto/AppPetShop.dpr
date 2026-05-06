program AppPetShop;

uses
  Vcl.Forms,
  AppSrvPetShop in 'AppSrvPetShop.pas' {FrmPrincipal},
  Core.Api in '..\Fontes\Core\Core.Api.pas',
  Core.Email in '..\Fontes\Core\Core.Email.pas',
  Core.Environment in '..\Fontes\Core\Core.Environment.pas',
  Core.Exceptions in '..\Fontes\Core\Core.Exceptions.pas',
  Core.Functions in '..\Fontes\Core\Core.Functions.pas',
  Core.Global in '..\Fontes\Core\Core.Global.pas',
  Core.Logs in '..\Fontes\Core\Core.Logs.pas',
  Core.Servico in '..\Fontes\Core\Core.Servico.pas',
  Core.Thread in '..\Fontes\Core\Core.Thread.pas',
  Core.DataBase.Access in '..\Fontes\Core\DB\Core.DataBase.Access.pas',
  Core.DataBase.Connection in '..\Fontes\Core\DB\Core.DataBase.Connection.pas',
  Core.DataBase.QueryBuilder in '..\Fontes\Core\DB\Core.DataBase.QueryBuilder.pas',
  Core.DataBase.Rtti in '..\Fontes\Core\DB\Core.DataBase.Rtti.pas',
  Core.DataBase.RttiHelper in '..\Fontes\Core\DB\Core.DataBase.RttiHelper.pas',
  Core.DataBase.SQLMaker in '..\Fontes\Core\DB\Core.DataBase.SQLMaker.pas',
  Core.DataBase.Types in '..\Fontes\Core\DB\Core.DataBase.Types.pas',
  Core.DataBase.Interfaces in '..\Fontes\Core\DB\Interfaces\Core.DataBase.Interfaces.pas',
  Core.Entidades.CustomAttributes in '..\Fontes\Core\Entidades\Core.Entidades.CustomAttributes.pas',
  Core.Entidades.ModelBase in '..\Fontes\Core\Entidades\Core.Entidades.ModelBase.pas',
  Services.Users in '..\Fontes\Services\Services.Users.pas',
  Controller.User in '..\Fontes\Controllers\Controller.User.pas',
  Entidade.Usuario in '..\Fontes\Entidades\Entidade.Usuario.pas',
  DTO.Usuario in '..\Fontes\DTOs\DTO.Usuario.pas',
  Core.Rest.JsonHelper in '..\Fontes\Core\Core.Rest.JsonHelper.pas',
  Controller.Base in '..\Fontes\Controllers\Controller.Base.pas',
  Entidade.Pessoa in '..\Fontes\Entidades\Entidade.Pessoa.pas',
  Controller.Pessoa in '..\Fontes\Controllers\Controller.Pessoa.pas',
  Services.Pessoa in '..\Fontes\Services\Services.Pessoa.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.
