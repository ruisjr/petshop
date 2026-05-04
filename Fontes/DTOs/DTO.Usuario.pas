unit DTO.Usuario;

interface

uses
   {Classes de Negócio}
   Core.Entidades.ModelBase;

type
  TUsuarioDTO = class(TBaseModel)
  private
    FID: Integer;
    FNome: String;
    FEmail: String;
    FLogin: String;
    FAtivo: Boolean;
    FBloqueado: Boolean;
    FDataCadastro: TDateTime;
    FUltimoAcesso: TDateTime;
    FPrimeiroAcesso: Boolean;

  public
    [DBField('ID'), PK, NotNull, Seq('seq_usuario'), Display('Código')]
    property ID:    Integer          read FID             write FID;
    [DBField('nome'), NotNull, Display('Nome')]
    property Nome:  String           read FNome           write FNome;
    [DBField('login'), NotNull, Display('Login')]
    property Login: String           read FLogin          write FLogin;
    [DBField('email'), NotNull, Display('E-Mail')]
    property Email: String           read FEmail          write FEmail;
    [DBField('ativo')]
    property Ativo: Boolean          read FAtivo          write FAtivo;
    [DBField('bloqueado')]
    property Bloqueado: Boolean      read FBloqueado      write FBloqueado;
    [DBField('data_cadastro')]
    property DataCadastro: TDateTime read FDataCadastro   write FDataCadastro;
    [DBField('data_ultimo_acesso')]
    property UltimoAcesso: TDateTime read FUltimoAcesso   write FUltimoAcesso;
    [DBField('primeiro_acesso')]
    property PrimeiroAcesso: Boolean read FPrimeiroAcesso write FPrimeiroAcesso;
  end;

implementation

end.
